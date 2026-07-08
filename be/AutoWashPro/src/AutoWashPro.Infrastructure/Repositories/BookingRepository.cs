using AutoWashPro.Application.DTOs;
using AutoWashPro.Application.Interfaces;
using AutoWashPro.Domain.Entities;
using AutoWashPro.Domain.Enums;
using AutoWashPro.Infrastructure.Data;
using Microsoft.EntityFrameworkCore;

namespace AutoWashPro.Infrastructure.Repositories;

public class BookingRepository : IBookingRepository
{
    private readonly ApplicationDbContext _context;

    public BookingRepository(ApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<List<AvailableSlotDTO>> GetAvailableSlotsAsync(DateTime date, Guid serviceId)
    {
        var normalizedDate = date.Date;

        var rawSlots = await _context.TimeSlots
            .Where(ts => ts.Date.Date == normalizedDate)
            .Select(ts => new
            {
                TimeSlotId = ts.Id,
                ts.StartTime,
                ts.EndTime,
                ActiveBookingsCount = ts.Bookings.Count(b => b.Status != BookingStatus.Cancelled),
                ts.MaxCapacity
            })
            .OrderBy(s => s.StartTime)
            .ToListAsync();

        var slots = rawSlots.Select(ts => new AvailableSlotDTO
        {
            TimeSlotId = ts.TimeSlotId,
            StartTime = ts.StartTime.ToString(@"hh\:mm"),
            EndTime = ts.EndTime.ToString(@"hh\:mm"),
            IsAvailable = ts.ActiveBookingsCount < ts.MaxCapacity,
            RemainingCapacity = ts.MaxCapacity - ts.ActiveBookingsCount
        }).ToList();

        return slots;
    }

    public async Task<BookingSummaryDTO> GetBookingSummaryAsync(Guid userId, CreateBookingDTO dto)
    {
        var user = await _context.Users.FindAsync(userId)
            ?? throw new Exception("Không tìm thấy người dùng.");

        var service = await _context.Services.FindAsync(dto.ServiceId)
            ?? throw new Exception("Không tìm thấy dịch vụ.");

        var vehicle = await _context.Vehicles.FindAsync(dto.VehicleId)
            ?? throw new Exception("Không tìm thấy xe.");

        var timeSlot = await _context.TimeSlots.FindAsync(dto.TimeSlotId)
            ?? throw new Exception("Không tìm thấy khung giờ.");

        var discountPercentage = user.Tier.GetDiscountPercentage();
        var discountAmount = service.Price * discountPercentage / 100;
        var finalPrice = service.Price - discountAmount;

        var perkApplied = discountPercentage > 0
            ? $"Giảm {discountPercentage}% cho hạng {user.Tier.GetTierName()}"
            : "Không có ưu đãi";

        decimal voucherDiscountAmount = 0;
        string? voucherCode = null;

        if (dto.VoucherId.HasValue)
        {
            var voucher = await _context.Vouchers
                .Include(v => v.Reward)
                .FirstOrDefaultAsync(v => v.Id == dto.VoucherId.Value && v.UserId == userId);

            if (voucher != null)
            {
                if (voucher.IsUsed)
                {
                    throw new Exception("Voucher này đã được sử dụng.");
                }
                if (voucher.ExpiryDate < DateTime.UtcNow)
                {
                    throw new Exception("Voucher này đã hết hạn.");
                }

                voucherCode = voucher.Code;
                if (voucher.Reward.Type == RewardType.Discount)
                {
                    voucherDiscountAmount = service.Price * voucher.Reward.DiscountValue / 100;
                }
                else
                {
                    voucherDiscountAmount = voucher.Reward.DiscountValue;
                }

                if (voucherDiscountAmount > finalPrice)
                {
                    voucherDiscountAmount = finalPrice;
                }
                finalPrice -= voucherDiscountAmount;
            }
        }

        return new BookingSummaryDTO
        {
            ServiceId = service.Id,
            ServiceName = service.Name,
            VehicleId = vehicle.Id,
            VehiclePlate = vehicle.LicensePlate,
            VehicleTypeName = vehicle.VehicleType == VehicleType.Car ? "Ô tô" : "Xe máy",
            BookingDate = dto.BookingDate,
            TimeSlotDisplay = $"{timeSlot.StartTime:hh\\:mm} - {timeSlot.EndTime:hh\\:mm}",
            OriginalPrice = service.Price,
            DiscountPercentage = discountPercentage,
            DiscountAmount = discountAmount,
            VoucherDiscountAmount = voucherDiscountAmount,
            VoucherCode = voucherCode,
            FinalPrice = finalPrice,
            TierName = user.Tier.GetTierName(),
            PerkApplied = perkApplied
        };
    }

    public async Task<BookingConfirmationDTO> CreateBookingAsync(Guid userId, CreateBookingDTO dto)
    {
        var user = await _context.Users.FindAsync(userId)
            ?? throw new Exception("Không tìm thấy người dùng.");

        var service = await _context.Services.FindAsync(dto.ServiceId)
            ?? throw new Exception("Không tìm thấy dịch vụ.");

        var vehicle = await _context.Vehicles
            .FirstOrDefaultAsync(v => v.Id == dto.VehicleId && v.UserId == userId)
            ?? throw new Exception("Xe không thuộc về bạn.");

        var timeSlot = await _context.TimeSlots
            .Include(ts => ts.Bookings)
            .FirstOrDefaultAsync(ts => ts.Id == dto.TimeSlotId)
            ?? throw new Exception("Không tìm thấy khung giờ.");

        // Check capacity
        var activeBookings = timeSlot.Bookings.Count(b => b.Status != BookingStatus.Cancelled);
        if (activeBookings >= timeSlot.MaxCapacity)
            throw new Exception("Khung giờ đã đầy, vui lòng chọn khung giờ khác.");

        // Check tier-based date limit
        var maxDays = user.Tier.GetMaxBookingDays();
        var maxDate = DateTime.UtcNow.Date.AddDays(maxDays);
        if (dto.BookingDate.Date > maxDate)
            throw new Exception($"Hạng {user.Tier.GetTierName()} chỉ được đặt lịch trong {maxDays} ngày tới.");

        // Calculate pricing
        var discountPercentage = user.Tier.GetDiscountPercentage();
        var discountAmount = service.Price * discountPercentage / 100;
        var totalPrice = service.Price - discountAmount;

        decimal voucherDiscountAmount = 0;
        Voucher? appliedVoucher = null;

        if (dto.VoucherId.HasValue)
        {
            appliedVoucher = await _context.Vouchers
                .Include(v => v.Reward)
                .FirstOrDefaultAsync(v => v.Id == dto.VoucherId.Value && v.UserId == userId);

            if (appliedVoucher == null)
            {
                throw new Exception("Không tìm thấy voucher hợp lệ.");
            }
            if (appliedVoucher.IsUsed)
            {
                throw new Exception("Voucher này đã được sử dụng.");
            }
            if (appliedVoucher.ExpiryDate < DateTime.UtcNow)
            {
                throw new Exception("Voucher này đã hết hạn.");
            }

            if (appliedVoucher.Reward.Type == RewardType.Discount)
            {
                voucherDiscountAmount = service.Price * appliedVoucher.Reward.DiscountValue / 100;
            }
            else
            {
                voucherDiscountAmount = appliedVoucher.Reward.DiscountValue;
            }

            if (voucherDiscountAmount > totalPrice)
            {
                voucherDiscountAmount = totalPrice;
            }
            totalPrice -= voucherDiscountAmount;
            
            // Mark voucher as used
            appliedVoucher.IsUsed = true;
        }

        // Generate QR Code (Base64 encoded booking info)
        var bookingId = Guid.NewGuid();
        var qrData = $"AUTOWASH|{bookingId}|{vehicle.LicensePlate}|{dto.BookingDate:yyyy-MM-dd}|{timeSlot.StartTime:hh\\:mm}";
        var qrCode = Convert.ToBase64String(System.Text.Encoding.UTF8.GetBytes(qrData));

        var booking = new Booking
        {
            Id = bookingId,
            UserId = userId,
            ServiceId = dto.ServiceId,
            VehicleId = dto.VehicleId,
            BookingDate = dto.BookingDate.Date,
            TimeSlotId = dto.TimeSlotId,
            TotalPrice = totalPrice,
            DiscountAmount = discountAmount + voucherDiscountAmount,
            Status = BookingStatus.Confirmed,
            QrCode = qrCode,
            CreatedAt = DateTime.UtcNow
        };

        _context.Bookings.Add(booking);

        await _context.SaveChangesAsync();

        return new BookingConfirmationDTO
        {
            BookingId = booking.Id,
            QrCode = booking.QrCode,
            Status = booking.Status.ToString(),
            ServiceName = service.Name,
            VehiclePlate = vehicle.LicensePlate,
            BookingDate = booking.BookingDate,
            TimeSlotDisplay = $"{timeSlot.StartTime:hh\\:mm} - {timeSlot.EndTime:hh\\:mm}",
            TotalPrice = totalPrice
        };
    }

    public async Task<List<BookingListDTO>> GetUserBookingsAsync(Guid userId)
    {
        return await _context.Bookings
            .Where(b => b.UserId == userId)
            .Include(b => b.Service)
            .Include(b => b.Vehicle)
            .Include(b => b.TimeSlot)
            .OrderByDescending(b => b.BookingDate)
            .Select(b => new BookingListDTO
            {
                Id = b.Id,
                ServiceName = b.Service.Name,
                VehiclePlate = b.Vehicle.LicensePlate,
                BookingDate = b.BookingDate,
                TimeSlotDisplay = $"{b.TimeSlot.StartTime:hh\\:mm} - {b.TimeSlot.EndTime:hh\\:mm}",
                TotalPrice = b.TotalPrice,
                Status = b.Status.ToString(),
                QrCode = b.QrCode,
                StaffId = b.StaffId,
                Checklist = b.Checklist,
                CompletionImageUrl = b.CompletionImageUrl,
                CompletedAt = b.CompletedAt
            })
            .ToListAsync();
    }

    public async Task<bool> CancelBookingAsync(Guid bookingId, Guid userId)
    {
        var booking = await _context.Bookings
            .FirstOrDefaultAsync(b => b.Id == bookingId && b.UserId == userId);

        if (booking == null) return false;
        if (booking.Status == BookingStatus.Cancelled) return false;

        booking.Status = BookingStatus.Cancelled;
        await _context.SaveChangesAsync();
        return true;
    }

    public async Task<List<BookingListDTO>> GetTodayBookingsAsync(DateTime today)
    {
        // For Staff, return all non-completed/non-cancelled bookings to easily track work
        return await _context.Bookings
            .Include(b => b.Service)
            .Include(b => b.Vehicle)
            .Include(b => b.TimeSlot)
            .Where(b => b.Status != BookingStatus.Completed && b.Status != BookingStatus.Cancelled)
            .OrderBy(b => b.BookingDate)
            .ThenBy(b => b.TimeSlot.StartTime)
            .Select(b => new BookingListDTO
            {
                Id = b.Id,
                ServiceName = b.Service.Name,
                VehiclePlate = b.Vehicle.LicensePlate,
                BookingDate = b.BookingDate,
                TimeSlotDisplay = $"{b.TimeSlot.StartTime:hh\\:mm} - {b.TimeSlot.EndTime:hh\\:mm}",
                TotalPrice = b.TotalPrice,
                Status = b.Status.ToString(),
                QrCode = b.QrCode,
                StaffId = b.StaffId,
                Checklist = b.Checklist,
                CompletionImageUrl = b.CompletionImageUrl,
                CompletedAt = b.CompletedAt
            })
            .ToListAsync();
    }

    public async Task<bool> UpdateStatusAsync(Guid bookingId, int newStatus)
    {
        var booking = await _context.Bookings.FindAsync(bookingId);
        if (booking == null) return false;

        if (Enum.IsDefined(typeof(BookingStatus), newStatus))
        {
            booking.Status = (BookingStatus)newStatus;
            await _context.SaveChangesAsync();
            return true;
        }
        return false;
    }

    public async Task<bool> ClaimBookingAsync(Guid bookingId, Guid staffId)
    {
        var booking = await _context.Bookings.FindAsync(bookingId);
        if (booking == null) return false;
        
        if (booking.StaffId == null)
        {
            booking.StaffId = staffId;
            await _context.SaveChangesAsync();
            return true;
        }
        return booking.StaffId == staffId; // already claimed by this staff
    }

    public async Task<bool> UpdateChecklistAsync(Guid bookingId, string checklistJson)
    {
        var booking = await _context.Bookings.FindAsync(bookingId);
        if (booking == null) return false;

        booking.Checklist = checklistJson;
        await _context.SaveChangesAsync();
        return true;
    }

    public async Task<bool> CompleteBookingAsync(Guid bookingId, string imageUrl)
    {
        var booking = await _context.Bookings.FindAsync(bookingId);
        if (booking == null) return false;

        booking.Status = BookingStatus.Completed;
        booking.CompletionImageUrl = imageUrl;
        booking.CompletedAt = DateTime.UtcNow;
        await _context.SaveChangesAsync();
        return true;
    }

    public async Task<object> GetStaffStatsAsync(Guid staffId)
    {
        var today = DateTime.UtcNow.Date;
        var startOfWeek = today.AddDays(-(int)today.DayOfWeek + (int)DayOfWeek.Monday); // Assuming Monday is start of week
        if (today.DayOfWeek == DayOfWeek.Sunday) startOfWeek = startOfWeek.AddDays(-7);

        var allRelevantBookings = await _context.Bookings
            .Where(b => b.StaffId == staffId || (b.StaffId == null && (b.Status == BookingStatus.Pending || b.Status == BookingStatus.Confirmed)))
            .ToListAsync();

        var todayCompleted = allRelevantBookings.Count(b => b.StaffId == staffId && b.Status == BookingStatus.Completed && b.CompletedAt.HasValue && b.CompletedAt.Value.Date == today);
        var weekCompleted = allRelevantBookings.Count(b => b.StaffId == staffId && b.Status == BookingStatus.Completed && b.CompletedAt.HasValue && b.CompletedAt.Value.Date >= startOfWeek);
        var activeJobs = allRelevantBookings.Count(b => (b.StaffId == null && (b.Status == BookingStatus.Pending || b.Status == BookingStatus.Confirmed)) || (b.StaffId == staffId && (b.Status == BookingStatus.Pending || b.Status == BookingStatus.Confirmed || b.Status == BookingStatus.InProgress)));

        return new
        {
            TodayCompleted = todayCompleted,
            WeekCompleted = weekCompleted,
            ActiveJobs = activeJobs
        };
    }
}

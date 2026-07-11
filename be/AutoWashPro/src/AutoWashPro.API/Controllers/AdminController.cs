using AutoWashPro.Application.Common;
using AutoWashPro.Domain.Entities;
using AutoWashPro.Domain.Enums;
using AutoWashPro.Infrastructure.Data;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace AutoWashPro.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize(Roles = "Admin")]
public class AdminController : ControllerBase
{
    private readonly ApplicationDbContext _context;

    public AdminController(ApplicationDbContext context)
    {
        _context = context;
    }

    // ==================== STATS ====================
    [HttpGet("stats")]
    public async Task<IActionResult> GetStats()
    {
        try
        {
            var today = DateTime.UtcNow.Date;

            var totalUsers = await _context.Users.CountAsync(u => u.Role == UserRole.Customer);
            var totalBookings = await _context.Bookings.CountAsync();
            
            var todayRevenue = await _context.Bookings
                .Where(b => b.BookingDate.Date == today && b.Status != BookingStatus.Cancelled)
                .SumAsync(b => (double)b.TotalPrice);

            var pendingWashes = await _context.Bookings
                .CountAsync(b => b.BookingDate.Date == today && 
                                (b.Status == BookingStatus.Confirmed || 
                                 b.Status == BookingStatus.Pending || 
                                 b.Status == BookingStatus.InProgress));

            var stats = new AdminStatsDTO
            {
                TotalUsers = totalUsers,
                TotalBookings = totalBookings,
                TodayRevenue = (decimal)todayRevenue,
                PendingWashes = pendingWashes
            };

            return Ok(ApiResponse<AdminStatsDTO>.SuccessResponse(stats));
        }
        catch (Exception ex)
        {
            return BadRequest(ApiResponse<AdminStatsDTO>.ErrorResponse(ex.Message));
        }
    }

    // ==================== BOOKINGS ====================
    [HttpGet("bookings")]
    public async Task<IActionResult> GetBookings([FromQuery] string? status, [FromQuery] DateTime? date)
    {
        try
        {
            var query = _context.Bookings
                .Include(b => b.User)
                .Include(b => b.Service)
                .Include(b => b.Vehicle)
                .Include(b => b.TimeSlot)
                .AsQueryable();

            if (!string.IsNullOrEmpty(status) && Enum.TryParse<BookingStatus>(status, true, out var statusEnum))
            {
                query = query.Where(b => b.Status == statusEnum);
            }

            if (date.HasValue)
            {
                var targetDate = date.Value.Date;
                query = query.Where(b => b.BookingDate.Date == targetDate);
            }

            var rawBookings = await query
                .OrderByDescending(b => b.BookingDate)
                .ThenBy(b => b.TimeSlot.StartTime)
                .ToListAsync();

            // Load staff names for bookings that have staff assigned
            var staffIds = rawBookings.Where(b => b.StaffId != null).Select(b => b.StaffId!.Value).Distinct().ToList();
            var staffNames = await _context.Users
                .Where(u => staffIds.Contains(u.Id))
                .ToDictionaryAsync(u => u.Id, u => u.FullName);

            var bookingsList = rawBookings.Select(b => new AdminBookingDTO
            {
                Id = b.Id,
                CustomerName = b.User.FullName,
                CustomerEmail = b.User.Email,
                ServiceName = b.Service.Name,
                VehiclePlate = b.Vehicle.LicensePlate,
                BookingDate = b.BookingDate,
                TimeSlotDisplay = $"{b.TimeSlot.StartTime:hh\\:mm} - {b.TimeSlot.EndTime:hh\\:mm}",
                TotalPrice = b.TotalPrice,
                Status = b.Status.ToString(),
                QrCode = b.QrCode,
                StaffId = b.StaffId,
                StaffName = b.StaffId != null && staffNames.ContainsKey(b.StaffId.Value) ? staffNames[b.StaffId.Value] : null
            }).ToList();

            return Ok(ApiResponse<List<AdminBookingDTO>>.SuccessResponse(bookingsList));
        }
        catch (Exception ex)
        {
            return BadRequest(ApiResponse<List<AdminBookingDTO>>.ErrorResponse(ex.Message));
        }
    }

    [HttpPut("bookings/{id}/status")]
    public async Task<IActionResult> UpdateBookingStatus(Guid id, [FromBody] UpdateBookingStatusDTO dto)
    {
        try
        {
            var booking = await _context.Bookings
                .Include(b => b.User)
                .FirstOrDefaultAsync(b => b.Id == id);
            if (booking == null)
            {
                return NotFound(ApiResponse<bool>.ErrorResponse("Không tìm thấy booking."));
            }

            if (!Enum.IsDefined(typeof(BookingStatus), dto.Status))
            {
                return BadRequest(ApiResponse<bool>.ErrorResponse("Trạng thái không hợp lệ."));
            }

            var newStatus = (BookingStatus)dto.Status;
            if (booking.Status != BookingStatus.Completed && newStatus == BookingStatus.Completed)
            {
                // Add loyalty points (10 points per 100k VND)
                var pointsEarned = (int)(booking.TotalPrice / 100000) * 10;
                if (booking.User != null)
                {
                    booking.User.LoyaltyPoints += pointsEarned;
                    booking.User.UpdateTier();
                }

                // Auto-deduct chemicals
                await DeductChemicalsForBooking(booking);
            }

            booking.Status = newStatus;
            await _context.SaveChangesAsync();

            return Ok(ApiResponse<bool>.SuccessResponse(true, "Cập nhật trạng thái thành công!"));
        }
        catch (Exception ex)
        {
            return BadRequest(ApiResponse<bool>.ErrorResponse(ex.Message));
        }
    }

    // ==================== ASSIGN STAFF ====================
    [HttpPut("bookings/{id}/assign-staff")]
    public async Task<IActionResult> AssignStaff(Guid id, [FromBody] AssignStaffDTO dto)
    {
        try
        {
            var booking = await _context.Bookings.FindAsync(id);
            if (booking == null)
                return NotFound(ApiResponse<bool>.ErrorResponse("Không tìm thấy booking."));

            if (booking.StaffId != null)
                return BadRequest(ApiResponse<bool>.ErrorResponse("Booking này đã được gán nhân viên."));

            var staff = await _context.Users.FirstOrDefaultAsync(u => u.Id == dto.StaffId && u.Role == UserRole.Staff);
            if (staff == null)
                return BadRequest(ApiResponse<bool>.ErrorResponse("Không tìm thấy nhân viên hợp lệ."));

            booking.StaffId = dto.StaffId;
            await _context.SaveChangesAsync();

            return Ok(ApiResponse<bool>.SuccessResponse(true, "Gán nhân viên thành công!"));
        }
        catch (Exception ex)
        {
            return BadRequest(ApiResponse<bool>.ErrorResponse(ex.Message));
        }
    }

    [HttpGet("staff")]
    public async Task<IActionResult> GetStaffList()
    {
        try
        {
            var staffList = await _context.Users
                .Where(u => u.Role == UserRole.Staff)
                .OrderBy(u => u.FullName)
                .Select(u => new StaffListDTO
                {
                    Id = u.Id,
                    FullName = u.FullName,
                    Email = u.Email,
                    Phone = u.Phone
                })
                .ToListAsync();

            return Ok(ApiResponse<List<StaffListDTO>>.SuccessResponse(staffList));
        }
        catch (Exception ex)
        {
            return BadRequest(ApiResponse<List<StaffListDTO>>.ErrorResponse(ex.Message));
        }
    }

    // ==================== USERS & STAFF ====================
    [HttpGet("users")]
    public async Task<IActionResult> GetUsers()
    {
        try
        {
            var customers = await _context.Users
                .Where(u => u.Role == UserRole.Customer || u.Role == UserRole.Staff)
                .OrderByDescending(u => u.CreatedAt)
                .Select(u => new AdminUserDTO
                {
                    Id = u.Id,
                    FullName = u.FullName,
                    Email = u.Email,
                    Phone = u.Phone,
                    Tier = u.Tier.ToString(),
                    LoyaltyPoints = u.LoyaltyPoints,
                    Role = u.Role.ToString(),
                    CreatedAt = u.CreatedAt
                })
                .ToListAsync();

            return Ok(ApiResponse<List<AdminUserDTO>>.SuccessResponse(customers));
        }
        catch (Exception ex)
        {
            return BadRequest(ApiResponse<List<AdminUserDTO>>.ErrorResponse(ex.Message));
        }
    }

    [HttpPost("staff")]
    public async Task<IActionResult> CreateStaff([FromBody] CreateStaffDTO dto)
    {
        try
        {
            if (await _context.Users.AnyAsync(u => u.Email == dto.Email))
            {
                return BadRequest(ApiResponse<bool>.ErrorResponse("Email này đã được sử dụng."));
            }

            var staffUser = new User
            {
                FullName = dto.FullName,
                Email = dto.Email,
                Phone = dto.Phone,
                PasswordHash = BCrypt.Net.BCrypt.HashPassword(dto.Password),
                Role = UserRole.Staff,
                Tier = MemberTier.Member,
                LoyaltyPoints = 0,
                CreatedAt = DateTime.UtcNow
            };

            _context.Users.Add(staffUser);
            await _context.SaveChangesAsync();

            return Ok(ApiResponse<bool>.SuccessResponse(true, "Tạo tài khoản nhân viên thành công!"));
        }
        catch (Exception ex)
        {
            return BadRequest(ApiResponse<bool>.ErrorResponse(ex.Message));
        }
    }

    // ==================== SERVICES CRUD ====================
    [HttpPost("services")]
    public async Task<IActionResult> CreateService([FromBody] CreateServiceDTO dto)
    {
        try
        {
            var newService = new Service
            {
                Name = dto.Name,
                Description = dto.Description,
                Price = dto.Price,
                DurationMinutes = dto.DurationMinutes,
                ImageUrl = dto.ImageUrl ?? string.Empty,
                IsActive = true
            };

            _context.Services.Add(newService);
            await _context.SaveChangesAsync();

            return Ok(ApiResponse<bool>.SuccessResponse(true, "Thêm dịch vụ thành công!"));
        }
        catch (Exception ex)
        {
            return BadRequest(ApiResponse<bool>.ErrorResponse(ex.Message));
        }
    }

    [HttpPut("services/{id}")]
    public async Task<IActionResult> UpdateService(Guid id, [FromBody] UpdateServiceDTO dto)
    {
        try
        {
            var service = await _context.Services.FindAsync(id);
            if (service == null)
            {
                return NotFound(ApiResponse<bool>.ErrorResponse("Không tìm thấy dịch vụ."));
            }

            service.Name = dto.Name;
            service.Description = dto.Description;
            service.Price = dto.Price;
            service.DurationMinutes = dto.DurationMinutes;
            service.ImageUrl = dto.ImageUrl ?? string.Empty;
            service.IsActive = dto.IsActive;

            await _context.SaveChangesAsync();

            return Ok(ApiResponse<bool>.SuccessResponse(true, "Cập nhật dịch vụ thành công!"));
        }
        catch (Exception ex)
        {
            return BadRequest(ApiResponse<bool>.ErrorResponse(ex.Message));
        }
    }

    [HttpDelete("services/{id}")]
    public async Task<IActionResult> DeleteService(Guid id)
    {
        try
        {
            var service = await _context.Services.FindAsync(id);
            if (service == null)
            {
                return NotFound(ApiResponse<bool>.ErrorResponse("Không tìm thấy dịch vụ."));
            }

            service.IsActive = false;
            await _context.SaveChangesAsync();

            return Ok(ApiResponse<bool>.SuccessResponse(true, "Vô hiệu hóa dịch vụ thành công!"));
        }
        catch (Exception ex)
        {
            return BadRequest(ApiResponse<bool>.ErrorResponse(ex.Message));
        }
    }

    // ==================== TIMESLOTS CRUD ====================
    [HttpGet("timeslots")]
    public async Task<IActionResult> GetTimeSlots()
    {
        try
        {
            var slots = await _context.TimeSlots
                .Include(t => t.Bookings)
                .OrderByDescending(t => t.Date)
                .ThenBy(t => t.StartTime)
                .Select(t => new AdminTimeSlotDTO
                {
                    Id = t.Id,
                    Date = t.Date,
                    StartTime = t.StartTime.ToString(@"hh\:mm"),
                    EndTime = t.EndTime.ToString(@"hh\:mm"),
                    MaxCapacity = t.MaxCapacity,
                    BookingsCount = t.Bookings.Count
                })
                .ToListAsync();

            return Ok(ApiResponse<List<AdminTimeSlotDTO>>.SuccessResponse(slots));
        }
        catch (Exception ex)
        {
            return BadRequest(ApiResponse<List<AdminTimeSlotDTO>>.ErrorResponse(ex.Message));
        }
    }

    [HttpPost("timeslots")]
    public async Task<IActionResult> CreateTimeSlot([FromBody] CreateTimeSlotDTO dto)
    {
        try
        {
            if (!TimeSpan.TryParse(dto.StartTime, out var startTimeSpan) || 
                !TimeSpan.TryParse(dto.EndTime, out var endTimeSpan))
            {
                return BadRequest(ApiResponse<bool>.ErrorResponse("Định dạng giờ không hợp lệ (ví dụ: '08:00')."));
            }

            var hasOverlap = await _context.TimeSlots.AnyAsync(t =>
                t.Date == dto.Date.Date &&
                startTimeSpan < t.EndTime &&
                t.StartTime < endTimeSpan
            );

            if (hasOverlap)
            {
                return BadRequest(ApiResponse<bool>.ErrorResponse("Khung giờ mới bị trùng/đè lên một khung giờ khác đã tồn tại trong ngày đó."));
            }

            var newSlot = new TimeSlot
            {
                Date = dto.Date.Date,
                StartTime = startTimeSpan,
                EndTime = endTimeSpan,
                MaxCapacity = dto.MaxCapacity
            };

            _context.TimeSlots.Add(newSlot);
            await _context.SaveChangesAsync();

            return Ok(ApiResponse<bool>.SuccessResponse(true, "Tạo khung giờ thành công!"));
        }
        catch (Exception ex)
        {
            return BadRequest(ApiResponse<bool>.ErrorResponse(ex.Message));
        }
    }

    [HttpPut("timeslots/{id}")]
    public async Task<IActionResult> UpdateTimeSlot(Guid id, [FromBody] UpdateTimeSlotDTO dto)
    {
        try
        {
            var slot = await _context.TimeSlots
                .Include(t => t.Bookings)
                .FirstOrDefaultAsync(t => t.Id == id);

            if (slot == null)
            {
                return NotFound(ApiResponse<bool>.ErrorResponse("Không tìm thấy khung giờ."));
            }

            if (!TimeSpan.TryParse(dto.StartTime, out var startTimeSpan) || 
                !TimeSpan.TryParse(dto.EndTime, out var endTimeSpan))
            {
                return BadRequest(ApiResponse<bool>.ErrorResponse("Định dạng giờ không hợp lệ (ví dụ: '08:00')."));
            }

            // If slot has bookings, check if date/time is changing
            if (slot.Bookings.Any())
            {
                bool isTimeChanged = slot.Date.Date != dto.Date.Date ||
                                    slot.StartTime != startTimeSpan ||
                                    slot.EndTime != endTimeSpan;

                if (isTimeChanged)
                {
                    return BadRequest(ApiResponse<bool>.ErrorResponse("Khung giờ này đã có khách hàng đặt lịch, không thể thay đổi ngày giờ (chỉ có thể điều chỉnh sức chứa)."));
                }
            }

            // Check for overlap on the target date (excluding this slot)
            var hasOverlap = await _context.TimeSlots.AnyAsync(t =>
                t.Id != id &&
                t.Date == dto.Date.Date &&
                startTimeSpan < t.EndTime &&
                t.StartTime < endTimeSpan
            );

            if (hasOverlap)
            {
                return BadRequest(ApiResponse<bool>.ErrorResponse("Khung giờ cập nhật bị trùng/đè lên một khung giờ khác đã tồn tại trong ngày đó."));
            }

            slot.Date = dto.Date.Date;
            slot.StartTime = startTimeSpan;
            slot.EndTime = endTimeSpan;
            slot.MaxCapacity = dto.MaxCapacity;

            await _context.SaveChangesAsync();

            return Ok(ApiResponse<bool>.SuccessResponse(true, "Cập nhật khung giờ thành công!"));
        }
        catch (Exception ex)
        {
            return BadRequest(ApiResponse<bool>.ErrorResponse(ex.Message));
        }
    }

    [HttpDelete("timeslots/{id}")]
    public async Task<IActionResult> DeleteTimeSlot(Guid id)
    {
        try
        {
            var slot = await _context.TimeSlots
                .Include(t => t.Bookings)
                .FirstOrDefaultAsync(t => t.Id == id);

            if (slot == null)
            {
                return NotFound(ApiResponse<bool>.ErrorResponse("Không tìm thấy khung giờ."));
            }

            if (slot.Bookings.Any())
            {
                return BadRequest(ApiResponse<bool>.ErrorResponse("Khung giờ này đã có khách hàng đặt lịch, không thể xóa vật lý."));
            }

            _context.TimeSlots.Remove(slot);
            await _context.SaveChangesAsync();

            return Ok(ApiResponse<bool>.SuccessResponse(true, "Xóa khung giờ thành công!"));
        }
        catch (Exception ex)
        {
            return BadRequest(ApiResponse<bool>.ErrorResponse(ex.Message));
        }
    }

    // ==================== REWARDS CRUD ====================
    [HttpGet("rewards")]
    public async Task<IActionResult> GetRewards()
    {
        try
        {
            var rewards = await _context.Rewards
                .OrderByDescending(r => r.CreatedAt)
                .ToListAsync();

            return Ok(ApiResponse<List<Reward>>.SuccessResponse(rewards));
        }
        catch (Exception ex)
        {
            return BadRequest(ApiResponse<List<Reward>>.ErrorResponse(ex.Message));
        }
    }

    [HttpPost("rewards")]
    public async Task<IActionResult> CreateReward([FromBody] CreateRewardDTO dto)
    {
        try
        {
            var newReward = new Reward
            {
                Name = dto.Name,
                Description = dto.Description,
                Type = (RewardType)dto.Type,
                PointsCost = dto.PointsCost,
                DiscountValue = dto.DiscountValue,
                ImageUrl = dto.ImageUrl ?? string.Empty,
                IsActive = true
            };

            _context.Rewards.Add(newReward);
            await _context.SaveChangesAsync();

            return Ok(ApiResponse<bool>.SuccessResponse(true, "Tạo quà tặng thành công!"));
        }
        catch (Exception ex)
        {
            return BadRequest(ApiResponse<bool>.ErrorResponse(ex.Message));
        }
    }

    [HttpPut("rewards/{id}")]
    public async Task<IActionResult> UpdateReward(Guid id, [FromBody] UpdateRewardDTO dto)
    {
        try
        {
            var reward = await _context.Rewards.FindAsync(id);
            if (reward == null)
            {
                return NotFound(ApiResponse<bool>.ErrorResponse("Không tìm thấy quà tặng."));
            }

            reward.Name = dto.Name;
            reward.Description = dto.Description;
            reward.Type = (RewardType)dto.Type;
            reward.PointsCost = dto.PointsCost;
            reward.DiscountValue = dto.DiscountValue;
            reward.ImageUrl = dto.ImageUrl ?? string.Empty;
            reward.IsActive = dto.IsActive;

            await _context.SaveChangesAsync();

            return Ok(ApiResponse<bool>.SuccessResponse(true, "Cập nhật quà tặng thành công!"));
        }
        catch (Exception ex)
        {
            return BadRequest(ApiResponse<bool>.ErrorResponse(ex.Message));
        }
    }

    [HttpDelete("rewards/{id}")]
    public async Task<IActionResult> DeleteReward(Guid id)
    {
        try
        {
            var reward = await _context.Rewards.FindAsync(id);
            if (reward == null)
            {
                return NotFound(ApiResponse<bool>.ErrorResponse("Không tìm thấy quà tặng."));
            }

            reward.IsActive = false;
            await _context.SaveChangesAsync();

            return Ok(ApiResponse<bool>.SuccessResponse(true, "Vô hiệu hóa quà tặng thành công!"));
        }
        catch (Exception ex)
        {
            return BadRequest(ApiResponse<bool>.ErrorResponse(ex.Message));
        }
    }

    // ==================== CHEMICALS ====================
    [HttpGet("chemicals")]
    public async Task<IActionResult> GetChemicals()
    {
        try
        {
            var chemicals = await _context.Chemicals
                .OrderBy(c => c.Name)
                .Select(c => new ChemicalDTO
                {
                    Id = c.Id,
                    Name = c.Name,
                    Unit = c.Unit,
                    CurrentStock = c.CurrentStock,
                    MinimumStock = c.MinimumStock,
                    IsLowStock = c.CurrentStock <= c.MinimumStock,
                    CreatedAt = c.CreatedAt,
                    UpdatedAt = c.UpdatedAt
                })
                .ToListAsync();

            return Ok(ApiResponse<List<ChemicalDTO>>.SuccessResponse(chemicals));
        }
        catch (Exception ex)
        {
            return BadRequest(ApiResponse<List<ChemicalDTO>>.ErrorResponse(ex.Message));
        }
    }

    [HttpPost("chemicals")]
    public async Task<IActionResult> CreateChemical([FromBody] CreateChemicalDTO dto)
    {
        try
        {
            var chemical = new Chemical
            {
                Name = dto.Name,
                Unit = dto.Unit,
                CurrentStock = dto.CurrentStock,
                MinimumStock = dto.MinimumStock,
                CreatedAt = DateTime.UtcNow,
                UpdatedAt = DateTime.UtcNow
            };

            _context.Chemicals.Add(chemical);
            await _context.SaveChangesAsync();

            return Ok(ApiResponse<bool>.SuccessResponse(true, "Thêm hóa chất thành công!"));
        }
        catch (Exception ex)
        {
            return BadRequest(ApiResponse<bool>.ErrorResponse(ex.Message));
        }
    }

    [HttpPut("chemicals/{id}")]
    public async Task<IActionResult> UpdateChemical(Guid id, [FromBody] UpdateChemicalDTO dto)
    {
        try
        {
            var chemical = await _context.Chemicals.FindAsync(id);
            if (chemical == null)
                return NotFound(ApiResponse<bool>.ErrorResponse("Không tìm thấy hóa chất."));

            chemical.Name = dto.Name;
            chemical.Unit = dto.Unit;
            chemical.MinimumStock = dto.MinimumStock;
            chemical.UpdatedAt = DateTime.UtcNow;

            await _context.SaveChangesAsync();

            return Ok(ApiResponse<bool>.SuccessResponse(true, "Cập nhật hóa chất thành công!"));
        }
        catch (Exception ex)
        {
            return BadRequest(ApiResponse<bool>.ErrorResponse(ex.Message));
        }
    }

    [HttpPost("chemicals/{id}/restock")]
    public async Task<IActionResult> RestockChemical(Guid id, [FromBody] RestockChemicalDTO dto)
    {
        try
        {
            var chemical = await _context.Chemicals.FindAsync(id);
            if (chemical == null)
                return NotFound(ApiResponse<bool>.ErrorResponse("Không tìm thấy hóa chất."));

            if (dto.Amount <= 0)
                return BadRequest(ApiResponse<bool>.ErrorResponse("Số lượng nhập phải lớn hơn 0."));

            chemical.CurrentStock += dto.Amount;
            chemical.UpdatedAt = DateTime.UtcNow;

            _context.ChemicalLogs.Add(new ChemicalLog
            {
                ChemicalId = id,
                ChangeAmount = dto.Amount,
                Reason = dto.Reason ?? "Nhập thêm hàng",
                CreatedAt = DateTime.UtcNow
            });

            await _context.SaveChangesAsync();

            return Ok(ApiResponse<bool>.SuccessResponse(true, "Nhập thêm hóa chất thành công!"));
        }
        catch (Exception ex)
        {
            return BadRequest(ApiResponse<bool>.ErrorResponse(ex.Message));
        }
    }

    [HttpGet("chemicals/{id}/logs")]
    public async Task<IActionResult> GetChemicalLogs(Guid id)
    {
        try
        {
            var chemical = await _context.Chemicals.FindAsync(id);
            if (chemical == null)
                return NotFound(ApiResponse<object>.ErrorResponse("Không tìm thấy hóa chất."));

            var logs = await _context.ChemicalLogs
                .Where(l => l.ChemicalId == id)
                .OrderByDescending(l => l.CreatedAt)
                .Select(l => new ChemicalLogDTO
                {
                    Id = l.Id,
                    ChangeAmount = l.ChangeAmount,
                    Reason = l.Reason,
                    BookingId = l.BookingId,
                    CreatedAt = l.CreatedAt
                })
                .ToListAsync();

            return Ok(ApiResponse<List<ChemicalLogDTO>>.SuccessResponse(logs));
        }
        catch (Exception ex)
        {
            return BadRequest(ApiResponse<List<ChemicalLogDTO>>.ErrorResponse(ex.Message));
        }
    }

    [HttpGet("chemicals/low-stock")]
    public async Task<IActionResult> GetLowStockChemicals()
    {
        try
        {
            var lowStock = await _context.Chemicals
                .Where(c => c.CurrentStock <= c.MinimumStock)
                .OrderBy(c => c.CurrentStock)
                .Select(c => new ChemicalDTO
                {
                    Id = c.Id,
                    Name = c.Name,
                    Unit = c.Unit,
                    CurrentStock = c.CurrentStock,
                    MinimumStock = c.MinimumStock,
                    IsLowStock = true,
                    CreatedAt = c.CreatedAt,
                    UpdatedAt = c.UpdatedAt
                })
                .ToListAsync();

            return Ok(ApiResponse<List<ChemicalDTO>>.SuccessResponse(lowStock));
        }
        catch (Exception ex)
        {
            return BadRequest(ApiResponse<List<ChemicalDTO>>.ErrorResponse(ex.Message));
        }
    }

    // ==================== SERVICE CHEMICALS ====================
    [HttpGet("services/{serviceId}/chemicals")]
    public async Task<IActionResult> GetServiceChemicals(Guid serviceId)
    {
        try
        {
            var serviceChemicals = await _context.ServiceChemicals
                .Include(sc => sc.Chemical)
                .Where(sc => sc.ServiceId == serviceId)
                .Select(sc => new ServiceChemicalDTO
                {
                    Id = sc.Id,
                    ServiceId = sc.ServiceId,
                    ChemicalId = sc.ChemicalId,
                    ChemicalName = sc.Chemical.Name,
                    Unit = sc.Chemical.Unit,
                    QuantityPerWash = sc.QuantityPerWash
                })
                .ToListAsync();

            return Ok(ApiResponse<List<ServiceChemicalDTO>>.SuccessResponse(serviceChemicals));
        }
        catch (Exception ex)
        {
            return BadRequest(ApiResponse<List<ServiceChemicalDTO>>.ErrorResponse(ex.Message));
        }
    }

    [HttpPost("services/{serviceId}/chemicals")]
    public async Task<IActionResult> AddServiceChemical(Guid serviceId, [FromBody] AddServiceChemicalDTO dto)
    {
        try
        {
            var service = await _context.Services.FindAsync(serviceId);
            if (service == null)
                return NotFound(ApiResponse<bool>.ErrorResponse("Không tìm thấy dịch vụ."));

            var chemical = await _context.Chemicals.FindAsync(dto.ChemicalId);
            if (chemical == null)
                return NotFound(ApiResponse<bool>.ErrorResponse("Không tìm thấy hóa chất."));

            var exists = await _context.ServiceChemicals.AnyAsync(sc => sc.ServiceId == serviceId && sc.ChemicalId == dto.ChemicalId);
            if (exists)
                return BadRequest(ApiResponse<bool>.ErrorResponse("Hóa chất này đã được gán cho dịch vụ."));

            var serviceChemical = new ServiceChemical
            {
                ServiceId = serviceId,
                ChemicalId = dto.ChemicalId,
                QuantityPerWash = dto.QuantityPerWash
            };

            _context.ServiceChemicals.Add(serviceChemical);
            await _context.SaveChangesAsync();

            return Ok(ApiResponse<bool>.SuccessResponse(true, "Gán hóa chất cho dịch vụ thành công!"));
        }
        catch (Exception ex)
        {
            return BadRequest(ApiResponse<bool>.ErrorResponse(ex.Message));
        }
    }

    [HttpPut("service-chemicals/{id}")]
    public async Task<IActionResult> UpdateServiceChemical(Guid id, [FromBody] UpdateServiceChemicalDTO dto)
    {
        try
        {
            var serviceChemical = await _context.ServiceChemicals.FindAsync(id);
            if (serviceChemical == null)
                return NotFound(ApiResponse<bool>.ErrorResponse("Không tìm thấy liên kết hóa chất - dịch vụ."));

            serviceChemical.QuantityPerWash = dto.QuantityPerWash;
            await _context.SaveChangesAsync();

            return Ok(ApiResponse<bool>.SuccessResponse(true, "Cập nhật lượng hóa chất thành công!"));
        }
        catch (Exception ex)
        {
            return BadRequest(ApiResponse<bool>.ErrorResponse(ex.Message));
        }
    }

    [HttpDelete("service-chemicals/{id}")]
    public async Task<IActionResult> DeleteServiceChemical(Guid id)
    {
        try
        {
            var serviceChemical = await _context.ServiceChemicals.FindAsync(id);
            if (serviceChemical == null)
                return NotFound(ApiResponse<bool>.ErrorResponse("Không tìm thấy liên kết hóa chất - dịch vụ."));

            _context.ServiceChemicals.Remove(serviceChemical);
            await _context.SaveChangesAsync();

            return Ok(ApiResponse<bool>.SuccessResponse(true, "Xóa liên kết hóa chất thành công!"));
        }
        catch (Exception ex)
        {
            return BadRequest(ApiResponse<bool>.ErrorResponse(ex.Message));
        }
    }

    // ==================== REVIEWS ====================
    [HttpGet("reviews")]
    public async Task<IActionResult> GetAllReviews()
    {
        try
        {
            var reviews = await _context.Reviews
                .Include(r => r.User)
                .Include(r => r.Booking)
                    .ThenInclude(b => b.Service)
                .OrderByDescending(r => r.CreatedAt)
                .Select(r => new AdminReviewDTO
                {
                    Id = r.Id,
                    BookingId = r.BookingId,
                    CustomerName = r.User.FullName,
                    ServiceName = r.Booking.Service.Name,
                    Rating = r.Rating,
                    Comment = r.Comment,
                    CreatedAt = r.CreatedAt
                })
                .ToListAsync();

            return Ok(ApiResponse<List<AdminReviewDTO>>.SuccessResponse(reviews));
        }
        catch (Exception ex)
        {
            return BadRequest(ApiResponse<List<AdminReviewDTO>>.ErrorResponse(ex.Message));
        }
    }

    // ==================== HELPER METHODS ====================
    private async Task DeductChemicalsForBooking(Booking booking)
    {
        var serviceChemicals = await _context.ServiceChemicals
            .Include(sc => sc.Chemical)
            .Where(sc => sc.ServiceId == booking.ServiceId)
            .ToListAsync();

        foreach (var sc in serviceChemicals)
        {
            sc.Chemical.CurrentStock -= sc.QuantityPerWash;
            sc.Chemical.UpdatedAt = DateTime.UtcNow;

            _context.ChemicalLogs.Add(new ChemicalLog
            {
                ChemicalId = sc.ChemicalId,
                ChangeAmount = -sc.QuantityPerWash,
                Reason = "Tự động trừ khi hoàn thành booking",
                BookingId = booking.Id,
                CreatedAt = DateTime.UtcNow
            });
        }
    }
}

// ==================== DTOS ====================
public class AdminStatsDTO
{
    public int TotalUsers { get; set; }
    public int TotalBookings { get; set; }
    public decimal TodayRevenue { get; set; }
    public int PendingWashes { get; set; }
}

public class AdminBookingDTO
{
    public Guid Id { get; set; }
    public string CustomerName { get; set; } = string.Empty;
    public string CustomerEmail { get; set; } = string.Empty;
    public string ServiceName { get; set; } = string.Empty;
    public string VehiclePlate { get; set; } = string.Empty;
    public DateTime BookingDate { get; set; }
    public string TimeSlotDisplay { get; set; } = string.Empty;
    public decimal TotalPrice { get; set; }
    public string Status { get; set; } = string.Empty;
    public string QrCode { get; set; } = string.Empty;
    public Guid? StaffId { get; set; }
    public string? StaffName { get; set; }
}

public class UpdateBookingStatusDTO
{
    public int Status { get; set; }
}

public class AdminUserDTO
{
    public Guid Id { get; set; }
    public string FullName { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string Phone { get; set; } = string.Empty;
    public string Tier { get; set; } = string.Empty;
    public int LoyaltyPoints { get; set; }
    public string Role { get; set; } = string.Empty;
    public DateTime CreatedAt { get; set; }
}

public class CreateStaffDTO
{
    public string FullName { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string Password { get; set; } = string.Empty;
    public string Phone { get; set; } = string.Empty;
}

public class CreateServiceDTO
{
    public string Name { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public decimal Price { get; set; }
    public int DurationMinutes { get; set; }
    public string? ImageUrl { get; set; }
}

public class UpdateServiceDTO
{
    public string Name { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public decimal Price { get; set; }
    public int DurationMinutes { get; set; }
    public string? ImageUrl { get; set; }
    public bool IsActive { get; set; }
}

public class AdminTimeSlotDTO
{
    public Guid Id { get; set; }
    public DateTime Date { get; set; }
    public string StartTime { get; set; } = string.Empty;
    public string EndTime { get; set; } = string.Empty;
    public int MaxCapacity { get; set; }
    public int BookingsCount { get; set; }
}

public class CreateTimeSlotDTO
{
    public DateTime Date { get; set; }
    public string StartTime { get; set; } = string.Empty;
    public string EndTime { get; set; } = string.Empty;
    public int MaxCapacity { get; set; }
}

public class UpdateTimeSlotDTO
{
    public DateTime Date { get; set; }
    public string StartTime { get; set; } = string.Empty;
    public string EndTime { get; set; } = string.Empty;
    public int MaxCapacity { get; set; }
}

public class CreateRewardDTO
{
    public string Name { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public int Type { get; set; }
    public int PointsCost { get; set; }
    public decimal DiscountValue { get; set; }
    public string? ImageUrl { get; set; }
}

public class UpdateRewardDTO
{
    public string Name { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public int Type { get; set; }
    public int PointsCost { get; set; }
    public decimal DiscountValue { get; set; }
    public string? ImageUrl { get; set; }
    public bool IsActive { get; set; }
}

public class AssignStaffDTO
{
    public Guid StaffId { get; set; }
}

public class StaffListDTO
{
    public Guid Id { get; set; }
    public string FullName { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string Phone { get; set; } = string.Empty;
}

public class ChemicalDTO
{
    public Guid Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Unit { get; set; } = string.Empty;
    public decimal CurrentStock { get; set; }
    public decimal MinimumStock { get; set; }
    public bool IsLowStock { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime UpdatedAt { get; set; }
}

public class CreateChemicalDTO
{
    public string Name { get; set; } = string.Empty;
    public string Unit { get; set; } = string.Empty;
    public decimal CurrentStock { get; set; }
    public decimal MinimumStock { get; set; }
}

public class UpdateChemicalDTO
{
    public string Name { get; set; } = string.Empty;
    public string Unit { get; set; } = string.Empty;
    public decimal MinimumStock { get; set; }
}

public class RestockChemicalDTO
{
    public decimal Amount { get; set; }
    public string? Reason { get; set; }
}

public class ChemicalLogDTO
{
    public Guid Id { get; set; }
    public decimal ChangeAmount { get; set; }
    public string Reason { get; set; } = string.Empty;
    public Guid? BookingId { get; set; }
    public DateTime CreatedAt { get; set; }
}

public class ServiceChemicalDTO
{
    public Guid Id { get; set; }
    public Guid ServiceId { get; set; }
    public Guid ChemicalId { get; set; }
    public string ChemicalName { get; set; } = string.Empty;
    public string Unit { get; set; } = string.Empty;
    public decimal QuantityPerWash { get; set; }
}

public class AddServiceChemicalDTO
{
    public Guid ChemicalId { get; set; }
    public decimal QuantityPerWash { get; set; }
}

public class UpdateServiceChemicalDTO
{
    public decimal QuantityPerWash { get; set; }
}

public class AdminReviewDTO
{
    public Guid Id { get; set; }
    public Guid BookingId { get; set; }
    public string CustomerName { get; set; } = string.Empty;
    public string ServiceName { get; set; } = string.Empty;
    public int Rating { get; set; }
    public string? Comment { get; set; }
    public DateTime CreatedAt { get; set; }
}

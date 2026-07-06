using AutoWashPro.Application.Common;
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
                QrCode = b.QrCode
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
            var booking = await _context.Bookings.FindAsync(id);
            if (booking == null)
            {
                return NotFound(ApiResponse<bool>.ErrorResponse("Không tìm thấy booking."));
            }

            if (!Enum.IsDefined(typeof(BookingStatus), dto.Status))
            {
                return BadRequest(ApiResponse<bool>.ErrorResponse("Trạng thái không hợp lệ."));
            }

            booking.Status = (BookingStatus)dto.Status;
            await _context.SaveChangesAsync();

            return Ok(ApiResponse<bool>.SuccessResponse(true, "Cập nhật trạng thái thành công!"));
        }
        catch (Exception ex)
        {
            return BadRequest(ApiResponse<bool>.ErrorResponse(ex.Message));
        }
    }

    [HttpGet("users")]
    public async Task<IActionResult> GetUsers()
    {
        try
        {
            var customers = await _context.Users
                .Where(u => u.Role == UserRole.Customer)
                .OrderByDescending(u => u.CreatedAt)
                .Select(u => new AdminUserDTO
                {
                    Id = u.Id,
                    FullName = u.FullName,
                    Email = u.Email,
                    Phone = u.Phone,
                    Tier = u.Tier.ToString(),
                    LoyaltyPoints = u.LoyaltyPoints,
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
}

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
    public DateTime CreatedAt { get; set; }
}

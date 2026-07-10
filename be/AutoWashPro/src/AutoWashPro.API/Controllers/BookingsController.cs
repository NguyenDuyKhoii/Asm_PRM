using System.Security.Claims;
using AutoWashPro.Application.Common;
using AutoWashPro.Application.DTOs;
using AutoWashPro.Application.Interfaces;
using AutoWashPro.Domain.Entities;
using AutoWashPro.Domain.Enums;
using AutoWashPro.Infrastructure.Data;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace AutoWashPro.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class BookingsController : ControllerBase
{
    private readonly IBookingRepository _bookingRepository;
    private readonly ApplicationDbContext _context;

    public BookingsController(IBookingRepository bookingRepository, ApplicationDbContext context)
    {
        _bookingRepository = bookingRepository;
        _context = context;
    }

    private Guid GetUserId()
    {
        var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        return Guid.Parse(userIdClaim!);
    }

    [HttpGet("available-slots")]
    public async Task<IActionResult> GetAvailableSlots([FromQuery] DateTime date, [FromQuery] Guid serviceId)
    {
        try
        {
            var slots = await _bookingRepository.GetAvailableSlotsAsync(date, serviceId);
            return Ok(ApiResponse<List<AvailableSlotDTO>>.SuccessResponse(slots));
        }
        catch (Exception ex)
        {
            return BadRequest(ApiResponse<List<AvailableSlotDTO>>.ErrorResponse(ex.Message));
        }
    }

    [HttpPost("summary")]
    public async Task<IActionResult> GetSummary([FromBody] CreateBookingDTO dto)
    {
        try
        {
            var userId = GetUserId();
            var summary = await _bookingRepository.GetBookingSummaryAsync(userId, dto);
            return Ok(ApiResponse<BookingSummaryDTO>.SuccessResponse(summary));
        }
        catch (Exception ex)
        {
            return BadRequest(ApiResponse<BookingSummaryDTO>.ErrorResponse(ex.Message));
        }
    }

    [HttpPost]
    public async Task<IActionResult> CreateBooking([FromBody] CreateBookingDTO dto)
    {
        try
        {
            var userId = GetUserId();
            var result = await _bookingRepository.CreateBookingAsync(userId, dto);
            return Ok(ApiResponse<BookingConfirmationDTO>.SuccessResponse(result, "Đặt lịch thành công!"));
        }
        catch (Exception ex)
        {
            return BadRequest(ApiResponse<BookingConfirmationDTO>.ErrorResponse(ex.Message));
        }
    }

    [HttpGet("my")]
    public async Task<IActionResult> GetMyBookings()
    {
        try
        {
            var userId = GetUserId();
            var bookings = await _bookingRepository.GetUserBookingsAsync(userId);
            return Ok(ApiResponse<List<BookingListDTO>>.SuccessResponse(bookings));
        }
        catch (Exception ex)
        {
            return BadRequest(ApiResponse<List<BookingListDTO>>.ErrorResponse(ex.Message));
        }
    }

    [HttpPut("{id}/cancel")]
    public async Task<IActionResult> CancelBooking(Guid id)
    {
        try
        {
            var userId = GetUserId();
            var result = await _bookingRepository.CancelBookingAsync(id, userId);
            if (!result)
                return NotFound(ApiResponse<bool>.ErrorResponse("Không tìm thấy hoặc không thể hủy booking."));

            return Ok(ApiResponse<bool>.SuccessResponse(true, "Hủy booking thành công!"));
        }
        catch (Exception ex)
        {
            return BadRequest(ApiResponse<bool>.ErrorResponse(ex.Message));
        }
    }

    [HttpGet("today")]
    public async Task<IActionResult> GetTodayBookings()
    {
        try
        {
            var today = DateTime.UtcNow;
            var bookings = await _bookingRepository.GetTodayBookingsAsync(today);
            return Ok(ApiResponse<List<BookingListDTO>>.SuccessResponse(bookings));
        }
        catch (Exception ex)
        {
            return BadRequest(ApiResponse<List<BookingListDTO>>.ErrorResponse(ex.Message));
        }
    }

    [HttpPut("{id}/status")]
    public async Task<IActionResult> UpdateBookingStatus(Guid id, [FromBody] int newStatus)
    {
        try
        {
            var result = await _bookingRepository.UpdateStatusAsync(id, newStatus);
            if (!result)
                return NotFound(ApiResponse<bool>.ErrorResponse("Không tìm thấy hoặc không thể cập nhật trạng thái booking."));

            return Ok(ApiResponse<bool>.SuccessResponse(true, "Cập nhật trạng thái thành công!"));
        }
        catch (Exception ex)
        {
            return BadRequest(ApiResponse<bool>.ErrorResponse(ex.Message));
        }
    }

    [HttpPut("{id}/claim")]
    [Authorize(Roles = "Staff,Admin")]
    public async Task<IActionResult> ClaimBooking(Guid id)
    {
        try
        {
            var userId = GetUserId();
            var result = await _bookingRepository.ClaimBookingAsync(id, userId);
            if (!result)
                return BadRequest(ApiResponse<bool>.ErrorResponse("Không thể nhận xe (xe đã được nhận hoặc không tồn tại)."));

            return Ok(ApiResponse<bool>.SuccessResponse(true, "Nhận việc thành công!"));
        }
        catch (Exception ex)
        {
            return BadRequest(ApiResponse<bool>.ErrorResponse(ex.Message));
        }
    }

    [HttpPut("{id}/checklist")]
    [Authorize(Roles = "Staff,Admin")]
    public async Task<IActionResult> UpdateChecklist(Guid id, [FromBody] string checklistJson)
    {
        try
        {
            var result = await _bookingRepository.UpdateChecklistAsync(id, checklistJson);
            if (!result)
                return NotFound(ApiResponse<bool>.ErrorResponse("Không tìm thấy booking."));

            return Ok(ApiResponse<bool>.SuccessResponse(true, "Cập nhật danh sách kiểm tra thành công!"));
        }
        catch (Exception ex)
        {
            return BadRequest(ApiResponse<bool>.ErrorResponse(ex.Message));
        }
    }

    [HttpPut("{id}/complete")]
    [Authorize(Roles = "Staff,Admin")]
    public async Task<IActionResult> CompleteBooking(Guid id, [FromBody] string imageUrl)
    {
        try
        {
            var result = await _bookingRepository.CompleteBookingAsync(id, imageUrl);
            if (!result)
                return NotFound(ApiResponse<bool>.ErrorResponse("Không tìm thấy booking."));

            var lowStockWarnings = await _bookingRepository.GetLowStockWarningsAsync();
            if (lowStockWarnings.Any())
            {
                return Ok(ApiResponse<object>.SuccessResponse(new
                {
                    Completed = true,
                    LowStockWarnings = lowStockWarnings
                }, "Hoàn thành công việc thành công! Cảnh báo: một số hóa chất sắp hết."));
            }

            return Ok(ApiResponse<bool>.SuccessResponse(true, "Hoàn thành công việc thành công!"));
        }
        catch (Exception ex)
        {
            return BadRequest(ApiResponse<bool>.ErrorResponse(ex.Message));
        }
    }

    [HttpGet("staff-stats")]
    [Authorize(Roles = "Staff,Admin")]
    public async Task<IActionResult> GetStaffStats()
    {
        try
        {
            var userId = GetUserId();
            var stats = await _bookingRepository.GetStaffStatsAsync(userId);
            return Ok(ApiResponse<object>.SuccessResponse(stats));
        }
        catch (Exception ex)
        {
            return BadRequest(ApiResponse<object>.ErrorResponse(ex.Message));
        }
    }

    // ==================== REVIEWS ====================
    [HttpPost("{id}/review")]
    public async Task<IActionResult> CreateReview(Guid id, [FromBody] CreateReviewDTO dto)
    {
        try
        {
            var userId = GetUserId();
            var booking = await _context.Bookings.FirstOrDefaultAsync(b => b.Id == id);
            if (booking == null)
                return NotFound(ApiResponse<bool>.ErrorResponse("Không tìm thấy booking."));

            if (booking.UserId != userId)
                return BadRequest(ApiResponse<bool>.ErrorResponse("Bạn không có quyền đánh giá booking này."));

            if (booking.Status != BookingStatus.Completed)
                return BadRequest(ApiResponse<bool>.ErrorResponse("Chỉ có thể đánh giá booking đã hoàn thành."));

            var existingReview = await _context.Reviews.AnyAsync(r => r.BookingId == id);
            if (existingReview)
                return BadRequest(ApiResponse<bool>.ErrorResponse("Booking này đã được đánh giá rồi."));

            if (dto.Rating < 1 || dto.Rating > 5)
                return BadRequest(ApiResponse<bool>.ErrorResponse("Đánh giá phải từ 1 đến 5 sao."));

            var review = new Review
            {
                BookingId = id,
                UserId = userId,
                Rating = dto.Rating,
                Comment = dto.Comment,
                CreatedAt = DateTime.UtcNow
            };

            _context.Reviews.Add(review);
            await _context.SaveChangesAsync();

            return Ok(ApiResponse<bool>.SuccessResponse(true, "Đánh giá thành công!"));
        }
        catch (Exception ex)
        {
            return BadRequest(ApiResponse<bool>.ErrorResponse(ex.Message));
        }
    }

    [HttpGet("{id}/review")]
    public async Task<IActionResult> GetReview(Guid id)
    {
        try
        {
            var userId = GetUserId();
            var review = await _context.Reviews
                .Include(r => r.User)
                .FirstOrDefaultAsync(r => r.BookingId == id);

            if (review == null)
                return NotFound(ApiResponse<object>.ErrorResponse("Chưa có đánh giá cho booking này."));

            if (review.UserId != userId)
                return BadRequest(ApiResponse<object>.ErrorResponse("Bạn không có quyền xem đánh giá này."));

            var result = new ReviewDTO
            {
                Id = review.Id,
                BookingId = review.BookingId,
                Rating = review.Rating,
                Comment = review.Comment,
                CustomerName = review.User.FullName,
                CreatedAt = review.CreatedAt
            };

            return Ok(ApiResponse<ReviewDTO>.SuccessResponse(result));
        }
        catch (Exception ex)
        {
            return BadRequest(ApiResponse<object>.ErrorResponse(ex.Message));
        }
    }
}

// ==================== BOOKING REVIEW DTOS ====================
public class CreateReviewDTO
{
    public int Rating { get; set; }
    public string? Comment { get; set; }
}

public class ReviewDTO
{
    public Guid Id { get; set; }
    public Guid BookingId { get; set; }
    public int Rating { get; set; }
    public string? Comment { get; set; }
    public string CustomerName { get; set; } = string.Empty;
    public DateTime CreatedAt { get; set; }
}

using System.Security.Claims;
using AutoWashPro.Application.Common;
using AutoWashPro.Application.DTOs;
using AutoWashPro.Application.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace AutoWashPro.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class BookingsController : ControllerBase
{
    private readonly IBookingRepository _bookingRepository;

    public BookingsController(IBookingRepository bookingRepository)
    {
        _bookingRepository = bookingRepository;
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
}

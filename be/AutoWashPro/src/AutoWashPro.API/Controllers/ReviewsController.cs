using AutoWashPro.Application.Common;
using AutoWashPro.Infrastructure.Data;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace AutoWashPro.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class ReviewsController : ControllerBase
{
    private readonly ApplicationDbContext _context;

    public ReviewsController(ApplicationDbContext context)
    {
        _context = context;
    }

    [HttpGet("service/{serviceId}")]
    public async Task<IActionResult> GetServiceReviews(Guid serviceId)
    {
        try
        {
            var reviews = await _context.Reviews
                .Include(r => r.Booking)
                .Include(r => r.User)
                .Where(r => r.Booking.ServiceId == serviceId)
                .OrderByDescending(r => r.CreatedAt)
                .Select(r => new ServiceReviewDTO
                {
                    Id = r.Id,
                    Rating = r.Rating,
                    Comment = r.Comment,
                    CustomerName = r.User.FullName,
                    CreatedAt = r.CreatedAt
                })
                .ToListAsync();

            var averageRating = reviews.Any() ? Math.Round(reviews.Average(r => r.Rating), 1) : 0;

            var result = new ServiceReviewsResultDTO
            {
                ServiceId = serviceId,
                AverageRating = averageRating,
                TotalReviews = reviews.Count,
                Reviews = reviews
            };

            return Ok(ApiResponse<ServiceReviewsResultDTO>.SuccessResponse(result));
        }
        catch (Exception ex)
        {
            return BadRequest(ApiResponse<ServiceReviewsResultDTO>.ErrorResponse(ex.Message));
        }
    }
}

// ==================== DTOS ====================
public class ServiceReviewDTO
{
    public Guid Id { get; set; }
    public int Rating { get; set; }
    public string? Comment { get; set; }
    public string CustomerName { get; set; } = string.Empty;
    public DateTime CreatedAt { get; set; }
}

public class ServiceReviewsResultDTO
{
    public Guid ServiceId { get; set; }
    public double AverageRating { get; set; }
    public int TotalReviews { get; set; }
    public List<ServiceReviewDTO> Reviews { get; set; } = new();
}

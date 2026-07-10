using AutoWashPro.Application.DTOs;

namespace AutoWashPro.Application.Interfaces;

public interface IBookingRepository
{
    Task<List<AvailableSlotDTO>> GetAvailableSlotsAsync(DateTime date, Guid serviceId);
    Task<BookingConfirmationDTO> CreateBookingAsync(Guid userId, CreateBookingDTO dto);
    Task<BookingSummaryDTO> GetBookingSummaryAsync(Guid userId, CreateBookingDTO dto);
    Task<List<BookingListDTO>> GetUserBookingsAsync(Guid userId);
    Task<bool> CancelBookingAsync(Guid bookingId, Guid userId);
    Task<List<BookingListDTO>> GetTodayBookingsAsync(DateTime today);
    Task<bool> UpdateStatusAsync(Guid bookingId, int newStatus);
    Task<bool> ClaimBookingAsync(Guid bookingId, Guid staffId);
    Task<bool> UpdateChecklistAsync(Guid bookingId, string checklistJson);
    Task<bool> CompleteBookingAsync(Guid bookingId, string imageUrl);
    Task<object> GetStaffStatsAsync(Guid staffId);
    Task<List<LowStockWarningDTO>> GetLowStockWarningsAsync();
}

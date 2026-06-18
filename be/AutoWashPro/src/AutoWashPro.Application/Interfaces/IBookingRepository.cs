using AutoWashPro.Application.DTOs;

namespace AutoWashPro.Application.Interfaces;

public interface IBookingRepository
{
    Task<List<AvailableSlotDTO>> GetAvailableSlotsAsync(DateTime date, Guid serviceId);
    Task<BookingConfirmationDTO> CreateBookingAsync(Guid userId, CreateBookingDTO dto);
    Task<BookingSummaryDTO> GetBookingSummaryAsync(Guid userId, CreateBookingDTO dto);
    Task<List<BookingListDTO>> GetUserBookingsAsync(Guid userId);
    Task<bool> CancelBookingAsync(Guid bookingId, Guid userId);
}

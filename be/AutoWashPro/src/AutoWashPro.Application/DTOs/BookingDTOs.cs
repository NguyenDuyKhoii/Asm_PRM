using AutoWashPro.Domain.Enums;

namespace AutoWashPro.Application.DTOs;

public class CreateBookingDTO
{
    public Guid ServiceId { get; set; }
    public Guid VehicleId { get; set; }
    public DateTime BookingDate { get; set; }
    public Guid TimeSlotId { get; set; }
    public Guid? VoucherId { get; set; }
}

public class BookingSummaryDTO
{
    public Guid ServiceId { get; set; }
    public string ServiceName { get; set; } = string.Empty;
    public Guid VehicleId { get; set; }
    public string VehiclePlate { get; set; } = string.Empty;
    public string VehicleTypeName { get; set; } = string.Empty;
    public DateTime BookingDate { get; set; }
    public string TimeSlotDisplay { get; set; } = string.Empty;
    public decimal OriginalPrice { get; set; }
    public decimal DiscountPercentage { get; set; }
    public decimal DiscountAmount { get; set; }
    public decimal VoucherDiscountAmount { get; set; }
    public string? VoucherCode { get; set; }
    public decimal FinalPrice { get; set; }
    public string TierName { get; set; } = string.Empty;
    public string PerkApplied { get; set; } = string.Empty;
}

public class BookingConfirmationDTO
{
    public Guid BookingId { get; set; }
    public string QrCode { get; set; } = string.Empty;
    public string Status { get; set; } = string.Empty;
    public string ServiceName { get; set; } = string.Empty;
    public string VehiclePlate { get; set; } = string.Empty;
    public DateTime BookingDate { get; set; }
    public string TimeSlotDisplay { get; set; } = string.Empty;
    public decimal TotalPrice { get; set; }
}

public class BookingListDTO
{
    public Guid Id { get; set; }
    public string ServiceName { get; set; } = string.Empty;
    public string VehiclePlate { get; set; } = string.Empty;
    public DateTime BookingDate { get; set; }
    public string TimeSlotDisplay { get; set; } = string.Empty;
    public decimal TotalPrice { get; set; }
    public string Status { get; set; } = string.Empty;
    public string QrCode { get; set; } = string.Empty;
}

public class AvailableSlotDTO
{
    public Guid TimeSlotId { get; set; }
    public string StartTime { get; set; } = string.Empty;
    public string EndTime { get; set; } = string.Empty;
    public bool IsAvailable { get; set; }
    public int RemainingCapacity { get; set; }
}

public class UserTierDTO
{
    public string TierName { get; set; } = string.Empty;
    public int TierLevel { get; set; }
    public int MaxBookingDays { get; set; }
    public decimal DiscountPercentage { get; set; }
    public int LoyaltyPoints { get; set; }
}

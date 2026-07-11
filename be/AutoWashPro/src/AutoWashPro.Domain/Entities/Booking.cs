using AutoWashPro.Domain.Enums;

namespace AutoWashPro.Domain.Entities;

public class Booking
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public Guid UserId { get; set; }
    public Guid ServiceId { get; set; }
    public Guid VehicleId { get; set; }
    public DateTime BookingDate { get; set; }
    public Guid TimeSlotId { get; set; }
    public decimal TotalPrice { get; set; }
    public decimal DiscountAmount { get; set; }
    public BookingStatus Status { get; set; } = BookingStatus.Pending;
    public string QrCode { get; set; } = string.Empty;
    public Guid? StaffId { get; set; }
    public string? Checklist { get; set; } // JSON format
    public string? CompletionImageUrl { get; set; }
    public DateTime? CompletedAt { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    // Navigation properties
    public User User { get; set; } = null!;
    public Service Service { get; set; } = null!;
    public Vehicle Vehicle { get; set; } = null!;
    public TimeSlot TimeSlot { get; set; } = null!;
    public Review? Review { get; set; }
    public ICollection<ChemicalLog> ChemicalLogs { get; set; } = new List<ChemicalLog>();
}

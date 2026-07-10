namespace AutoWashPro.Domain.Entities;

public class ChemicalLog
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public Guid ChemicalId { get; set; }
    public decimal ChangeAmount { get; set; }
    public string Reason { get; set; } = string.Empty;
    public Guid? BookingId { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    // Navigation properties
    public Chemical Chemical { get; set; } = null!;
    public Booking? Booking { get; set; }
}

namespace AutoWashPro.Domain.Entities;

public class TimeSlot
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public TimeSpan StartTime { get; set; }
    public TimeSpan EndTime { get; set; }
    public int MaxCapacity { get; set; } = 3;
    public DateTime Date { get; set; }

    // Navigation properties
    public ICollection<Booking> Bookings { get; set; } = new List<Booking>();
}

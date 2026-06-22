using AutoWashPro.Domain.Enums;

namespace AutoWashPro.Domain.Entities;

public class Reward
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public string Name { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public RewardType Type { get; set; }
    public int PointsCost { get; set; }
    public decimal DiscountValue { get; set; }
    public string ImageUrl { get; set; } = string.Empty;
    public bool IsActive { get; set; } = true;
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    // Navigation properties
    public ICollection<Voucher> Vouchers { get; set; } = new List<Voucher>();
}

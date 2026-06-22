using AutoWashPro.Domain.Enums;

namespace AutoWashPro.Application.DTOs;

public class RewardDTO
{
    public Guid Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public string Type { get; set; } = string.Empty;
    public int PointsCost { get; set; }
    public decimal DiscountValue { get; set; }
    public string ImageUrl { get; set; } = string.Empty;
    public bool CanRedeem { get; set; }
}

public class RedeemRewardDTO
{
    public Guid RewardId { get; set; }
}

public class VoucherDTO
{
    public Guid Id { get; set; }
    public string Code { get; set; } = string.Empty;
    public string RewardName { get; set; } = string.Empty;
    public string RewardType { get; set; } = string.Empty;
    public decimal DiscountValue { get; set; }
    public bool IsUsed { get; set; }
    public DateTime ExpiryDate { get; set; }
    public DateTime CreatedAt { get; set; }
}

public class RedeemResultDTO
{
    public Guid VoucherId { get; set; }
    public string VoucherCode { get; set; } = string.Empty;
    public string RewardName { get; set; } = string.Empty;
    public int PointsSpent { get; set; }
    public int RemainingPoints { get; set; }
    public DateTime ExpiryDate { get; set; }
}

public class LoyaltyHomeDTO
{
    public string TierName { get; set; } = string.Empty;
    public int TierLevel { get; set; }
    public int LoyaltyPoints { get; set; }
    public int MaxBookingDays { get; set; }
    public decimal DiscountPercentage { get; set; }
    public int PointsToNextTier { get; set; }
    public string NextTierName { get; set; } = string.Empty;
    public int ExpiringPoints { get; set; }
    public DateTime? PointsExpiryDate { get; set; }
    public int TotalVouchers { get; set; }
}

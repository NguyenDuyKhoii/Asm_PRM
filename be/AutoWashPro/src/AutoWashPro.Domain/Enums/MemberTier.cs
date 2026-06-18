namespace AutoWashPro.Domain.Enums;

public enum MemberTier
{
    Member = 0,
    Silver = 1,
    Gold = 2,
    Platinum = 3
}

public static class MemberTierExtensions
{
    public static int GetMaxBookingDays(this MemberTier tier) => tier switch
    {
        MemberTier.Member => 7,
        MemberTier.Silver => 10,
        MemberTier.Gold => 12,
        MemberTier.Platinum => 14,
        _ => 7
    };

    public static decimal GetDiscountPercentage(this MemberTier tier) => tier switch
    {
        MemberTier.Member => 0m,
        MemberTier.Silver => 5m,
        MemberTier.Gold => 10m,
        MemberTier.Platinum => 15m,
        _ => 0m
    };

    public static string GetTierName(this MemberTier tier) => tier switch
    {
        MemberTier.Member => "Member",
        MemberTier.Silver => "Silver",
        MemberTier.Gold => "Gold",
        MemberTier.Platinum => "Platinum",
        _ => "Member"
    };
}

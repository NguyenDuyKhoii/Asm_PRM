using AutoWashPro.Application.DTOs;
using AutoWashPro.Application.Interfaces;
using AutoWashPro.Domain.Entities;
using AutoWashPro.Domain.Enums;
using AutoWashPro.Infrastructure.Data;
using Microsoft.EntityFrameworkCore;

namespace AutoWashPro.Infrastructure.Repositories;

public class RewardRepository : IRewardRepository
{
    private readonly ApplicationDbContext _context;

    public RewardRepository(ApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<List<RewardDTO>> GetRewardsAsync(Guid userId)
    {
        var user = await _context.Users.FindAsync(userId)
            ?? throw new Exception("Không tìm thấy người dùng.");

        var rewards = await _context.Rewards
            .Where(r => r.IsActive)
            .OrderBy(r => r.PointsCost)
            .ToListAsync();

        return rewards.Select(r => new RewardDTO
        {
            Id = r.Id,
            Name = r.Name,
            Description = r.Description,
            Type = r.Type.ToString(),
            PointsCost = r.PointsCost,
            DiscountValue = r.DiscountValue,
            ImageUrl = r.ImageUrl,
            CanRedeem = user.LoyaltyPoints >= r.PointsCost
        }).ToList();
    }

    public async Task<RedeemResultDTO> RedeemRewardAsync(Guid userId, Guid rewardId)
    {
        var user = await _context.Users.FindAsync(userId)
            ?? throw new Exception("Không tìm thấy người dùng.");

        var reward = await _context.Rewards.FindAsync(rewardId)
            ?? throw new Exception("Không tìm thấy phần thưởng.");

        if (!reward.IsActive)
            throw new Exception("Phần thưởng này hiện không khả dụng.");

        if (user.LoyaltyPoints < reward.PointsCost)
            throw new Exception($"Bạn cần {reward.PointsCost} điểm để đổi phần thưởng này. Hiện tại bạn có {user.LoyaltyPoints} điểm.");

        // Deduct points
        user.LoyaltyPoints -= reward.PointsCost;

        // Generate voucher code
        var voucherCode = $"AW-{DateTime.UtcNow:yyyyMMdd}-{Guid.NewGuid().ToString()[..8].ToUpper()}";

        var voucher = new Voucher
        {
            Id = Guid.NewGuid(),
            UserId = userId,
            RewardId = rewardId,
            Code = voucherCode,
            IsUsed = false,
            ExpiryDate = DateTime.UtcNow.AddDays(30),
            CreatedAt = DateTime.UtcNow
        };

        _context.Vouchers.Add(voucher);
        await _context.SaveChangesAsync();

        return new RedeemResultDTO
        {
            VoucherId = voucher.Id,
            VoucherCode = voucher.Code,
            RewardName = reward.Name,
            PointsSpent = reward.PointsCost,
            RemainingPoints = user.LoyaltyPoints,
            ExpiryDate = voucher.ExpiryDate
        };
    }

    public async Task<List<VoucherDTO>> GetUserVouchersAsync(Guid userId)
    {
        return await _context.Vouchers
            .Where(v => v.UserId == userId)
            .Include(v => v.Reward)
            .OrderByDescending(v => v.CreatedAt)
            .Select(v => new VoucherDTO
            {
                Id = v.Id,
                Code = v.Code,
                RewardName = v.Reward.Name,
                RewardType = v.Reward.Type.ToString(),
                DiscountValue = v.Reward.DiscountValue,
                IsUsed = v.IsUsed,
                ExpiryDate = v.ExpiryDate,
                CreatedAt = v.CreatedAt
            })
            .ToListAsync();
    }

    public async Task<LoyaltyHomeDTO> GetLoyaltyHomeAsync(Guid userId)
    {
        var user = await _context.Users.FindAsync(userId)
            ?? throw new Exception("Không tìm thấy người dùng.");

        var totalVouchers = await _context.Vouchers
            .CountAsync(v => v.UserId == userId && !v.IsUsed && v.ExpiryDate > DateTime.UtcNow);

        // Calculate points to next tier
        int pointsToNextTier = 0;
        string nextTierName = "";
        switch (user.Tier)
        {
            case MemberTier.Member:
                pointsToNextTier = 200 - user.LoyaltyPoints;
                nextTierName = "Silver";
                break;
            case MemberTier.Silver:
                pointsToNextTier = 500 - user.LoyaltyPoints;
                nextTierName = "Gold";
                break;
            case MemberTier.Gold:
                pointsToNextTier = 1000 - user.LoyaltyPoints;
                nextTierName = "Platinum";
                break;
            case MemberTier.Platinum:
                pointsToNextTier = 0;
                nextTierName = "Platinum (Max)";
                break;
        }
        if (pointsToNextTier < 0) pointsToNextTier = 0;

        return new LoyaltyHomeDTO
        {
            TierName = user.Tier.GetTierName(),
            TierLevel = (int)user.Tier,
            LoyaltyPoints = user.LoyaltyPoints,
            MaxBookingDays = user.Tier.GetMaxBookingDays(),
            DiscountPercentage = user.Tier.GetDiscountPercentage(),
            PointsToNextTier = pointsToNextTier,
            NextTierName = nextTierName,
            ExpiringPoints = 0, // Simplified — no partial expiry tracking
            PointsExpiryDate = DateTime.UtcNow.AddMonths(6),
            TotalVouchers = totalVouchers
        };
    }
}

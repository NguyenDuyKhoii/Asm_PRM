using AutoWashPro.Application.DTOs;

namespace AutoWashPro.Application.Interfaces;

public interface IRewardRepository
{
    Task<List<RewardDTO>> GetRewardsAsync(Guid userId);
    Task<RedeemResultDTO> RedeemRewardAsync(Guid userId, Guid rewardId);
    Task<List<VoucherDTO>> GetUserVouchersAsync(Guid userId);
    Task<LoyaltyHomeDTO> GetLoyaltyHomeAsync(Guid userId);
}

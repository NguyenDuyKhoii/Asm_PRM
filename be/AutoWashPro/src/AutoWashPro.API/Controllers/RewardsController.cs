using System.Security.Claims;
using AutoWashPro.Application.Common;
using AutoWashPro.Application.DTOs;
using AutoWashPro.Application.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace AutoWashPro.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class RewardsController : ControllerBase
{
    private readonly IRewardRepository _rewardRepository;

    public RewardsController(IRewardRepository rewardRepository)
    {
        _rewardRepository = rewardRepository;
    }

    private Guid GetUserId()
    {
        var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        return Guid.Parse(userIdClaim!);
    }

    [HttpGet("loyalty")]
    public async Task<IActionResult> GetLoyaltyHome()
    {
        try
        {
            var userId = GetUserId();
            var loyalty = await _rewardRepository.GetLoyaltyHomeAsync(userId);
            return Ok(ApiResponse<LoyaltyHomeDTO>.SuccessResponse(loyalty));
        }
        catch (Exception ex)
        {
            return BadRequest(ApiResponse<LoyaltyHomeDTO>.ErrorResponse(ex.Message));
        }
    }

    [HttpGet]
    public async Task<IActionResult> GetRewards()
    {
        try
        {
            var userId = GetUserId();
            var rewards = await _rewardRepository.GetRewardsAsync(userId);
            return Ok(ApiResponse<List<RewardDTO>>.SuccessResponse(rewards));
        }
        catch (Exception ex)
        {
            return BadRequest(ApiResponse<List<RewardDTO>>.ErrorResponse(ex.Message));
        }
    }

    [HttpPost("redeem")]
    public async Task<IActionResult> RedeemReward([FromBody] RedeemRewardDTO dto)
    {
        try
        {
            var userId = GetUserId();
            var result = await _rewardRepository.RedeemRewardAsync(userId, dto.RewardId);
            return Ok(ApiResponse<RedeemResultDTO>.SuccessResponse(result, "Đổi thưởng thành công!"));
        }
        catch (Exception ex)
        {
            return BadRequest(ApiResponse<RedeemResultDTO>.ErrorResponse(ex.Message));
        }
    }

    [HttpGet("vouchers")]
    public async Task<IActionResult> GetMyVouchers()
    {
        try
        {
            var userId = GetUserId();
            var vouchers = await _rewardRepository.GetUserVouchersAsync(userId);
            return Ok(ApiResponse<List<VoucherDTO>>.SuccessResponse(vouchers));
        }
        catch (Exception ex)
        {
            return BadRequest(ApiResponse<List<VoucherDTO>>.ErrorResponse(ex.Message));
        }
    }
}

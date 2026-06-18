using AutoWashPro.Application.DTOs;
using AutoWashPro.Application.Interfaces;
using AutoWashPro.Domain.Enums;
using AutoWashPro.Infrastructure.Data;
using Microsoft.EntityFrameworkCore;

namespace AutoWashPro.Infrastructure.Repositories;

public class UserRepository : IUserRepository
{
    private readonly ApplicationDbContext _context;

    public UserRepository(ApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<UserTierDTO> GetUserTierAsync(Guid userId)
    {
        var user = await _context.Users.FindAsync(userId)
            ?? throw new Exception("Không tìm thấy người dùng.");

        return new UserTierDTO
        {
            TierName = user.Tier.GetTierName(),
            TierLevel = (int)user.Tier,
            MaxBookingDays = user.Tier.GetMaxBookingDays(),
            DiscountPercentage = user.Tier.GetDiscountPercentage(),
            LoyaltyPoints = user.LoyaltyPoints
        };
    }
}

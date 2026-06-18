using AutoWashPro.Application.DTOs;

namespace AutoWashPro.Application.Interfaces;

public interface IUserRepository
{
    Task<UserTierDTO> GetUserTierAsync(Guid userId);
}

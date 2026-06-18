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
public class UsersController : ControllerBase
{
    private readonly IUserRepository _userRepository;

    public UsersController(IUserRepository userRepository)
    {
        _userRepository = userRepository;
    }

    private Guid GetUserId()
    {
        var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        return Guid.Parse(userIdClaim!);
    }

    [HttpGet("tier")]
    public async Task<IActionResult> GetTier()
    {
        try
        {
            var userId = GetUserId();
            var tier = await _userRepository.GetUserTierAsync(userId);
            return Ok(ApiResponse<UserTierDTO>.SuccessResponse(tier));
        }
        catch (Exception ex)
        {
            return BadRequest(ApiResponse<UserTierDTO>.ErrorResponse(ex.Message));
        }
    }
}

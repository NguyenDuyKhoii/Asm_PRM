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
public class VehiclesController : ControllerBase
{
    private readonly IVehicleRepository _vehicleRepository;

    public VehiclesController(IVehicleRepository vehicleRepository)
    {
        _vehicleRepository = vehicleRepository;
    }

    private Guid GetUserId()
    {
        var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        return Guid.Parse(userIdClaim!);
    }

    [HttpGet]
    public async Task<IActionResult> GetMyVehicles()
    {
        try
        {
            var userId = GetUserId();
            var vehicles = await _vehicleRepository.GetUserVehiclesAsync(userId);
            return Ok(ApiResponse<List<VehicleDTO>>.SuccessResponse(vehicles));
        }
        catch (Exception ex)
        {
            return BadRequest(ApiResponse<List<VehicleDTO>>.ErrorResponse(ex.Message));
        }
    }

    [HttpPost]
    public async Task<IActionResult> AddVehicle([FromBody] CreateVehicleDTO dto)
    {
        try
        {
            var userId = GetUserId();
            var vehicle = await _vehicleRepository.AddVehicleAsync(userId, dto);
            return Ok(ApiResponse<VehicleDTO>.SuccessResponse(vehicle, "Thêm xe thành công!"));
        }
        catch (Exception ex)
        {
            return BadRequest(ApiResponse<VehicleDTO>.ErrorResponse(ex.Message));
        }
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> DeleteVehicle(Guid id)
    {
        try
        {
            var userId = GetUserId();
            var result = await _vehicleRepository.DeleteVehicleAsync(id, userId);
            if (!result)
                return NotFound(ApiResponse<bool>.ErrorResponse("Không tìm thấy xe."));

            return Ok(ApiResponse<bool>.SuccessResponse(true, "Xóa xe thành công!"));
        }
        catch (Exception ex)
        {
            return BadRequest(ApiResponse<bool>.ErrorResponse(ex.Message));
        }
    }
}

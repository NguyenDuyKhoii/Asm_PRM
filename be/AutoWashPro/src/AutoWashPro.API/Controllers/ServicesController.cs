using AutoWashPro.Application.Common;
using AutoWashPro.Application.DTOs;
using AutoWashPro.Application.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace AutoWashPro.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class ServicesController : ControllerBase
{
    private readonly IServiceRepository _serviceRepository;

    public ServicesController(IServiceRepository serviceRepository)
    {
        _serviceRepository = serviceRepository;
    }

    [HttpGet]
    public async Task<IActionResult> GetAll()
    {
        var services = await _serviceRepository.GetAllServicesAsync();
        return Ok(ApiResponse<List<ServiceDTO>>.SuccessResponse(services));
    }

    [HttpGet("{id}")]
    public async Task<IActionResult> GetById(Guid id)
    {
        var service = await _serviceRepository.GetServiceByIdAsync(id);
        if (service == null)
            return NotFound(ApiResponse<ServiceDTO>.ErrorResponse("Không tìm thấy dịch vụ."));

        return Ok(ApiResponse<ServiceDTO>.SuccessResponse(service));
    }
}

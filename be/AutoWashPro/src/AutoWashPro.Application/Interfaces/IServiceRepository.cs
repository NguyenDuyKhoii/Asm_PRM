using AutoWashPro.Application.DTOs;

namespace AutoWashPro.Application.Interfaces;

public interface IServiceRepository
{
    Task<List<ServiceDTO>> GetAllServicesAsync();
    Task<ServiceDTO?> GetServiceByIdAsync(Guid id);
}

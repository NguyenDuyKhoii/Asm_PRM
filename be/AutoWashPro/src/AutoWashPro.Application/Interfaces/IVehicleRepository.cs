using AutoWashPro.Application.DTOs;

namespace AutoWashPro.Application.Interfaces;

public interface IVehicleRepository
{
    Task<List<VehicleDTO>> GetUserVehiclesAsync(Guid userId);
    Task<VehicleDTO> AddVehicleAsync(Guid userId, CreateVehicleDTO dto);
    Task<bool> DeleteVehicleAsync(Guid vehicleId, Guid userId);
}

using AutoWashPro.Application.DTOs;
using AutoWashPro.Application.Interfaces;
using AutoWashPro.Domain.Entities;
using AutoWashPro.Domain.Enums;
using AutoWashPro.Infrastructure.Data;
using Microsoft.EntityFrameworkCore;

namespace AutoWashPro.Infrastructure.Repositories;

public class VehicleRepository : IVehicleRepository
{
    private readonly ApplicationDbContext _context;

    public VehicleRepository(ApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<List<VehicleDTO>> GetUserVehiclesAsync(Guid userId)
    {
        return await _context.Vehicles
            .Where(v => v.UserId == userId)
            .Select(v => new VehicleDTO
            {
                Id = v.Id,
                LicensePlate = v.LicensePlate,
                VehicleType = v.VehicleType,
                VehicleTypeName = v.VehicleType == VehicleType.Car ? "Ô tô" : "Xe máy",
                Name = v.Name,
                Color = v.Color,
                ImageUrl = v.ImageUrl
            })
            .ToListAsync();
    }

    public async Task<VehicleDTO> AddVehicleAsync(Guid userId, CreateVehicleDTO dto)
    {
        // Check duplicate license plate
        if (await _context.Vehicles.AnyAsync(v => v.LicensePlate == dto.LicensePlate))
            throw new Exception("Biển số xe đã được đăng ký.");

        var vehicle = new Vehicle
        {
            UserId = userId,
            LicensePlate = dto.LicensePlate,
            VehicleType = dto.VehicleType,
            Name = dto.Name,
            Color = dto.Color,
            ImageUrl = dto.ImageUrl,
            CreatedAt = DateTime.UtcNow
        };

        _context.Vehicles.Add(vehicle);
        await _context.SaveChangesAsync();

        return new VehicleDTO
        {
            Id = vehicle.Id,
            LicensePlate = vehicle.LicensePlate,
            VehicleType = vehicle.VehicleType,
            VehicleTypeName = vehicle.VehicleType == VehicleType.Car ? "Ô tô" : "Xe máy",
            Name = vehicle.Name,
            Color = vehicle.Color,
            ImageUrl = vehicle.ImageUrl
        };
    }

    public async Task<bool> DeleteVehicleAsync(Guid vehicleId, Guid userId)
    {
        var vehicle = await _context.Vehicles
            .FirstOrDefaultAsync(v => v.Id == vehicleId && v.UserId == userId);

        if (vehicle == null) return false;

        _context.Vehicles.Remove(vehicle);
        await _context.SaveChangesAsync();
        return true;
    }
}

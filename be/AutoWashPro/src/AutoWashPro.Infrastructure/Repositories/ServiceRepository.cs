using AutoWashPro.Application.DTOs;
using AutoWashPro.Application.Interfaces;
using AutoWashPro.Infrastructure.Data;
using Microsoft.EntityFrameworkCore;

namespace AutoWashPro.Infrastructure.Repositories;

public class ServiceRepository : IServiceRepository
{
    private readonly ApplicationDbContext _context;

    public ServiceRepository(ApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<List<ServiceDTO>> GetAllServicesAsync()
    {
        return await _context.Services
            .Where(s => s.IsActive)
            .Select(s => new ServiceDTO
            {
                Id = s.Id,
                Name = s.Name,
                Description = s.Description,
                Price = s.Price,
                DurationMinutes = s.DurationMinutes,
                ImageUrl = s.ImageUrl
            })
            .ToListAsync();
    }

    public async Task<ServiceDTO?> GetServiceByIdAsync(Guid id)
    {
        return await _context.Services
            .Where(s => s.Id == id && s.IsActive)
            .Select(s => new ServiceDTO
            {
                Id = s.Id,
                Name = s.Name,
                Description = s.Description,
                Price = s.Price,
                DurationMinutes = s.DurationMinutes,
                ImageUrl = s.ImageUrl
            })
            .FirstOrDefaultAsync();
    }
}

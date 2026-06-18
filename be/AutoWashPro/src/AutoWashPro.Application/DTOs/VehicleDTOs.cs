using AutoWashPro.Domain.Enums;

namespace AutoWashPro.Application.DTOs;

public class VehicleDTO
{
    public Guid Id { get; set; }
    public string LicensePlate { get; set; } = string.Empty;
    public string VehicleTypeName { get; set; } = string.Empty;
    public VehicleType VehicleType { get; set; }
}

public class CreateVehicleDTO
{
    public string LicensePlate { get; set; } = string.Empty;
    public VehicleType VehicleType { get; set; }
}

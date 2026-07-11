namespace AutoWashPro.Domain.Entities;

public class ServiceChemical
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public Guid ServiceId { get; set; }
    public Guid ChemicalId { get; set; }
    public decimal QuantityPerWash { get; set; }

    // Navigation properties
    public Service Service { get; set; } = null!;
    public Chemical Chemical { get; set; } = null!;
}

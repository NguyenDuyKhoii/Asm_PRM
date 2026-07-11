namespace AutoWashPro.Domain.Entities;

public class Chemical
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public string Name { get; set; } = string.Empty;
    public string Unit { get; set; } = string.Empty;
    public decimal CurrentStock { get; set; }
    public decimal MinimumStock { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;

    // Navigation properties
    public ICollection<ServiceChemical> ServiceChemicals { get; set; } = new List<ServiceChemical>();
    public ICollection<ChemicalLog> ChemicalLogs { get; set; } = new List<ChemicalLog>();
}

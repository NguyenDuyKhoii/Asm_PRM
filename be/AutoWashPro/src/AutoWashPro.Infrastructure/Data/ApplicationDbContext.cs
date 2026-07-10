using AutoWashPro.Domain.Entities;
using Microsoft.EntityFrameworkCore;

namespace AutoWashPro.Infrastructure.Data;

public class ApplicationDbContext : DbContext
{
    public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options) : base(options) { }

    public DbSet<User> Users => Set<User>();
    public DbSet<Service> Services => Set<Service>();
    public DbSet<Vehicle> Vehicles => Set<Vehicle>();
    public DbSet<Booking> Bookings => Set<Booking>();
    public DbSet<TimeSlot> TimeSlots => Set<TimeSlot>();
    public DbSet<Reward> Rewards => Set<Reward>();
    public DbSet<Voucher> Vouchers => Set<Voucher>();
    public DbSet<Chemical> Chemicals => Set<Chemical>();
    public DbSet<ServiceChemical> ServiceChemicals => Set<ServiceChemical>();
    public DbSet<ChemicalLog> ChemicalLogs => Set<ChemicalLog>();
    public DbSet<Review> Reviews => Set<Review>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        // User configuration
        modelBuilder.Entity<User>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.HasIndex(e => e.Email).IsUnique();
            entity.Property(e => e.FullName).IsRequired().HasMaxLength(100);
            entity.Property(e => e.Email).IsRequired().HasMaxLength(100);
            entity.Property(e => e.PasswordHash).IsRequired();
            entity.Property(e => e.Phone).HasMaxLength(20);
            entity.Property(e => e.Tier).HasConversion<int>();
            entity.Property(e => e.Role).HasConversion<int>();
        });

        // Service configuration
        modelBuilder.Entity<Service>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Name).IsRequired().HasMaxLength(100);
            entity.Property(e => e.Description).HasMaxLength(500);
            entity.Property(e => e.Price).HasColumnType("decimal(18,2)");
            entity.Property(e => e.ImageUrl).HasMaxLength(500);
        });

        // Vehicle configuration
        modelBuilder.Entity<Vehicle>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.HasIndex(e => e.LicensePlate).IsUnique();
            entity.Property(e => e.LicensePlate).IsRequired().HasMaxLength(20);
            entity.Property(e => e.VehicleType).HasConversion<int>();
            entity.HasOne(e => e.User)
                  .WithMany(u => u.Vehicles)
                  .HasForeignKey(e => e.UserId)
                  .OnDelete(DeleteBehavior.Cascade);
        });

        // Booking configuration
        modelBuilder.Entity<Booking>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.TotalPrice).HasColumnType("decimal(18,2)");
            entity.Property(e => e.DiscountAmount).HasColumnType("decimal(18,2)");
            entity.Property(e => e.Status).HasConversion<int>();
            entity.Property(e => e.QrCode).HasMaxLength(500);

            entity.HasOne(e => e.User)
                  .WithMany(u => u.Bookings)
                  .HasForeignKey(e => e.UserId)
                  .OnDelete(DeleteBehavior.Cascade);

            entity.HasOne(e => e.Service)
                  .WithMany(s => s.Bookings)
                  .HasForeignKey(e => e.ServiceId)
                  .OnDelete(DeleteBehavior.Restrict);

            entity.HasOne(e => e.Vehicle)
                  .WithMany(v => v.Bookings)
                  .HasForeignKey(e => e.VehicleId)
                  .OnDelete(DeleteBehavior.Restrict);

            entity.HasOne(e => e.TimeSlot)
                  .WithMany(t => t.Bookings)
                  .HasForeignKey(e => e.TimeSlotId)
                  .OnDelete(DeleteBehavior.Restrict);
        });

        // TimeSlot configuration
        modelBuilder.Entity<TimeSlot>(entity =>
        {
            entity.HasKey(e => e.Id);
        });

        // Reward configuration
        modelBuilder.Entity<Reward>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Name).IsRequired().HasMaxLength(100);
            entity.Property(e => e.Description).HasMaxLength(500);
            entity.Property(e => e.Type).HasConversion<int>();
            entity.Property(e => e.DiscountValue).HasColumnType("decimal(18,2)");
            entity.Property(e => e.ImageUrl).HasMaxLength(500);
        });

        // Voucher configuration
        modelBuilder.Entity<Voucher>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.HasIndex(e => e.Code).IsUnique();
            entity.Property(e => e.Code).IsRequired().HasMaxLength(50);
            entity.HasOne(e => e.User)
                  .WithMany(u => u.Vouchers)
                  .HasForeignKey(e => e.UserId)
                  .OnDelete(DeleteBehavior.Cascade);
            entity.HasOne(e => e.Reward)
                  .WithMany(r => r.Vouchers)
                  .HasForeignKey(e => e.RewardId)
                  .OnDelete(DeleteBehavior.Restrict);
        });

        // Chemical configuration
        modelBuilder.Entity<Chemical>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Name).IsRequired().HasMaxLength(100);
            entity.Property(e => e.Unit).IsRequired().HasMaxLength(50);
            entity.Property(e => e.CurrentStock).HasColumnType("decimal(18,2)");
            entity.Property(e => e.MinimumStock).HasColumnType("decimal(18,2)");
        });

        // ServiceChemical configuration
        modelBuilder.Entity<ServiceChemical>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.HasIndex(e => new { e.ServiceId, e.ChemicalId }).IsUnique();
            entity.Property(e => e.QuantityPerWash).HasColumnType("decimal(18,2)");
            entity.HasOne(e => e.Service)
                  .WithMany(s => s.ServiceChemicals)
                  .HasForeignKey(e => e.ServiceId)
                  .OnDelete(DeleteBehavior.Cascade);
            entity.HasOne(e => e.Chemical)
                  .WithMany(c => c.ServiceChemicals)
                  .HasForeignKey(e => e.ChemicalId)
                  .OnDelete(DeleteBehavior.Cascade);
        });

        // ChemicalLog configuration
        modelBuilder.Entity<ChemicalLog>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.ChangeAmount).HasColumnType("decimal(18,2)");
            entity.Property(e => e.Reason).IsRequired().HasMaxLength(500);
            entity.HasOne(e => e.Chemical)
                  .WithMany(c => c.ChemicalLogs)
                  .HasForeignKey(e => e.ChemicalId)
                  .OnDelete(DeleteBehavior.Cascade);
            entity.HasOne(e => e.Booking)
                  .WithMany(b => b.ChemicalLogs)
                  .HasForeignKey(e => e.BookingId)
                  .OnDelete(DeleteBehavior.SetNull);
        });

        // Review configuration
        modelBuilder.Entity<Review>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.HasIndex(e => e.BookingId).IsUnique();
            entity.Property(e => e.Comment).HasMaxLength(1000);
            entity.HasOne(e => e.Booking)
                  .WithOne(b => b.Review)
                  .HasForeignKey<Review>(e => e.BookingId)
                  .OnDelete(DeleteBehavior.Cascade);
            entity.HasOne(e => e.User)
                  .WithMany(u => u.Reviews)
                  .HasForeignKey(e => e.UserId)
                  .OnDelete(DeleteBehavior.Cascade);
        });
    }
}

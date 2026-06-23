using AutoWashPro.Domain.Entities;
using AutoWashPro.Domain.Enums;
using Microsoft.EntityFrameworkCore;

namespace AutoWashPro.Infrastructure.Data;

public static class DbSeeder
{
    public static async Task SeedAsync(ApplicationDbContext context)
    {
        // Seed Services
        if (!await context.Services.AnyAsync())
        {
            var services = new List<Service>
            {
                new()
                {
                    Id = Guid.Parse("a1b2c3d4-e5f6-7890-abcd-ef1234567801"),
                    Name = "Basic Car Wash",
                    Description = "Exterior high-pressure wash, hand dry, and tire shine.",
                    Price = 50000,
                    DurationMinutes = 30,
                    ImageUrl = "https://images.unsplash.com/photo-1520340356584-f9917d1eea6f?auto=format&fit=crop&q=80&w=800",
                    IsActive = true
                },
                new()
                {
                    Id = Guid.Parse("a1b2c3d4-e5f6-7890-abcd-ef1234567802"),
                    Name = "Premium Car Wash",
                    Description = "Exterior wash + basic interior cleaning, seat and floor vacuuming.",
                    Price = 100000,
                    DurationMinutes = 45,
                    ImageUrl = "https://images.unsplash.com/photo-1601362840469-51e4d8d58785?auto=format&fit=crop&q=80&w=800",
                    IsActive = true
                },
                new()
                {
                    Id = Guid.Parse("a1b2c3d4-e5f6-7890-abcd-ef1234567803"),
                    Name = "Wash & Vacuum",
                    Description = "Comprehensive exterior wash + full interior vacuum + dashboard cleaning.",
                    Price = 150000,
                    DurationMinutes = 60,
                    ImageUrl = "https://images.unsplash.com/photo-1600577916048-804c9191e36c?auto=format&fit=crop&q=80&w=800",
                    IsActive = true
                },
                new()
                {
                    Id = Guid.Parse("a1b2c3d4-e5f6-7890-abcd-ef1234567804"),
                    Name = "Comprehensive Care",
                    Description = "Wash + vacuum + paint polish + plastic trim dressing + interior fragrance.",
                    Price = 300000,
                    DurationMinutes = 90,
                    ImageUrl = "https://images.unsplash.com/photo-1580273916550-e323be2ae537?auto=format&fit=crop&q=80&w=800",
                    IsActive = true
                },
                new()
                {
                    Id = Guid.Parse("a1b2c3d4-e5f6-7890-abcd-ef1234567805"),
                    Name = "Interior Polishing",
                    Description = "Deep interior cleaning, seat washing, ceiling cleaning, leather conditioning.",
                    Price = 500000,
                    DurationMinutes = 120,
                    ImageUrl = "https://images.unsplash.com/photo-1549317661-bd32c8ce0db2?auto=format&fit=crop&q=80&w=800",
                    IsActive = true
                }
            };

            await context.Services.AddRangeAsync(services);
        }

        // Seed Demo Users
        if (!await context.Users.AnyAsync())
        {
            var demoUser = new User
            {
                Id = Guid.Parse("d1e2f3a4-b5c6-7890-abcd-ef1234567890"),
                FullName = "Nguyễn Văn Platinum",
                Email = "demo@autowash.com",
                PasswordHash = BCrypt.Net.BCrypt.HashPassword("Demo@123"),
                Phone = "0901234567",
                Tier = MemberTier.Platinum,
                LoyaltyPoints = 500,
                CreatedAt = DateTime.UtcNow
            };

            var memberUser = new User
            {
                Id = Guid.Parse("d1e2f3a4-b5c6-7890-abcd-ef1234567891"),
                FullName = "Trần Thị Member",
                Email = "member@autowash.com",
                PasswordHash = BCrypt.Net.BCrypt.HashPassword("Member@123"),
                Phone = "0909876543",
                Tier = MemberTier.Member,
                LoyaltyPoints = 50,
                CreatedAt = DateTime.UtcNow
            };

            await context.Users.AddRangeAsync(demoUser, memberUser);

            // Seed Vehicles for demo users
            var vehicles = new List<Vehicle>
            {
                new()
                {
                    Id = Guid.Parse("b1e2f3a4-b5c6-7890-abcd-ef1234567801"),
                    UserId = demoUser.Id,
                    LicensePlate = "51A-123.45",
                    VehicleType = VehicleType.Car,
                    CreatedAt = DateTime.UtcNow
                },
                new()
                {
                    Id = Guid.Parse("b1e2f3a4-b5c6-7890-abcd-ef1234567802"),
                    UserId = memberUser.Id,
                    LicensePlate = "59B-678.90",
                    VehicleType = VehicleType.Motorcycle,
                    CreatedAt = DateTime.UtcNow
                }
            };

            await context.Vehicles.AddRangeAsync(vehicles);
        }

        // Seed TimeSlots for next 30 days if there are no future slots
        var today = DateTime.UtcNow.Date;
        var hasFutureSlots = await context.TimeSlots.AnyAsync(ts => ts.Date >= today);
        if (!hasFutureSlots)
        {
            var timeSlotTemplates = new[]
            {
                (new TimeSpan(8, 0, 0), new TimeSpan(9, 0, 0)),
                (new TimeSpan(9, 0, 0), new TimeSpan(10, 0, 0)),
                (new TimeSpan(10, 0, 0), new TimeSpan(11, 0, 0)),
                (new TimeSpan(11, 0, 0), new TimeSpan(12, 0, 0)),
                (new TimeSpan(13, 0, 0), new TimeSpan(14, 0, 0)),
                (new TimeSpan(14, 0, 0), new TimeSpan(15, 0, 0)),
                (new TimeSpan(15, 0, 0), new TimeSpan(16, 0, 0)),
                (new TimeSpan(16, 0, 0), new TimeSpan(17, 0, 0)),
            };

            var timeSlots = new List<TimeSlot>();
            for (int day = 0; day < 30; day++)
            {
                var date = today.AddDays(day);
                foreach (var (start, end) in timeSlotTemplates)
                {
                    timeSlots.Add(new TimeSlot
                    {
                        Id = Guid.NewGuid(),
                        StartTime = start,
                        EndTime = end,
                        MaxCapacity = 3,
                        Date = date
                    });
                }
            }

            await context.TimeSlots.AddRangeAsync(timeSlots);
        }

        // Seed Rewards
        if (!await context.Rewards.AnyAsync())
        {
            var rewards = new List<Reward>
            {
                new()
                {
                    Id = Guid.Parse("c1e2f3a4-b5c6-7890-abcd-ef1234567801"),
                    Name = "20% Off Next Wash",
                    Description = "20% discount voucher for any car wash. Applies to all services.",
                    Type = RewardType.Discount,
                    PointsCost = 50,
                    DiscountValue = 20,
                    ImageUrl = "discount_20",
                    IsActive = true
                },
                new()
                {
                    Id = Guid.Parse("c1e2f3a4-b5c6-7890-abcd-ef1234567802"),
                    Name = "50% Off Next Wash",
                    Description = "50% discount voucher for 1 car wash. Applies to services from 100,000đ.",
                    Type = RewardType.Discount,
                    PointsCost = 100,
                    DiscountValue = 50,
                    ImageUrl = "discount_50",
                    IsActive = true
                },
                new()
                {
                    Id = Guid.Parse("c1e2f3a4-b5c6-7890-abcd-ef1234567803"),
                    Name = "Free Basic Wash",
                    Description = "Redeem points for 1 completely free basic car wash.",
                    Type = RewardType.FreeWash,
                    PointsCost = 150,
                    DiscountValue = 50000,
                    ImageUrl = "free_basic",
                    IsActive = true
                },
                new()
                {
                    Id = Guid.Parse("c1e2f3a4-b5c6-7890-abcd-ef1234567804"),
                    Name = "Free Premium Wash",
                    Description = "Redeem points for 1 completely free premium car wash.",
                    Type = RewardType.FreeWash,
                    PointsCost = 300,
                    DiscountValue = 100000,
                    ImageUrl = "free_premium",
                    IsActive = true
                },
                new()
                {
                    Id = Guid.Parse("c1e2f3a4-b5c6-7890-abcd-ef1234567805"),
                    Name = "Interior Fragrance",
                    Description = "Free premium interior fragrance spray with your next car wash.",
                    Type = RewardType.AddOn,
                    PointsCost = 30,
                    DiscountValue = 30000,
                    ImageUrl = "addon_perfume",
                    IsActive = true
                },
                new()
                {
                    Id = Guid.Parse("c1e2f3a4-b5c6-7890-abcd-ef1234567806"),
                    Name = "Nano Paint Coating",
                    Description = "Free protective nano paint coating service (worth 200,000đ).",
                    Type = RewardType.AddOn,
                    PointsCost = 400,
                    DiscountValue = 200000,
                    ImageUrl = "addon_nano",
                    IsActive = true
                }
            };

            await context.Rewards.AddRangeAsync(rewards);
        }

        await context.SaveChangesAsync();
    }
}

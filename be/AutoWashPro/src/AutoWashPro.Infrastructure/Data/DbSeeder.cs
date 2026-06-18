using AutoWashPro.Domain.Entities;
using AutoWashPro.Domain.Enums;
using Microsoft.EntityFrameworkCore;

namespace AutoWashPro.Infrastructure.Data;

public static class DbSeeder
{
    public static async Task SeedAsync(ApplicationDbContext context)
    {
        if (await context.Services.AnyAsync())
            return;

        // Seed Services
        var services = new List<Service>
        {
            new()
            {
                Id = Guid.Parse("a1b2c3d4-e5f6-7890-abcd-ef1234567801"),
                Name = "Rửa xe cơ bản",
                Description = "Rửa ngoài xe bằng nước áp lực cao, lau khô và xịt bóng lốp.",
                Price = 50000,
                DurationMinutes = 30,
                ImageUrl = "basic_wash",
                IsActive = true
            },
            new()
            {
                Id = Guid.Parse("a1b2c3d4-e5f6-7890-abcd-ef1234567802"),
                Name = "Rửa xe cao cấp",
                Description = "Rửa ngoài + vệ sinh nội thất cơ bản, hút bụi ghế và sàn xe.",
                Price = 100000,
                DurationMinutes = 45,
                ImageUrl = "premium_wash",
                IsActive = true
            },
            new()
            {
                Id = Guid.Parse("a1b2c3d4-e5f6-7890-abcd-ef1234567803"),
                Name = "Rửa xe & Hút bụi",
                Description = "Rửa ngoài toàn diện + hút bụi toàn bộ nội thất + vệ sinh taplo.",
                Price = 150000,
                DurationMinutes = 60,
                ImageUrl = "wash_vacuum",
                IsActive = true
            },
            new()
            {
                Id = Guid.Parse("a1b2c3d4-e5f6-7890-abcd-ef1234567804"),
                Name = "Chăm sóc toàn diện",
                Description = "Rửa xe + hút bụi + đánh bóng sơn + dưỡng nhựa đen + xịt thơm.",
                Price = 300000,
                DurationMinutes = 90,
                ImageUrl = "full_care",
                IsActive = true
            },
            new()
            {
                Id = Guid.Parse("a1b2c3d4-e5f6-7890-abcd-ef1234567805"),
                Name = "Đánh bóng nội thất",
                Description = "Vệ sinh sâu nội thất, giặt ghế, làm sạch trần, dưỡng da ghế.",
                Price = 500000,
                DurationMinutes = 120,
                ImageUrl = "interior_polish",
                IsActive = true
            }
        };

        await context.Services.AddRangeAsync(services);

        // Seed Demo Users
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
                Id = Guid.Parse("v1e2f3a4-b5c6-7890-abcd-ef1234567801"),
                UserId = demoUser.Id,
                LicensePlate = "51A-123.45",
                VehicleType = VehicleType.Car,
                CreatedAt = DateTime.UtcNow
            },
            new()
            {
                Id = Guid.Parse("v1e2f3a4-b5c6-7890-abcd-ef1234567802"),
                UserId = memberUser.Id,
                LicensePlate = "59B-678.90",
                VehicleType = VehicleType.Motorcycle,
                CreatedAt = DateTime.UtcNow
            }
        };

        await context.Vehicles.AddRangeAsync(vehicles);

        // Seed TimeSlots for next 14 days
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
            var date = DateTime.UtcNow.Date.AddDays(day);
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
        await context.SaveChangesAsync();
    }
}

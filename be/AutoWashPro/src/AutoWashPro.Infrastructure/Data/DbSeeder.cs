using AutoWashPro.Domain.Entities;
using AutoWashPro.Domain.Enums;
using Microsoft.EntityFrameworkCore;

namespace AutoWashPro.Infrastructure.Data;

public static class DbSeeder
{
    public static async Task SeedAsync(ApplicationDbContext context)
    {
        // Seed Services (Vietnamese)
        if (!await context.Services.AnyAsync())
        {
            var services = new List<Service>
            {
                new()
                {
                    Id = Guid.Parse("a1b2c3d4-e5f6-7890-abcd-ef1234567801"),
                    Name = "Rửa xe cơ bản",
                    Description = "Rửa xe áp lực cao bên ngoài, lau khô bằng tay và đánh bóng lốp.",
                    Price = 50000,
                    DurationMinutes = 30,
                    ImageUrl = "https://images.unsplash.com/photo-1520340356584-f9917d1eea6f?auto=format&fit=crop&q=80&w=800",
                    IsActive = true
                },
                new()
                {
                    Id = Guid.Parse("a1b2c3d4-e5f6-7890-abcd-ef1234567802"),
                    Name = "Rửa xe cao cấp",
                    Description = "Rửa vỏ bên ngoài + vệ sinh nội thất cơ bản, hút bụi ghế và sàn xe.",
                    Price = 100000,
                    DurationMinutes = 45,
                    ImageUrl = "https://images.unsplash.com/photo-1601362840469-51e4d8d58785?auto=format&fit=crop&q=80&w=800",
                    IsActive = true
                },
                new()
                {
                    Id = Guid.Parse("a1b2c3d4-e5f6-7890-abcd-ef1234567803"),
                    Name = "Rửa xe & Hút bụi",
                    Description = "Rửa vỏ toàn diện + hút bụi chi tiết toàn bộ nội thất + lau sạch bảng taplo.",
                    Price = 150000,
                    DurationMinutes = 60,
                    ImageUrl = "https://images.unsplash.com/photo-1600577916048-804c9191e36c?auto=format&fit=crop&q=80&w=800",
                    IsActive = true
                },
                new()
                {
                    Id = Guid.Parse("a1b2c3d4-e5f6-7890-abcd-ef1234567804"),
                    Name = "Chăm sóc toàn diện",
                    Description = "Rửa xe + hút bụi + đánh bóng sơn + dưỡng nhựa ngoài + xịt thơm nội thất.",
                    Price = 300000,
                    DurationMinutes = 90,
                    ImageUrl = "https://images.unsplash.com/photo-1580273916550-e323be2ae537?auto=format&fit=crop&q=80&w=800",
                    IsActive = true
                },
                new()
                {
                    Id = Guid.Parse("a1b2c3d4-e5f6-7890-abcd-ef1234567805"),
                    Name = "Đánh bóng & Dưỡng nội thất",
                    Description = "Dọn nội thất sâu, giặt ghế, vệ sinh trần, dưỡng da cao cấp.",
                    Price = 500000,
                    DurationMinutes = 120,
                    ImageUrl = "https://images.unsplash.com/photo-1549317661-bd32c8ce0db2?auto=format&fit=crop&q=80&w=800",
                    IsActive = true
                }
            };

            await context.Services.AddRangeAsync(services);
        }
        else
        {
            // Auto-update existing English service records to Vietnamese
            var basicSvc = await context.Services.FindAsync(Guid.Parse("a1b2c3d4-e5f6-7890-abcd-ef1234567801"));
            if (basicSvc != null && basicSvc.Name == "Basic Car Wash")
            {
                basicSvc.Name = "Rửa xe cơ bản";
                basicSvc.Description = "Rửa xe áp lực cao bên ngoài, lau khô bằng tay và đánh bóng lốp.";
            }
            var premiumSvc = await context.Services.FindAsync(Guid.Parse("a1b2c3d4-e5f6-7890-abcd-ef1234567802"));
            if (premiumSvc != null && premiumSvc.Name == "Premium Car Wash")
            {
                premiumSvc.Name = "Rửa xe cao cấp";
                premiumSvc.Description = "Rửa vỏ bên ngoài + vệ sinh nội thất cơ bản, hút bụi ghế và sàn xe.";
            }
            var washVacuum = await context.Services.FindAsync(Guid.Parse("a1b2c3d4-e5f6-7890-abcd-ef1234567803"));
            if (washVacuum != null && washVacuum.Name == "Wash & Vacuum")
            {
                washVacuum.Name = "Rửa xe & Hút bụi";
                washVacuum.Description = "Rửa vỏ toàn diện + hút bụi chi tiết toàn bộ nội thất + lau sạch bảng taplo.";
            }
            var comprehensive = await context.Services.FindAsync(Guid.Parse("a1b2c3d4-e5f6-7890-abcd-ef1234567804"));
            if (comprehensive != null && comprehensive.Name == "Comprehensive Care")
            {
                comprehensive.Name = "Chăm sóc toàn diện";
                comprehensive.Description = "Rửa xe + hút bụi + đánh bóng sơn + dưỡng nhựa ngoài + xịt thơm nội thất.";
            }
            var interior = await context.Services.FindAsync(Guid.Parse("a1b2c3d4-e5f6-7890-abcd-ef1234567805"));
            if (interior != null && interior.Name == "Interior Polishing")
            {
                interior.Name = "Đánh bóng & Dưỡng nội thất";
                interior.Description = "Dọn nội thất sâu, giặt ghế, vệ sinh trần, dưỡng da cao cấp.";
            }
            await context.SaveChangesAsync();
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
                Role = UserRole.Customer,
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
                Role = UserRole.Customer,
                CreatedAt = DateTime.UtcNow
            };

            var adminUser = new User
            {
                Id = Guid.Parse("d1e2f3a4-b5c6-7890-abcd-ef1234567892"),
                FullName = "System Admin",
                Email = "admin@autowash.com",
                PasswordHash = BCrypt.Net.BCrypt.HashPassword("Admin@123"),
                Phone = "0900000000",
                Tier = MemberTier.Member,
                LoyaltyPoints = 0,
                Role = UserRole.Admin,
                CreatedAt = DateTime.UtcNow
            };

            await context.Users.AddRangeAsync(demoUser, memberUser, adminUser);

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

        // Seed Rewards (Vietnamese)
        if (!await context.Rewards.AnyAsync())
        {
            var rewards = new List<Reward>
            {
                new()
                {
                    Id = Guid.Parse("c1e2f3a4-b5c6-7890-abcd-ef1234567801"),
                    Name = "Voucher Giảm Giá 20%",
                    Description = "Voucher giảm giá 20% cho bất kỳ ca rửa xe nào. Áp dụng cho mọi dịch vụ.",
                    Type = RewardType.Discount,
                    PointsCost = 50,
                    DiscountValue = 20,
                    ImageUrl = "discount_20",
                    IsActive = true
                },
                new()
                {
                    Id = Guid.Parse("c1e2f3a4-b5c6-7890-abcd-ef1234567802"),
                    Name = "Voucher Giảm Giá 50%",
                    Description = "Voucher giảm giá 50% cho 1 lần rửa xe. Áp dụng cho dịch vụ từ 100.000đ.",
                    Type = RewardType.Discount,
                    PointsCost = 100,
                    DiscountValue = 50,
                    ImageUrl = "discount_50",
                    IsActive = true
                },
                new()
                {
                    Id = Guid.Parse("c1e2f3a4-b5c6-7890-abcd-ef1234567803"),
                    Name = "Rửa xe Cơ bản Miễn phí",
                    Description = "Đổi điểm lấy 1 lần rửa xe cơ bản hoàn toàn miễn phí.",
                    Type = RewardType.FreeWash,
                    PointsCost = 150,
                    DiscountValue = 50000,
                    ImageUrl = "free_basic",
                    IsActive = true
                },
                new()
                {
                    Id = Guid.Parse("c1e2f3a4-b5c6-7890-abcd-ef1234567804"),
                    Name = "Rửa xe Cao cấp Miễn phí",
                    Description = "Đổi điểm lấy 1 lần rửa xe cao cấp hoàn toàn miễn phí.",
                    Type = RewardType.FreeWash,
                    PointsCost = 300,
                    DiscountValue = 100000,
                    ImageUrl = "free_premium",
                    IsActive = true
                },
                new()
                {
                    Id = Guid.Parse("c1e2f3a4-b5c6-7890-abcd-ef1234567805"),
                    Name = "Xịt thơm Nội thất",
                    Description = "Miễn phí xịt thơm nội thất cao cấp cho ca rửa xe tiếp theo.",
                    Type = RewardType.AddOn,
                    PointsCost = 30,
                    DiscountValue = 30000,
                    ImageUrl = "addon_perfume",
                    IsActive = true
                },
                new()
                {
                    Id = Guid.Parse("c1e2f3a4-b5c6-7890-abcd-ef1234567806"),
                    Name = "Phủ bóng Sơn Nano",
                    Description = "Miễn phí dịch vụ phủ bóng sơn bảo vệ Nano (trị giá 200.000đ).",
                    Type = RewardType.AddOn,
                    PointsCost = 400,
                    DiscountValue = 200000,
                    ImageUrl = "addon_nano",
                    IsActive = true
                }
            };

            await context.Rewards.AddRangeAsync(rewards);
        }
        else
        {
            // Auto-update existing English reward records to Vietnamese
            var r1 = await context.Rewards.FindAsync(Guid.Parse("c1e2f3a4-b5c6-7890-abcd-ef1234567801"));
            if (r1 != null && r1.Name == "20% Off Next Wash")
            {
                r1.Name = "Voucher Giảm Giá 20%";
                r1.Description = "Voucher giảm giá 20% cho bất kỳ ca rửa xe nào. Áp dụng cho mọi dịch vụ.";
            }
            var r2 = await context.Rewards.FindAsync(Guid.Parse("c1e2f3a4-b5c6-7890-abcd-ef1234567802"));
            if (r2 != null && r2.Name == "50% Off Next Wash")
            {
                r2.Name = "Voucher Giảm Giá 50%";
                r2.Description = "Voucher giảm giá 50% cho 1 lần rửa xe. Áp dụng cho dịch vụ từ 100.000đ.";
            }
            var r3 = await context.Rewards.FindAsync(Guid.Parse("c1e2f3a4-b5c6-7890-abcd-ef1234567803"));
            if (r3 != null && r3.Name == "Free Basic Wash")
            {
                r3.Name = "Rửa xe Cơ bản Miễn phí";
                r3.Description = "Đổi điểm lấy 1 lần rửa xe cơ bản hoàn toàn miễn phí.";
            }
            var r4 = await context.Rewards.FindAsync(Guid.Parse("c1e2f3a4-b5c6-7890-abcd-ef1234567804"));
            if (r4 != null && r4.Name == "Free Premium Wash")
            {
                r4.Name = "Rửa xe Cao cấp Miễn phí";
                r4.Description = "Đổi điểm lấy 1 lần rửa xe cao cấp hoàn toàn miễn phí.";
            }
            var r5 = await context.Rewards.FindAsync(Guid.Parse("c1e2f3a4-b5c6-7890-abcd-ef1234567805"));
            if (r5 != null && r5.Name == "Interior Fragrance")
            {
                r5.Name = "Xịt thơm Nội thất";
                r5.Description = "Miễn phí xịt thơm nội thất cao cấp cho ca rửa xe tiếp theo.";
            }
            var r6 = await context.Rewards.FindAsync(Guid.Parse("c1e2f3a4-b5c6-7890-abcd-ef1234567806"));
            if (r6 != null && r6.Name == "Nano Paint Coating")
            {
                r6.Name = "Phủ bóng Sơn Nano";
                r6.Description = "Miễn phí dịch vụ phủ bóng sơn bảo vệ Nano (trị giá 200.000đ).";
            }
            await context.SaveChangesAsync();
        }

        // Seed Chemicals
        if (!await context.Chemicals.AnyAsync())
        {
            var chemicals = new List<Chemical>
            {
                new() { Id = Guid.Parse("e1b2c3d4-e5f6-7890-abcd-ef1234567801"), Name = "Active Foam Shampoo", Unit = "ml", CurrentStock = 20000, MinimumStock = 2000, CreatedAt = DateTime.UtcNow, UpdatedAt = DateTime.UtcNow },
                new() { Id = Guid.Parse("e1b2c3d4-e5f6-7890-abcd-ef1234567802"), Name = "Tire Wax & Shine", Unit = "ml", CurrentStock = 5000, MinimumStock = 500, CreatedAt = DateTime.UtcNow, UpdatedAt = DateTime.UtcNow },
                new() { Id = Guid.Parse("e1b2c3d4-e5f6-7890-abcd-ef1234567803"), Name = "Glass Cleaner", Unit = "ml", CurrentStock = 10000, MinimumStock = 1000, CreatedAt = DateTime.UtcNow, UpdatedAt = DateTime.UtcNow },
                new() { Id = Guid.Parse("e1b2c3d4-e5f6-7890-abcd-ef1234567804"), Name = "Leather Conditioner", Unit = "ml", CurrentStock = 5000, MinimumStock = 500, CreatedAt = DateTime.UtcNow, UpdatedAt = DateTime.UtcNow },
                new() { Id = Guid.Parse("e1b2c3d4-e5f6-7890-abcd-ef1234567805"), Name = "Premium Car Wax / Polish", Unit = "ml", CurrentStock = 3000, MinimumStock = 300, CreatedAt = DateTime.UtcNow, UpdatedAt = DateTime.UtcNow },
                new() { Id = Guid.Parse("e1b2c3d4-e5f6-7890-abcd-ef1234567806"), Name = "Deodorizer & Fragrance", Unit = "ml", CurrentStock = 2000, MinimumStock = 200, CreatedAt = DateTime.UtcNow, UpdatedAt = DateTime.UtcNow }
            };
            await context.Chemicals.AddRangeAsync(chemicals);
        }

        // Seed ServiceChemicals
        if (!await context.ServiceChemicals.AnyAsync())
        {
            var serviceChemicals = new List<ServiceChemical>
            {
                // Basic Car Wash (a1b2c3d4-e5f6-7890-abcd-ef1234567801)
                new() { Id = Guid.NewGuid(), ServiceId = Guid.Parse("a1b2c3d4-e5f6-7890-abcd-ef1234567801"), ChemicalId = Guid.Parse("e1b2c3d4-e5f6-7890-abcd-ef1234567801"), QuantityPerWash = 150 },
                new() { Id = Guid.NewGuid(), ServiceId = Guid.Parse("a1b2c3d4-e5f6-7890-abcd-ef1234567801"), ChemicalId = Guid.Parse("e1b2c3d4-e5f6-7890-abcd-ef1234567803"), QuantityPerWash = 50 },
                new() { Id = Guid.NewGuid(), ServiceId = Guid.Parse("a1b2c3d4-e5f6-7890-abcd-ef1234567801"), ChemicalId = Guid.Parse("e1b2c3d4-e5f6-7890-abcd-ef1234567802"), QuantityPerWash = 30 },

                // Premium Car Wash (a1b2c3d4-e5f6-7890-abcd-ef1234567802)
                new() { Id = Guid.NewGuid(), ServiceId = Guid.Parse("a1b2c3d4-e5f6-7890-abcd-ef1234567802"), ChemicalId = Guid.Parse("e1b2c3d4-e5f6-7890-abcd-ef1234567801"), QuantityPerWash = 200 },
                new() { Id = Guid.NewGuid(), ServiceId = Guid.Parse("a1b2c3d4-e5f6-7890-abcd-ef1234567802"), ChemicalId = Guid.Parse("e1b2c3d4-e5f6-7890-abcd-ef1234567803"), QuantityPerWash = 80 },
                new() { Id = Guid.NewGuid(), ServiceId = Guid.Parse("a1b2c3d4-e5f6-7890-abcd-ef1234567802"), ChemicalId = Guid.Parse("e1b2c3d4-e5f6-7890-abcd-ef1234567802"), QuantityPerWash = 40 },
                new() { Id = Guid.NewGuid(), ServiceId = Guid.Parse("a1b2c3d4-e5f6-7890-abcd-ef1234567802"), ChemicalId = Guid.Parse("e1b2c3d4-e5f6-7890-abcd-ef1234567806"), QuantityPerWash = 10 },

                // Wash & Vacuum (a1b2c3d4-e5f6-7890-abcd-ef1234567803)
                new() { Id = Guid.NewGuid(), ServiceId = Guid.Parse("a1b2c3d4-e5f6-7890-abcd-ef1234567803"), ChemicalId = Guid.Parse("e1b2c3d4-e5f6-7890-abcd-ef1234567801"), QuantityPerWash = 200 },
                new() { Id = Guid.NewGuid(), ServiceId = Guid.Parse("a1b2c3d4-e5f6-7890-abcd-ef1234567803"), ChemicalId = Guid.Parse("e1b2c3d4-e5f6-7890-abcd-ef1234567803"), QuantityPerWash = 100 },
                new() { Id = Guid.NewGuid(), ServiceId = Guid.Parse("a1b2c3d4-e5f6-7890-abcd-ef1234567803"), ChemicalId = Guid.Parse("e1b2c3d4-e5f6-7890-abcd-ef1234567802"), QuantityPerWash = 40 },
                new() { Id = Guid.NewGuid(), ServiceId = Guid.Parse("a1b2c3d4-e5f6-7890-abcd-ef1234567803"), ChemicalId = Guid.Parse("e1b2c3d4-e5f6-7890-abcd-ef1234567804"), QuantityPerWash = 30 },
                new() { Id = Guid.NewGuid(), ServiceId = Guid.Parse("a1b2c3d4-e5f6-7890-abcd-ef1234567803"), ChemicalId = Guid.Parse("e1b2c3d4-e5f6-7890-abcd-ef1234567806"), QuantityPerWash = 15 },

                // Comprehensive Care (a1b2c3d4-e5f6-7890-abcd-ef1234567804)
                new() { Id = Guid.NewGuid(), ServiceId = Guid.Parse("a1b2c3d4-e5f6-7890-abcd-ef1234567804"), ChemicalId = Guid.Parse("e1b2c3d4-e5f6-7890-abcd-ef1234567801"), QuantityPerWash = 250 },
                new() { Id = Guid.NewGuid(), ServiceId = Guid.Parse("a1b2c3d4-e5f6-7890-abcd-ef1234567804"), ChemicalId = Guid.Parse("e1b2c3d4-e5f6-7890-abcd-ef1234567803"), QuantityPerWash = 120 },
                new() { Id = Guid.NewGuid(), ServiceId = Guid.Parse("a1b2c3d4-e5f6-7890-abcd-ef1234567804"), ChemicalId = Guid.Parse("e1b2c3d4-e5f6-7890-abcd-ef1234567802"), QuantityPerWash = 50 },
                new() { Id = Guid.NewGuid(), ServiceId = Guid.Parse("a1b2c3d4-e5f6-7890-abcd-ef1234567804"), ChemicalId = Guid.Parse("e1b2c3d4-e5f6-7890-abcd-ef1234567804"), QuantityPerWash = 50 },
                new() { Id = Guid.NewGuid(), ServiceId = Guid.Parse("a1b2c3d4-e5f6-7890-abcd-ef1234567804"), ChemicalId = Guid.Parse("e1b2c3d4-e5f6-7890-abcd-ef1234567805"), QuantityPerWash = 20 },
                new() { Id = Guid.NewGuid(), ServiceId = Guid.Parse("a1b2c3d4-e5f6-7890-abcd-ef1234567804"), ChemicalId = Guid.Parse("e1b2c3d4-e5f6-7890-abcd-ef1234567806"), QuantityPerWash = 20 },

                // Interior Polishing (a1b2c3d4-e5f6-7890-abcd-ef1234567805)
                new() { Id = Guid.NewGuid(), ServiceId = Guid.Parse("a1b2c3d4-e5f6-7890-abcd-ef1234567805"), ChemicalId = Guid.Parse("e1b2c3d4-e5f6-7890-abcd-ef1234567803"), QuantityPerWash = 150 },
                new() { Id = Guid.NewGuid(), ServiceId = Guid.Parse("a1b2c3d4-e5f6-7890-abcd-ef1234567805"), ChemicalId = Guid.Parse("e1b2c3d4-e5f6-7890-abcd-ef1234567804"), QuantityPerWash = 100 },
                new() { Id = Guid.NewGuid(), ServiceId = Guid.Parse("a1b2c3d4-e5f6-7890-abcd-ef1234567805"), ChemicalId = Guid.Parse("e1b2c3d4-e5f6-7890-abcd-ef1234567806"), QuantityPerWash = 30 }
            };
            await context.ServiceChemicals.AddRangeAsync(serviceChemicals);
        }

        // Reset InProgress bookings for today to Confirmed so staff can click "Bắt đầu làm việc"
        var todayDate = DateTime.UtcNow.Date;
        var todayBookings = await context.Bookings
            .Where(b => b.BookingDate.Date == todayDate && b.Status == BookingStatus.InProgress)
            .ToListAsync();
            
        foreach (var b in todayBookings)
        {
            b.Status = BookingStatus.Confirmed;
            b.Checklist = null; // Clear checklist so it's fresh
        }

        await context.SaveChangesAsync();
    }
}

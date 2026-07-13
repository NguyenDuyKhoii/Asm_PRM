using System.Text;
using AutoWashPro.Application.Interfaces;
using AutoWashPro.Infrastructure.Data;
using AutoWashPro.Infrastructure.Repositories;
using AutoWashPro.Infrastructure.Services;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;

AppContext.SetSwitch("Npgsql.EnableLegacyTimestampBehavior", true);
var builder = WebApplication.CreateBuilder(args);

// Add DbContext with PostgreSQL
builder.Services.AddDbContext<ApplicationDbContext>(options =>
    options.UseNpgsql(builder.Configuration.GetConnectionString("DefaultConnection")));

// Register services
builder.Services.AddScoped<IAuthService, AuthService>();
builder.Services.AddScoped<IServiceRepository, ServiceRepository>();
builder.Services.AddScoped<IBookingRepository, BookingRepository>();
builder.Services.AddScoped<IUserRepository, UserRepository>();
builder.Services.AddScoped<IVehicleRepository, VehicleRepository>();
builder.Services.AddScoped<IRewardRepository, RewardRepository>();

// JWT Authentication
var jwtKey = builder.Configuration["Jwt:Key"] ?? "AutoWashProSuperSecretKeyThatIsLongEnough2024!";
builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidateAudience = true,
            ValidateLifetime = true,
            ValidateIssuerSigningKey = true,
            ValidIssuer = builder.Configuration["Jwt:Issuer"] ?? "AutoWashPro",
            ValidAudience = builder.Configuration["Jwt:Audience"] ?? "AutoWashProApp",
            IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtKey))
        };
    });

builder.Services.AddAuthorization();

// Add controllers
builder.Services.AddControllers();

// Swagger with JWT support
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new OpenApiInfo
    {
        Title = "AutoWash Pro API",
        Version = "v1",
        Description = "API cho hệ thống quản lý rửa xe tự động thông minh AutoWash Pro"
    });

    c.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
    {
        Description = "JWT Authorization header. Nhập: Bearer {token}",
        Name = "Authorization",
        In = ParameterLocation.Header,
        Type = SecuritySchemeType.ApiKey,
        Scheme = "Bearer"
    });

    c.AddSecurityRequirement(new OpenApiSecurityRequirement
    {
        {
            new OpenApiSecurityScheme
            {
                Reference = new OpenApiReference
                {
                    Type = ReferenceType.SecurityScheme,
                    Id = "Bearer"
                }
            },
            Array.Empty<string>()
        }
    });
});

// CORS
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", policy =>
    {
        policy.AllowAnyOrigin()
              .AllowAnyMethod()
              .AllowAnyHeader();
    });
});

var app = builder.Build();

// Seed database
using (var scope = app.Services.CreateScope())
{
    var context = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
    await context.Database.MigrateAsync();
    
    // Dynamically add columns for Staff features if they don't exist
    try
    {
        await context.Database.ExecuteSqlRawAsync(@"
            ALTER TABLE ""Bookings"" ADD COLUMN IF NOT EXISTS ""StaffId"" uuid NULL;
            ALTER TABLE ""Bookings"" ADD COLUMN IF NOT EXISTS ""Checklist"" text NULL;
            ALTER TABLE ""Bookings"" ADD COLUMN IF NOT EXISTS ""CompletionImageUrl"" text NULL;
            ALTER TABLE ""Bookings"" ADD COLUMN IF NOT EXISTS ""CompletedAt"" timestamp with time zone NULL;
        ");

        // Create Chemicals table
        await context.Database.ExecuteSqlRawAsync(@"
            CREATE TABLE IF NOT EXISTS ""Chemicals"" (
                ""Id"" uuid PRIMARY KEY,
                ""Name"" character varying(100) NOT NULL,
                ""Unit"" character varying(50) NOT NULL,
                ""CurrentStock"" numeric(18,2) NOT NULL DEFAULT 0,
                ""MinimumStock"" numeric(18,2) NOT NULL DEFAULT 0,
                ""CreatedAt"" timestamp with time zone NOT NULL DEFAULT NOW(),
                ""UpdatedAt"" timestamp with time zone NOT NULL DEFAULT NOW()
            );
        ");

        // Create ServiceChemicals table
        await context.Database.ExecuteSqlRawAsync(@"
            CREATE TABLE IF NOT EXISTS ""ServiceChemicals"" (
                ""Id"" uuid PRIMARY KEY,
                ""ServiceId"" uuid NOT NULL REFERENCES ""Services""(""Id"") ON DELETE CASCADE,
                ""ChemicalId"" uuid NOT NULL REFERENCES ""Chemicals""(""Id"") ON DELETE CASCADE,
                ""QuantityPerWash"" numeric(18,2) NOT NULL DEFAULT 0,
                UNIQUE(""ServiceId"", ""ChemicalId"")
            );
        ");

        // Create ChemicalLogs table
        await context.Database.ExecuteSqlRawAsync(@"
            CREATE TABLE IF NOT EXISTS ""ChemicalLogs"" (
                ""Id"" uuid PRIMARY KEY,
                ""ChemicalId"" uuid NOT NULL REFERENCES ""Chemicals""(""Id"") ON DELETE CASCADE,
                ""ChangeAmount"" numeric(18,2) NOT NULL,
                ""Reason"" character varying(500) NOT NULL,
                ""BookingId"" uuid NULL REFERENCES ""Bookings""(""Id"") ON DELETE SET NULL,
                ""CreatedAt"" timestamp with time zone NOT NULL DEFAULT NOW()
            );
        ");

        // Create Reviews table
        await context.Database.ExecuteSqlRawAsync(@"
            CREATE TABLE IF NOT EXISTS ""Reviews"" (
                ""Id"" uuid PRIMARY KEY,
                ""BookingId"" uuid NOT NULL UNIQUE REFERENCES ""Bookings""(""Id"") ON DELETE CASCADE,
                ""UserId"" uuid NOT NULL REFERENCES ""Users""(""Id"") ON DELETE CASCADE,
                ""Rating"" integer NOT NULL,
                ""Comment"" character varying(1000) NULL,
                ""CreatedAt"" timestamp with time zone NOT NULL DEFAULT NOW()
            );
        ");
    }
    catch (Exception ex)
    {
        Console.WriteLine($"Error adding staff columns: {ex.Message}");
    }

    await DbSeeder.SeedAsync(context);
}

// Configure pipeline
app.UseSwagger();
app.UseSwaggerUI(c =>
{
    c.SwaggerEndpoint("/swagger/v1/swagger.json", "AutoWash Pro API v1");
});

app.UseCors("AllowAll");
app.UseAuthentication();
app.UseAuthorization();
app.MapControllers();

app.Run();

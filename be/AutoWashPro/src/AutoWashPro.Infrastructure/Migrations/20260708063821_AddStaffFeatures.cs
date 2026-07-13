using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace AutoWashPro.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class AddStaffFeatures : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {

            migrationBuilder.AddColumn<string>(
                name: "Checklist",
                table: "Bookings",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<DateTime>(
                name: "CompletedAt",
                table: "Bookings",
                type: "timestamp without time zone",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "CompletionImageUrl",
                table: "Bookings",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<Guid>(
                name: "StaffId",
                table: "Bookings",
                type: "uuid",
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "Checklist",
                table: "Bookings");

            migrationBuilder.DropColumn(
                name: "CompletedAt",
                table: "Bookings");

            migrationBuilder.DropColumn(
                name: "CompletionImageUrl",
                table: "Bookings");

            migrationBuilder.DropColumn(
                name: "StaffId",
                table: "Bookings");
        }
    }
}

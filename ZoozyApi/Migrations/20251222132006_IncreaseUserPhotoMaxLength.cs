using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace ZoozyApi.Migrations
{
    /// <inheritdoc />
    public partial class IncreaseUserPhotoMaxLength : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            // UserPhoto kolonunu NVARCHAR(MAX) yap
            migrationBuilder.AlterColumn<string>(
                name: "UserPhoto",
                table: "UserRequests",
                type: "nvarchar(max)",
                nullable: true,
                oldClrType: typeof(string),
                oldType: "nvarchar(5000)",
                oldMaxLength: 5000,
                oldNullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            // Geri alma: NVARCHAR(5000) yap
            migrationBuilder.AlterColumn<string>(
                name: "UserPhoto",
                table: "UserRequests",
                type: "nvarchar(5000)",
                maxLength: 5000,
                nullable: true,
                oldClrType: typeof(string),
                oldType: "nvarchar(max)",
                oldNullable: true);
        }
    }
}

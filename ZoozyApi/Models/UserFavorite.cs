using System.ComponentModel.DataAnnotations;

namespace ZoozyApi.Models;

/// <summary>
/// Kullanıcının favorileri (Explore, Moments, Caregiver)
/// </summary>
public class UserFavorite
{
    public int Id { get; set; }
    
    [Required]
    public int UserId { get; set; }
    
    [Required]
    [MaxLength(200)]
    public string Title { get; set; } = string.Empty;
    
    [MaxLength(500)]
    public string? Subtitle { get; set; }
    
    [MaxLength(1000)]
    public string? ImageUrl { get; set; }
    
    [MaxLength(1000)]
    public string? ProfileImageUrl { get; set; }
    
    [Required]
    [MaxLength(50)]
    public string Tip { get; set; } = string.Empty; // "explore", "moments", "caregiver"
    
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    
    // Navigation
    public User? User { get; set; }
}


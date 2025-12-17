using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using ZoozyApi.Data;
using ZoozyApi.Models;

namespace ZoozyApi.Controllers;

[ApiController]
[Route("api/[controller]")]
public class UserServicesController : ControllerBase
{
    private readonly AppDbContext _context;

    public UserServicesController(AppDbContext context)
    {
        _context = context;
    }

    // GET: api/UserServices?userId=1
    [HttpGet]
    public async Task<ActionResult<IEnumerable<UserService>>> GetUserServices([FromQuery] int? userId)
    {
        var query = _context.UserServices.AsQueryable();

        if (userId.HasValue)
        {
            query = query.Where(s => s.UserId == userId.Value);
        }

        var services = await query
            .OrderByDescending(s => s.CreatedAt)
            .ToListAsync();

        return Ok(services);
    }

    // GET: api/UserServices/others?excludeUserId=1
    // Login olan kullanıcı hariç tüm kullanıcıların job'larını getir
    [HttpGet("others")]
    public async Task<ActionResult<IEnumerable<object>>> GetOtherUsersServices([FromQuery] int excludeUserId)
    {
        var services = await _context.UserServices
            .Where(s => s.UserId != excludeUserId)
            .Join(
                _context.Users,
                service => service.UserId,
                user => user.Id,
                (service, user) => new
                {
                    Id = service.Id,
                    UserId = service.UserId,
                    ServiceName = service.ServiceName,
                    ServiceIcon = service.ServiceIcon,
                    Price = service.Price,
                    Description = service.Description,
                    Address = service.Address,
                    CreatedAt = service.CreatedAt,
                    UpdatedAt = service.UpdatedAt,
                    // Kullanıcı bilgileri
                    UserDisplayName = user.DisplayName,
                    UserEmail = user.Email,
                    UserPhotoUrl = user.PhotoUrl
                }
            )
            .OrderByDescending(s => s.CreatedAt)
            .ToListAsync();

        return Ok(services);
    }

    // GET: api/UserServices/5
    [HttpGet("{id}")]
    public async Task<ActionResult<UserService>> GetUserService(int id)
    {
        var service = await _context.UserServices.FindAsync(id);

        if (service == null)
        {
            return NotFound();
        }

        return Ok(service);
    }

    // POST: api/UserServices
    [HttpPost]
    public async Task<ActionResult<UserService>> CreateUserService([FromBody] UserService service)
    {
        // UserId validation
        var userExists = await _context.Users.AnyAsync(u => u.Id == service.UserId);
        if (!userExists)
        {
            return BadRequest(new { message = "Geçersiz kullanıcı ID." });
        }

        service.CreatedAt = DateTime.UtcNow;
        service.UpdatedAt = DateTime.UtcNow;

        _context.UserServices.Add(service);
        await _context.SaveChangesAsync();

        return CreatedAtAction(nameof(GetUserService), new { id = service.Id }, service);
    }

    // PUT: api/UserServices/5
    [HttpPut("{id}")]
    public async Task<IActionResult> UpdateUserService(int id, [FromBody] UserService updatedService)
    {
        if (id != updatedService.Id)
        {
            return BadRequest();
        }

        var existing = await _context.UserServices.FindAsync(id);
        if (existing == null)
        {
            return NotFound();
        }

        existing.ServiceName = updatedService.ServiceName;
        existing.ServiceIcon = updatedService.ServiceIcon;
        existing.Price = updatedService.Price;
        existing.Description = updatedService.Description;
        existing.Address = updatedService.Address;
        existing.UpdatedAt = DateTime.UtcNow;

        try
        {
            await _context.SaveChangesAsync();
        }
        catch (DbUpdateConcurrencyException)
        {
            if (!await _context.UserServices.AnyAsync(s => s.Id == id))
            {
                return NotFound();
            }
            throw;
        }

        return NoContent();
    }

    // DELETE: api/UserServices/5
    [HttpDelete("{id}")]
    public async Task<IActionResult> DeleteUserService(int id)
    {
        var service = await _context.UserServices.FindAsync(id);
        if (service == null)
        {
            return NotFound();
        }

        _context.UserServices.Remove(service);
        await _context.SaveChangesAsync();

        return NoContent();
    }
}


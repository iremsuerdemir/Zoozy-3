using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using ZoozyApi.Data;
using ZoozyApi.Models;

namespace ZoozyApi.Controllers;

[ApiController]
[Route("api/[controller]")]
public class UserRequestsController : ControllerBase
{
    private readonly AppDbContext _context;

    public UserRequestsController(AppDbContext context)
    {
        _context = context;
    }

    // GET: api/UserRequests?userId=1
    [HttpGet]
    public async Task<ActionResult<IEnumerable<UserRequest>>> GetUserRequests([FromQuery] int? userId)
    {
        var query = _context.UserRequests.AsQueryable();

        if (userId.HasValue)
        {
            query = query.Where(r => r.UserId == userId.Value);
        }

        var requests = await query
            .OrderByDescending(r => r.CreatedAt)
            .ToListAsync();

        return Ok(requests);
    }

    // GET: api/UserRequests/5
    [HttpGet("{id}")]
    public async Task<ActionResult<UserRequest>> GetUserRequest(int id)
    {
        var request = await _context.UserRequests.FindAsync(id);

        if (request == null)
        {
            return NotFound();
        }

        return Ok(request);
    }

    // POST: api/UserRequests
    [HttpPost]
    public async Task<ActionResult<UserRequest>> CreateUserRequest([FromBody] UserRequest request)
    {
        // UserId validation
        var userExists = await _context.Users.AnyAsync(u => u.Id == request.UserId);
        if (!userExists)
        {
            return BadRequest(new { message = "Geçersiz kullanıcı ID." });
        }

        request.CreatedAt = DateTime.UtcNow;
        request.UpdatedAt = DateTime.UtcNow;

        _context.UserRequests.Add(request);
        await _context.SaveChangesAsync();

        return CreatedAtAction(nameof(GetUserRequest), new { id = request.Id }, request);
    }

    // PUT: api/UserRequests/5
    [HttpPut("{id}")]
    public async Task<IActionResult> UpdateUserRequest(int id, [FromBody] UserRequest updatedRequest)
    {
        if (id != updatedRequest.Id)
        {
            return BadRequest();
        }

        var existing = await _context.UserRequests.FindAsync(id);
        if (existing == null)
        {
            return NotFound();
        }

        existing.PetName = updatedRequest.PetName;
        existing.ServiceName = updatedRequest.ServiceName;
        existing.UserPhoto = updatedRequest.UserPhoto;
        existing.StartDate = updatedRequest.StartDate;
        existing.EndDate = updatedRequest.EndDate;
        existing.DayDiff = updatedRequest.DayDiff;
        existing.Note = updatedRequest.Note;
        existing.Location = updatedRequest.Location;
        existing.UpdatedAt = DateTime.UtcNow;

        try
        {
            await _context.SaveChangesAsync();
        }
        catch (DbUpdateConcurrencyException)
        {
            if (!await _context.UserRequests.AnyAsync(r => r.Id == id))
            {
                return NotFound();
            }
            throw;
        }

        return NoContent();
    }

    // DELETE: api/UserRequests/5
    [HttpDelete("{id}")]
    public async Task<IActionResult> DeleteUserRequest(int id)
    {
        var request = await _context.UserRequests.FindAsync(id);
        if (request == null)
        {
            return NotFound();
        }

        _context.UserRequests.Remove(request);
        await _context.SaveChangesAsync();

        return NoContent();
    }
}


using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using ZoozyApi.Data;
using ZoozyApi.Models;

namespace ZoozyApi.Controllers;

[ApiController]
[Route("api/[controller]")]
public class UserCommentsController : ControllerBase
{
    private readonly AppDbContext _context;

    public UserCommentsController(AppDbContext context)
    {
        _context = context;
    }

    // GET: api/UserComments?cardId=moment_xxx
    [HttpGet]
    public async Task<ActionResult<IEnumerable<UserComment>>> GetUserComments([FromQuery] string? cardId)
    {
        var query = _context.UserComments.AsQueryable();

        if (!string.IsNullOrEmpty(cardId))
        {
            query = query.Where(c => c.CardId == cardId);
        }

        var comments = await query
            .OrderByDescending(c => c.CreatedAt)
            .ToListAsync();

        return Ok(comments);
    }

    // GET: api/UserComments/5
    [HttpGet("{id}")]
    public async Task<ActionResult<UserComment>> GetUserComment(int id)
    {
        var comment = await _context.UserComments.FindAsync(id);

        if (comment == null)
        {
            return NotFound();
        }

        return Ok(comment);
    }

    // POST: api/UserComments
    [HttpPost]
    public async Task<ActionResult<UserComment>> CreateUserComment([FromBody] UserComment comment)
    {
        // UserId validation
        var userExists = await _context.Users.AnyAsync(u => u.Id == comment.UserId);
        if (!userExists)
        {
            return BadRequest(new { message = "Geçersiz kullanıcı ID." });
        }

        comment.CreatedAt = DateTime.UtcNow;

        _context.UserComments.Add(comment);
        await _context.SaveChangesAsync();

        return CreatedAtAction(nameof(GetUserComment), new { id = comment.Id }, comment);
    }

    // DELETE: api/UserComments/5
    [HttpDelete("{id}")]
    public async Task<IActionResult> DeleteUserComment(int id)
    {
        var comment = await _context.UserComments.FindAsync(id);
        if (comment == null)
        {
            return NotFound();
        }

        _context.UserComments.Remove(comment);
        await _context.SaveChangesAsync();

        return NoContent();
    }

    // DELETE: api/UserComments/by-card?cardId=moment_xxx
    [HttpDelete("by-card")]
    public async Task<IActionResult> DeleteCommentsByCard([FromQuery] string cardId)
    {
        var comments = await _context.UserComments
            .Where(c => c.CardId == cardId)
            .ToListAsync();

        if (!comments.Any())
        {
            return NotFound();
        }

        _context.UserComments.RemoveRange(comments);
        await _context.SaveChangesAsync();

        return NoContent();
    }
}


using Microsoft.AspNetCore.Mvc;
using TaxiServer.Abstractions;
using TaxiServer.Models.Users;

namespace TaxiServer.Controllers;

[ApiController]
[Route("api/driver")]
public class DriverController: Controller
{
    private readonly IDriverRepository _driverRepository;

    public DriverController(IDriverRepository driverRepository)
    {
        _driverRepository = driverRepository;
    }
    
    [HttpGet("profile/{id}")]
    public async Task<ActionResult<DriverProfile>> GetProfile(string id)
    {
        var profile = await _driverRepository.GetDriver(id);
        if (profile == null) return NotFound();
        return Ok(profile);
    }

    [HttpPut("profile")]
    public async Task<ActionResult<DriverProfile>> UpdateProfile([FromBody] Driver driver)
    {
        var profile = await _driverRepository.UpdateDriver(driver.Id, driver);
        if (profile == null) return NotFound();
        return Ok(profile);
    }

    [HttpPost]
    public async Task<ActionResult<DriverProfile>> CreateProfile(Driver driver)
    {
        var profile = await _driverRepository.CreateDriver(driver);
        if (profile == null) return Conflict(new { message = "User with this ID already exists." });
        return Created($"api/driver/profile/{driver.Id}", profile);
    }

    [HttpGet("ride-history/{id}")]
    public async Task<ActionResult<DriverProfile>> GetRideHistory(string id)
    {
        return Ok(new { FirstName = id, LastName = id });
    }
}
using Microsoft.AspNetCore.Mvc;
using TaxiServer.Abstractions;
using TaxiServer.Models.Users;
using TaxiServer.Models.Vehicle;

namespace TaxiServer.Controllers;

[ApiController]
[Route("api/driver")]
public class DriverController : Controller
{
    private readonly IDriverRepository _driverRepository;
    private readonly IPricingService _pricingService;

    public DriverController(IDriverRepository driverRepository, IPricingService pricingService)
    {
        _driverRepository = driverRepository;
        _pricingService = pricingService;
    }

    [HttpGet("{id}")]
    public async Task<ActionResult<Driver>> GetProfile(string id)
    {
        var profile = await _driverRepository.GetDriver(id);
        if (profile == null) return NotFound();
        return Ok(profile);
    }

    [HttpPut]
    public async Task<ActionResult<Driver>> UpdateProfile([FromBody] Driver driver)
    {
        var profile = await _driverRepository.UpdateDriver(driver.Id, driver);
        if (profile == null) return NotFound();
        return Ok(profile);
    }

    [HttpPost]
    public async Task<ActionResult<Driver>> CreateProfile(Driver driver)
    {
        var profile = await _driverRepository.CreateDriver(driver);
        if (profile == null) return Conflict(new { message = "User with this ID already exists." });
        return Created($"api/driver/profile/{driver.Id}", profile);
    }

    [HttpGet("ride-history/{id}")]
    public async Task<ActionResult<Driver>> GetRideHistory(string id)
    {
        return Ok(new { FirstName = id, LastName = id });
    }

    [HttpGet("car-types")]
    public async Task<ActionResult<List<CarType>>> GetCarTypes()
    {
        var prices = await _pricingService.GetCarTypeList();
        return Ok(prices);
    }
}
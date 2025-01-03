using Microsoft.AspNetCore.Mvc;
using TaxiServer.Abstractions;
using TaxiServer.Models.Ride;

namespace TaxiServer.Controllers;

[ApiController]
[Route("api/ride")]
public class RideController : Controller
{
    private readonly IRideRepository _rideRepository;


    public RideController(IRideRepository rideRepository)
    {
        _rideRepository = rideRepository;
    }

    [HttpGet("{id}/status")]
    public async Task<ActionResult<RideStatus>> GetRideStatus(string id)
    {
        var ride = await _rideRepository.GetRide(id);
        if (ride == null) return NotFound();
        return Ok(new RideStatus
        {
            Status = ride.status,
        });
    }
}
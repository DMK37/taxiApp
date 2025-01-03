using Google.Type;
using Microsoft.AspNetCore.Mvc;
using TaxiServer.Abstractions;
using TaxiServer.Models.Ride;
using TaxiServer.Models.Users;

namespace TaxiServer.Controllers
{
    [ApiController]
    [Route("api/client")]
    public class ClientController : Controller
    {
        private readonly IClientRepository _clientRepository;
        private readonly IPricingService _pricingService;

        public ClientController(IClientRepository clientRepository, IPricingService pricingService)
        {
            _clientRepository = clientRepository;
            _pricingService = pricingService;
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<Client>> GetProfile(string id)
        {
            var profile = await _clientRepository.GetClient(id);

            if (profile == null) return NotFound();
            return Ok(profile);
        }

        [HttpPut]
        public async Task<ActionResult<Client>> UpdateProfile([FromBody] Client client)
        {
            var resp = await _clientRepository.UpdateClient(client.Id, client);
            if (resp == null) return NotFound();
            return Ok(resp);
        }

        [HttpPost]
        public async Task<ActionResult<Client>> CreateProfile(Client client)
        {
            var resp = await _clientRepository.CreateClient(client);
            if (resp == null) return Conflict(new { message = "User with this ID already exists." });
            return Created($"api/client/profile/{client.Id}", resp);
        }

        [HttpGet("ride-history/{id}")]
        public async Task<ActionResult<Client>> GetRideHistory(string id)
        {
            return Ok(new { FirstName = id, LastName = id });
        }

        [HttpGet("prices")]
        public async Task<ActionResult<List<RidePrice>>> GetPrices([FromQuery] string source,
            [FromQuery] string destination, [FromQuery] int distance)
        {
            if (string.IsNullOrEmpty(source) || string.IsNullOrEmpty(destination))
            {
                return BadRequest("Query parameter 'source' and 'destination' is required.");
            }

            var parts = source.Split(',');
            var parts2 = destination.Split(',');
            if (parts.Length != 2 || !double.TryParse(parts[0], out double latitude) ||
                !double.TryParse(parts[1], out double longitude)
                || parts2.Length != 2 || !double.TryParse(parts2[0], out double latitude2) ||
                !double.TryParse(parts2[1], out double longitude2))
            {
                return BadRequest(
                    "Query parameter 'source' and 'destination' must be in the format 'latitude,longitude'.");
            }

            LatLng src = new LatLng
            {
                Latitude = latitude,
                Longitude = longitude
            };

            LatLng dest = new LatLng
            {
                Latitude = latitude2,
                Longitude = longitude2
            };
            var prices = await _pricingService.CalculateTaxiPrice(src, dest, distance);
            return Ok(prices);
        }

    }
}

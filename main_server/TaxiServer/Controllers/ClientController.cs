using Google.Type;
using Microsoft.AspNetCore.Mvc;
using TaxiServer.Abstractions;
using TaxiServer.Models.Price;
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
        public async Task<ActionResult<List<RidePrice>>> GetPrices([FromQuery] LatLng source,
            [FromQuery] LatLng destination, [FromQuery] int distance)
        {
            var prices = await _pricingService.CalculateTaxiPrice(source, destination, distance);
            return Ok(prices);
        }

    }
}

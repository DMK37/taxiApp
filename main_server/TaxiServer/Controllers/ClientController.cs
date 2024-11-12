using Microsoft.AspNetCore.Mvc;
using TaxiServer.Abstractions;
using TaxiServer.Models.Users;

namespace TaxiServer.Controllers
{
    [ApiController]
    [Route("api/client")]
    public class ClientController : Controller
    {
        private readonly IClientRepository _clientRepository;

        public ClientController(IClientRepository clientRepository)
        {
            _clientRepository = clientRepository;
        }

        [HttpGet("profile/{id}")]
        public async Task<ActionResult<ClientProfile>> GetProfile(string id)
        {
            ClientProfile? profile = await _clientRepository.GetClient(id);
            
            if (profile == null) return NotFound();
            return Ok(profile);
        }

        [HttpPut("profile")]
        public async Task<ActionResult<ClientProfile>> UpdateProfile([FromBody] Client client)
        {
            var resp = await _clientRepository.UpdateClient(client.Id, client);
            if (resp == null) return NotFound();
            return Ok(resp);
        }

        [HttpPost]
        public async Task<ActionResult<ClientProfile>> CreateProfile(Client client)
        {
            var resp = await _clientRepository.CreateClient(client);
            if (resp == null) return Conflict(new { message = "User with this ID already exists." });
            return Created($"api/client/profile/{client.Id}", resp);
        }

        [HttpGet("ride-history/{id}")]
        public async Task<ActionResult<ClientProfile>> GetRideHistory(string id)
        {
            return Ok(new { FirstName = id, LastName = id });
        }
        
    }
}

using Microsoft.AspNetCore.Mvc;

namespace TaxiAppServer.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class TaxiClassesController : Controller
    {
        [HttpGet]
        public IActionResult GetTaxiClasses()
        {
            var taxiClasses = new[]
            {
                new {Class = "Economy", Description = "Affordable and basic rides" },
                new {Class = "Family", Description = "Spacious rides for families" },
                new {Class = "Comfort", Description = "Comfortable and premium rides" }
            };

            return Ok(taxiClasses);
        }
    }
}

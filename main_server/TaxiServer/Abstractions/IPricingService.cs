using Google.Type;
using TaxiServer.Models.Price;

namespace TaxiServer.Abstractions;

public interface IPricingService
{
    Task<List<RidePrice>> CalculateTaxiPrice(LatLng source, LatLng destination, int distance);
}
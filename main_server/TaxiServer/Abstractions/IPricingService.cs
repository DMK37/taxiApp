using Google.Type;
using TaxiServer.Models.Price;
using TaxiServer.Models.Vehicle;

namespace TaxiServer.Abstractions;

public interface IPricingService
{
    Task<List<RidePrice>> CalculateTaxiPrice(LatLng source, LatLng destination, int distance);
    Task<List<CarType>> GetCarTypeList();
}
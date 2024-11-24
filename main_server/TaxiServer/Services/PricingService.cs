using Google.Type;
using TaxiServer.Abstractions;
using TaxiServer.Models.Price;

namespace TaxiServer.Services;

public class PricingService : IPricingService
{
    public async Task<List<RidePrice>> CalculateTaxiPrice(LatLng source, LatLng destination, int distance)
    {
        // calculate distance to price
        decimal baseFare = 3.00m;
        decimal km = (decimal)distance / 1000;
        decimal basePrice = (baseFare + km) / 2000;
        basePrice = Math.Round(basePrice, 4);
        // TODO: fetch all active drivers of each type in area of 15 km
        // return list for all available types
        return
        [
            new RidePrice
            {
                Type = "Basic",
                Amount = basePrice
            },
            new RidePrice
            {
                Type = "Comfort",
                Amount = basePrice * 1.5m
            },
            new RidePrice
            {
                Type = "Premium",
                Amount = basePrice * 2
            }
        ];
    }
}
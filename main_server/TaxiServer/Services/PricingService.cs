using Google.Type;
using TaxiServer.Abstractions;
using TaxiServer.Models.Vehicle;
using TaxiServer.Models.Ride;

namespace TaxiServer.Services;

public class PricingService : IPricingService { 
    public async Task<List<CarType>> GetCarTypeList()
    {
        return
        [
            CarType.Basic,
            CarType.Comfort,
            CarType.Premium,
        ];
    }
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
                Type = CarType.Basic,
                Amount = basePrice
            },
            new RidePrice
            {
                Type = CarType.Comfort,
                Amount = basePrice * 1.5m
            },
            new RidePrice
            {
                Type = CarType.Premium,
                Amount = basePrice * 2
            }
        ];
    }
}
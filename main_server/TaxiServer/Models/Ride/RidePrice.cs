using TaxiServer.Models.Vehicle;

namespace TaxiServer.Models.Ride;

public class RidePrice
{
    public CarType Type { get; set; }
    public decimal Amount { get; set; }
}
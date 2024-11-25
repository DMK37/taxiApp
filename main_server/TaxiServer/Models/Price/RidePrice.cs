using TaxiServer.Models.Car;

namespace TaxiServer.Models.Price;

public class RidePrice
{
    public CarType Type { get; set; }
    public decimal Amount { get; set; }
}
using Google.Type;
using TaxiServer.Models.Vehicle;

namespace TaxiServer.Models.Users;

public class RealtimeDriverInfo
{
    public string Id { get; set; }
    public LatLng Location { get; set; }
    public Car Car { get; set; }
}
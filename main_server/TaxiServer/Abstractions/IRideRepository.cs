using TaxiServer.Models.Ride;

namespace TaxiServer.Abstractions;

public interface IRideRepository
{
    Task<Ride?> GetRide(string rideId);
}
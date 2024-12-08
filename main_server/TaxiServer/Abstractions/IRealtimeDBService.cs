using Google.Type;
using TaxiServer.Models.Users;

namespace TaxiServer.Abstractions;

public interface IRealtimeDBService
{
    Task<List<RealtimeDriverInfo>> getDriversNearLocation(LatLng location);
}
using TaxiServer.Models.Users;

namespace TaxiServer.Abstractions;

public interface IDriverRepository
{
    Task<DriverProfile?> GetDriver(string driverId);
    Task<DriverProfile?> UpdateDriver(string id, Driver driver);
    Task<DriverProfile?> CreateDriver(Driver driver);
}
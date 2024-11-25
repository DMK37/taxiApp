using TaxiServer.Models.Users;

namespace TaxiServer.Abstractions;

public interface IDriverRepository
{
    Task<Driver?> GetDriver(string driverId);
    Task<Driver?> UpdateDriver(string id, Driver driver);
    Task<Driver?> CreateDriver(Driver driver);
}
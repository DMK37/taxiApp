using TaxiServer.Abstractions;
using TaxiServer.Models.Users;

namespace TaxiServer.Data;

public class DriverRepository: IDriverRepository
{
    private const string _collectionName = "drivers";
    private readonly IFirestoreService _firestoreDb;

    public DriverRepository(IFirestoreService firestoreDb)
    {
        _firestoreDb = firestoreDb;
    }

    public async Task<DriverProfile?> GetDriver(string driverId)
    {
        var snapshot = await _firestoreDb.GetDocumentAsync(_collectionName, driverId);
        if (!snapshot.Exists) return null;
        var driver = snapshot.ConvertTo<Driver>();
        return new DriverProfile
        {
            FirstName = driver.FirstName,
            LastName = driver.LastName,
        };
    }

    public async Task<DriverProfile?> UpdateDriver(string id, Driver driver)
    {
        var result = await _firestoreDb.UpdateDocumentAsync(_collectionName, id, driver);
        if (result == null) return null;

        return new DriverProfile
        {
            FirstName = driver.FirstName,
            LastName = driver.LastName,
        };
    }

    public async Task<DriverProfile?> CreateDriver(Driver driver)
    {
        var result = await _firestoreDb.AddDocumentAsync(_collectionName, driver, driver.Id);
        if (result == null) return null;

        return new DriverProfile
        {
            FirstName = driver.FirstName,
            LastName = driver.LastName,
        };
    }
}
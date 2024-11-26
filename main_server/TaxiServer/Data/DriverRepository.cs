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

    public async Task<Driver?> GetDriver(string driverId)
    {
        var snapshot = await _firestoreDb.GetDocumentAsync(_collectionName, driverId);
        if (!snapshot.Exists) return null;
        var driver = snapshot.ConvertTo<Driver>();
        return driver;
    }

    public async Task<Driver?> UpdateDriver(string id, Driver driver)
    {
        var result = await _firestoreDb.UpdateDocumentAsync(_collectionName, id, driver);
        return result;
    }

    public async Task<Driver?> CreateDriver(Driver driver)
    {
        var result = await _firestoreDb.AddDocumentAsync(_collectionName, driver, driver.Id);
        return result;
    }
}
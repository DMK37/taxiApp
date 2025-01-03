using TaxiServer.Abstractions;
using TaxiServer.Models.Ride;

namespace TaxiServer.Data;

public class RideRepository: IRideRepository
{
    private const string _collectionName = "rides";
    private readonly IFirestoreService _firestoreDb;

    public RideRepository(IFirestoreService firestoreDb)
    {
        _firestoreDb = firestoreDb;
    }

    public async Task<Ride?> GetRide(string rideId)
    {
        var snapshot = await _firestoreDb.GetDocumentAsync(_collectionName, rideId);
        if (!snapshot.Exists) return null;
        var ride = snapshot.ConvertTo<Ride>();
        return ride;
    }
}
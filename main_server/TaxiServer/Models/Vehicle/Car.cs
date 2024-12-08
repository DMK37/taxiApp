using Google.Cloud.Firestore;

namespace TaxiServer.Models.Vehicle;

[FirestoreData]
public class Car
{
    [FirestoreProperty] public string CarName { get; set; }
    [FirestoreProperty] public CarType CarType { get; set; }
}
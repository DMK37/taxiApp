using Google.Cloud.Firestore;

namespace TaxiServer.Models.Car;

[FirestoreData]
public class Car
{
    [FirestoreProperty] public string CarName { get; set; }
    [FirestoreProperty] public CarType CarType { get; set; }
}
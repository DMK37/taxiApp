using Google.Cloud.Firestore;
using TaxiServer.Models.Vehicle;

namespace TaxiServer.Models.Users;

[FirestoreData]
public class Driver
{
    [FirestoreDocumentId] public string Id { get; set; }

    [FirestoreProperty] public string FirstName { get; set; }

    [FirestoreProperty] public string LastName { get; set; }

    [FirestoreProperty] public Car Car { get; set; }
}
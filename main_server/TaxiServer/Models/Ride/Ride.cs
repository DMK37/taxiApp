using Google.Cloud.Firestore;

namespace TaxiServer.Models.Ride;

[FirestoreData]
public class Ride
{
    [FirestoreDocumentId] public string client { get; set; }

    [FirestoreProperty] public string? driver { get; set; }

    [FirestoreProperty] public string cost { get; set; }

    [FirestoreProperty] public string status { get; set; }
}
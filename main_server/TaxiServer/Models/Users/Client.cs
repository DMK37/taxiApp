using Google.Cloud.Firestore;

namespace TaxiServer.Models.Users;

[FirestoreData]
public class Client
{
    [FirestoreDocumentId] public string Id { get; set; }

    [FirestoreProperty] public string FirstName { get; set; }

    [FirestoreProperty] public string LastName { get; set; }
}
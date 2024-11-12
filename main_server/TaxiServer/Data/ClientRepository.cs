using Google.Cloud.Firestore;
using TaxiServer.Abstractions;
using TaxiServer.Models.Users;

namespace TaxiServer.Data;

public class ClientRepository : IClientRepository
{
    private const string _collectionName = "clients";
    private readonly IFirestoreService _firestoreDb;

    public ClientRepository(IFirestoreService firestoreDb)
    {
        _firestoreDb = firestoreDb;
    }

    public async Task<ClientProfile?> GetClient(string clientId)
    {
        var snapshot = await _firestoreDb.GetDocumentAsync(_collectionName, clientId);
        if (!snapshot.Exists)
        {
            return null;
        }
        var client = snapshot.ConvertTo<Client>();
        return new ClientProfile
        {
            FirstName = client.FirstName,
            LastName = client.LastName
        };
    }

    public async Task<ClientProfile?> UpdateClient(string id, Client client)
    {
        var response = await _firestoreDb.UpdateDocumentAsync(_collectionName, id, client);
        if (response == null) return null;

        return new ClientProfile
        {
            FirstName = response.FirstName,
            LastName = response.LastName,
        };
    }

    public async Task<ClientProfile?> CreateClient(Client client)
    {
        var response = await _firestoreDb.AddDocumentAsync(_collectionName, client, client.Id);
        if (response == null) return null;

        return new ClientProfile
        {
            FirstName = response.FirstName,
            LastName = response.LastName,
        };
    }
}
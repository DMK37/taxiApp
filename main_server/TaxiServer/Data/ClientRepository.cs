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

    public async Task<Client?> GetClient(string clientId)
    {
        var snapshot = await _firestoreDb.GetDocumentAsync(_collectionName, clientId);
        if (!snapshot.Exists)
        {
            return null;
        }
        var client = snapshot.ConvertTo<Client>();
        return client;
    }

    public async Task<Client?> UpdateClient(string id, Client client)
    {
        var response = await _firestoreDb.UpdateDocumentAsync(_collectionName, id, client);
        return response;
    }

    public async Task<Client?> CreateClient(Client client)
    {
        var response = await _firestoreDb.AddDocumentAsync(_collectionName, client, client.Id);
        return response;
    }
}
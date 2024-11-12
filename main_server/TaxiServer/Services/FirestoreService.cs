using Google.Cloud.Firestore;
using TaxiServer.Abstractions;

namespace TaxiServer.Services;

public class FirestoreService : IFirestoreService
{
    private readonly FirestoreDb _firestoreDb;

    public FirestoreService(FirestoreDb firestoreDb)
    {
        _firestoreDb = firestoreDb;
    }

    public async Task<T?> AddDocumentAsync<T>(string collectionName, T data, string id) where T : class
    {
        var docRef = _firestoreDb.Collection(collectionName).Document(id);
        
        if (docRef == null) return null;
        var snapshot = await docRef.GetSnapshotAsync();
        
        if (snapshot.Exists) return null;
        await docRef.SetAsync(data);
        return data;
    }

    public async Task<DocumentSnapshot> GetDocumentAsync(string collectionName, string documentId)
    {
        DocumentReference document = _firestoreDb.Collection(collectionName).Document(documentId);
        return await document.GetSnapshotAsync();
    }

    public async Task<T?> UpdateDocumentAsync<T>(string collectionName, string documentId, T data) where T : class
    {
        var document = _firestoreDb.Collection(collectionName).Document(documentId);
        
        if (document == null) return null;
        var snapshot = await document.GetSnapshotAsync();
        
        if (snapshot.Exists) return null;
        await document.SetAsync(data, SetOptions.MergeAll);
        return data;
    }

    public async Task DeleteDocumentAsync(string collectionName, string documentId)
    {
        DocumentReference document = _firestoreDb.Collection(collectionName).Document(documentId);
        await document.DeleteAsync();
    }
}
using Google.Cloud.Firestore;

namespace TaxiServer.Abstractions;

public interface IFirestoreService
{
    Task<T?> AddDocumentAsync<T>(string collectionName, T data, string id) where T : class;
    Task<DocumentSnapshot> GetDocumentAsync(string collectionName, string documentId);
    Task<T?> UpdateDocumentAsync<T>(string collectionName, string documentId, T data) where T : class;
    Task DeleteDocumentAsync(string collectionName, string documentId);
}
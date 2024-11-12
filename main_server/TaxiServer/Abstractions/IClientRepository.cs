using TaxiServer.Models.Users;

namespace TaxiServer.Abstractions;

public interface IClientRepository
{
    Task<ClientProfile?> GetClient(string clientId);
    Task<ClientProfile?> UpdateClient(string id, Client client);
    Task<ClientProfile?> CreateClient(Client client);
}
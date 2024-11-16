using TaxiServer.Models.Users;

namespace TaxiServer.Abstractions;

public interface IClientRepository
{
    Task<Client?> GetClient(string clientId);
    Task<Client?> UpdateClient(string id, Client client);
    Task<Client?> CreateClient(Client client);
}
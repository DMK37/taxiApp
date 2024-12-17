using Google.Type;
using Newtonsoft.Json;
using TaxiServer.Abstractions;
using TaxiServer.Models.Users;

namespace TaxiServer.Services;

public class RealtimeDBService : IRealtimeDBService
{
    string databaseUrl = "https://taxiapp-6761d-default-rtdb.europe-west1.firebasedatabase.app/";

    public async Task<List<RealtimeDriverInfo>> getDriversNearLocation(LatLng location)
    {
        using HttpClient client = new HttpClient();
        List<RealtimeDriverInfo> drivers = new List<RealtimeDriverInfo>();
        HttpResponseMessage response = await client.GetAsync(databaseUrl + "drivers");
        if (response.IsSuccessStatusCode)
        {
            string jsonData = await response.Content.ReadAsStringAsync();
            drivers = JsonConvert.DeserializeObject<List<RealtimeDriverInfo>>(jsonData) ??
                      new List<RealtimeDriverInfo>();

            Console.WriteLine("Data: " + jsonData);
        }
        else
        {
            Console.WriteLine($"Error: {response.StatusCode}");
        }

        return drivers;
    }
}
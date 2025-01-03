using Google.Type;
using TaxiServer.Models.Vehicle;
using TaxiServer.Models.Ride;
using TaxiServer.Services;

namespace TaxiAppTests.Services;

public class PricingServiceTests
{
    [Fact]
    public async Task PricingService_ShouldReturnCorrectPrice()
    {
        // Arrange
        PricingService service = new PricingService();
        var source = new LatLng
        {
            Latitude = 45,
            Longitude = 47
        };

        var destination = new LatLng
        {
            Latitude = 45,
            Longitude = 47.3
        };

        int distance = 5000;

        decimal basePrice = (3 + (decimal)distance / 1000) / 2000;
        basePrice = Math.Round(basePrice, 4);
        var expectedResult = new List<RidePrice>
        {
            new()
            {
                Type = CarType.Basic,
                Amount = basePrice
            },
            new()
            {
                Type = CarType.Comfort,
                Amount = basePrice * 1.5m
            },
            new()
            {
                Type = CarType.Premium,
                Amount = basePrice * 2
            }
        };
        // Act
        var result = await service.CalculateTaxiPrice(source, destination, distance);

        // Assert
        for (int i = 0; i < expectedResult.Count; i++)
        {
            Assert.Equal(expectedResult[i].Type, result[i].Type);
            Assert.Equal(expectedResult[i].Amount, result[i].Amount);
        }
    }
}
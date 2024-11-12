using Microsoft.AspNetCore.Mvc;
using Moq;
using TaxiServer.Abstractions;
using TaxiServer.Controllers;
using TaxiServer.Models.Users;

namespace TaxiAppTests.Controllers;

public class ClientControllerTests
{
    [Fact]
    public async Task ClientController_CreateProfile_Created()
    {
        // Arrange
        var mockClientRepository = new Mock<IClientRepository>();
        Client client = new Client
        {
            Id = "0x123456789",
            FirstName = "Alex",
            LastName = "Brown",
        };
        ClientProfile profile = new ClientProfile
        {
            FirstName = "Alex",
            LastName = "Brown",
        };
        mockClientRepository.Setup(repository => repository.CreateClient(client)).ReturnsAsync(profile);
        
        var controller = new ClientController(mockClientRepository.Object);

        
        
        // Act
        var result = await controller.CreateProfile(client);

        // Assert
        var createdResult = Assert.IsType<CreatedResult>(result.Result);
        var resultProfile = Assert.IsType<ClientProfile>(createdResult.Value);
        mockClientRepository.Verify(repository => repository.CreateClient(client), Times.Once);
        Assert.Equal(profile.FirstName, resultProfile.FirstName);
        Assert.Equal(profile.LastName, resultProfile.LastName);
    }
    
    [Fact]
    public async Task ClientController_CreateProfile_Conflict()
    {
        // Arrange
        var mockClientRepository = new Mock<IClientRepository>();
        Client client = new Client
        {
            Id = "0x123456789",
            FirstName = "Alex",
            LastName = "Brown",
        };
        
        mockClientRepository.Setup(repository => repository.CreateClient(client)).ReturnsAsync(null as ClientProfile);
        
        var controller = new ClientController(mockClientRepository.Object);
        
        // Act
        var result = await controller.CreateProfile(client);

        // Assert
        Assert.IsType<ConflictObjectResult>(result.Result);
        mockClientRepository.Verify(repository => repository.CreateClient(client), Times.Once);
    }

    [Fact]
    public async Task ClientController_GetClient_Ok()
    {
        // Arrange
        var mockClientRepository = new Mock<IClientRepository>();
        ClientProfile profile = new ClientProfile
        {
            FirstName = "Alex",
            LastName = "Brown",
        };
        mockClientRepository.Setup(repository => repository.GetClient("0x123456789")).ReturnsAsync(profile);
        
        var controller = new ClientController(mockClientRepository.Object);
        
        // Act
        var result = await controller.GetProfile("0x123456789");
        
        // Assert
        var okResult = Assert.IsType<OkObjectResult>(result.Result);
        var resultProfile = Assert.IsType<ClientProfile>(okResult.Value);
        mockClientRepository.Verify(repository => repository.GetClient("0x123456789"), Times.Once);
        Assert.Equal(profile.FirstName, resultProfile.FirstName);
        Assert.Equal(profile.LastName, resultProfile.LastName);
    }
    
    [Fact]
    public async Task ClientController_GetProfile_NotFound()
    {
        // Arrange
        var mockClientRepository = new Mock<IClientRepository>();
        

        mockClientRepository.Setup(repository => repository.GetClient("0x123456789")).ReturnsAsync(null as ClientProfile);
        
        var controller = new ClientController(mockClientRepository.Object);
        
        // Act
        var result = await controller.GetProfile("0x123456789");
        
        // Assert
        Assert.IsType<NotFoundResult>(result.Result);
        mockClientRepository.Verify(repository => repository.GetClient("0x123456789"), Times.Once);
    }

    [Fact]
    public async Task ClientController_UpdateProfile_Ok()
    {
        // Arrange
        var mockClientRepository = new Mock<IClientRepository>();
        Client client = new Client
        {
            Id = "0x123456789",
            FirstName = "Alex",
            LastName = "Brown"
        };
        ClientProfile profile = new ClientProfile
        {
            FirstName = "Alex",
            LastName = "Brown",
        };
        mockClientRepository.Setup(repository => 
            repository.UpdateClient("0x123456789", client)).ReturnsAsync(profile);
        
        var controller = new ClientController(mockClientRepository.Object);

        // Act
        var result = await controller.UpdateProfile(client);
        
        // Assert
        var okResult = Assert.IsType<OkObjectResult>(result.Result);
        var resultProfile = Assert.IsType<ClientProfile>(okResult.Value);
        mockClientRepository.Verify(repository => repository.UpdateClient("0x123456789", client), Times.Once);
        Assert.Equal(profile.FirstName, resultProfile.FirstName);
        Assert.Equal(profile.LastName, resultProfile.LastName);
    }
    
    [Fact]
    public async Task ClientController_UpdateProfile_NotFound()
    {
        // Arrange
        var mockClientRepository = new Mock<IClientRepository>();
        Client client = new Client
        {
            Id = "0x123456789",
            FirstName = "Alex",
            LastName = "Brown"
        };

        mockClientRepository.Setup(repository => 
            repository.UpdateClient("0x123456789", client)).ReturnsAsync(null as ClientProfile);
        
        var controller = new ClientController(mockClientRepository.Object);
        
        // Act
        var result = await controller.UpdateProfile(client);
        
        // Assert
        Assert.IsType<NotFoundResult>(result.Result);
        mockClientRepository.Verify(repository => repository.UpdateClient("0x123456789", client), Times.Once);
    }
}
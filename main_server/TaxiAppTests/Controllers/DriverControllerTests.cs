using Microsoft.AspNetCore.Mvc;
using Moq;
using TaxiServer.Abstractions;
using TaxiServer.Controllers;
using TaxiServer.Models.Car;
using TaxiServer.Models.Users;

namespace TaxiAppTests.Controllers;

public class DriverControllerTests
{
    [Fact]
    public async Task DriverController_CreateProfile_Created()
    {
        // Arrange
        var mockClientRepository = new Mock<IDriverRepository>();
        Driver driver = new Driver
        {
            Id = "0x123456789",
            FirstName = "Alex",
            LastName = "Brown",
            Car = new Car
            {
                CarName = "Mercedes",
                CarType = CarType.Basic
            }
        };

        mockClientRepository.Setup(repository => repository.CreateDriver(driver)).ReturnsAsync(driver);

        var controller = new DriverController(mockClientRepository.Object);



        // Act
        var result = await controller.CreateProfile(driver);

        // Assert
        var createdResult = Assert.IsType<CreatedResult>(result.Result);
        var resultProfile = Assert.IsType<Driver>(createdResult.Value);
        mockClientRepository.Verify(repository => repository.CreateDriver(driver), Times.Once);
        Assert.Equal(driver.FirstName, resultProfile.FirstName);
        Assert.Equal(driver.LastName, resultProfile.LastName);
        Assert.Equal(driver.Id, resultProfile.Id);
        Assert.Equal(driver.Car.CarName, resultProfile.Car.CarName);
        Assert.Equal(driver.Car.CarType, resultProfile.Car.CarType);
    }

    [Fact]
    public async Task DriverController_CreateProfile_Conflict()
    {
        // Arrange
        var mockClientRepository = new Mock<IDriverRepository>();
        Driver driver = new Driver
        {
            Id = "0x123456789",
            FirstName = "Alex",
            LastName = "Brown",
            Car = new Car
            {
                CarName = "Mercedes",
                CarType = CarType.Basic
            }
        };

        mockClientRepository.Setup(repository => repository.CreateDriver(driver)).ReturnsAsync(null as Driver);

        var controller = new DriverController(mockClientRepository.Object);

        // Act
        var result = await controller.CreateProfile(driver);

        // Assert
        Assert.IsType<ConflictObjectResult>(result.Result);
        mockClientRepository.Verify(repository => repository.CreateDriver(driver), Times.Once);
    }

    [Fact]
    public async Task DriverController_GetDriver_Ok()
    {
        // Arrange
        var mockClientRepository = new Mock<IDriverRepository>();
        Driver driver = new Driver
        {
            Id = "0x123456789",
            FirstName = "Alex",
            LastName = "Brown",
            Car = new Car
            {
                CarName = "Mercedes",
                CarType = CarType.Basic
            }
        };
        mockClientRepository.Setup(repository => repository.GetDriver("0x123456789")).ReturnsAsync(driver);

        var controller = new DriverController(mockClientRepository.Object);

        // Act
        var result = await controller.GetProfile("0x123456789");

        // Assert
        var okResult = Assert.IsType<OkObjectResult>(result.Result);
        var resultProfile = Assert.IsType<Driver>(okResult.Value);
        mockClientRepository.Verify(repository => repository.GetDriver("0x123456789"), Times.Once);
        Assert.Equal(driver.FirstName, resultProfile.FirstName);
        Assert.Equal(driver.LastName, resultProfile.LastName);
        Assert.Equal(driver.Id, resultProfile.Id);
        Assert.Equal(driver.Car.CarName, resultProfile.Car.CarName);
        Assert.Equal(driver.Car.CarType, resultProfile.Car.CarType);
    }

    [Fact]
    public async Task DriverController_GetProfile_NotFound()
    {
        // Arrange
        var mockClientRepository = new Mock<IDriverRepository>();


        mockClientRepository.Setup(repository => repository.GetDriver("0x123456789")).ReturnsAsync(null as Driver);

        var controller = new DriverController(mockClientRepository.Object);

        // Act
        var result = await controller.GetProfile("0x123456789");

        // Assert
        Assert.IsType<NotFoundResult>(result.Result);
        mockClientRepository.Verify(repository => repository.GetDriver("0x123456789"), Times.Once);
    }

    [Fact]
    public async Task DriverController_UpdateProfile_Ok()
    {
        // Arrange
        var mockClientRepository = new Mock<IDriverRepository>();
        Driver driver = new Driver
        {
            Id = "0x123456789",
            FirstName = "Alex",
            LastName = "Brown",
            Car = new Car
            {
                CarName = "Mercedes",
                CarType = CarType.Basic
            }
        };

        mockClientRepository.Setup(repository =>
            repository.UpdateDriver("0x123456789", driver)).ReturnsAsync(driver);

        var controller = new DriverController(mockClientRepository.Object);

        // Act
        var result = await controller.UpdateProfile(driver);

        // Assert
        var okResult = Assert.IsType<OkObjectResult>(result.Result);
        var resultProfile = Assert.IsType<Driver>(okResult.Value);
        mockClientRepository.Verify(repository => repository.UpdateDriver("0x123456789", driver), Times.Once);
        Assert.Equal(driver.FirstName, resultProfile.FirstName);
        Assert.Equal(driver.LastName, resultProfile.LastName);
        Assert.Equal(driver.Id, resultProfile.Id);
        Assert.Equal(driver.Car.CarName, resultProfile.Car.CarName);
        Assert.Equal(driver.Car.CarType, resultProfile.Car.CarType);
    }

    [Fact]
    public async Task DriverController_UpdateProfile_NotFound()
    {
        // Arrange
        var mockClientRepository = new Mock<IDriverRepository>();
        Driver driver = new Driver
        {
            Id = "0x123456789",
            FirstName = "Alex",
            LastName = "Brown",
            Car = new Car
            {
                CarName = "Mercedes",
                CarType = CarType.Basic
            }
        };

        mockClientRepository.Setup(repository =>
            repository.UpdateDriver("0x123456789", driver)).ReturnsAsync(null as Driver);

        var controller = new DriverController(mockClientRepository.Object);

        // Act
        var result = await controller.UpdateProfile(driver);

        // Assert
        Assert.IsType<NotFoundResult>(result.Result);
        mockClientRepository.Verify(repository => repository.UpdateDriver("0x123456789", driver), Times.Once);
    }
}

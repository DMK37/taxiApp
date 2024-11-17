const { expect } = require("chai");

describe("Ride", function () {
    let Ride;
    let ride;
    let owner;
    let client;
    let driver;
    const amount = BigInt(200000);

    beforeEach(async function () {
        Ride = await ethers.getContractFactory("Ride");
        [owner, client, driver] = await ethers.getSigners();
        ride = await Ride.deploy();
    });

    it("Should create a ride", async function () {
        const tx = await ride.connect(client).createRide(5700, "A", "B", { value: amount });

        const rideDetails = await ride.rides(1);
        expect(rideDetails.status).to.equal(0);
        expect(rideDetails.client).to.equal(client.address);
        expect(rideDetails.cost).to.equal(amount);
        expect(rideDetails.source).to.equal("A");
        expect(rideDetails.destination).to.equal("B");
        expect(rideDetails.distance).to.equal(5700);
        await expect(tx).to.emit(ride, "RideCreated").withArgs(1, client.address, amount);
    });

    it("Should increase the ride count", async function () {
        await ride.connect(client).createRide(5700, "A", "B", { value: amount });
        expect(await ride.rideCounter()).to.equal(1);
    });

    it("Should not create a ride if value is 0", async function () {
        await expect(ride.connect(client).createRide(5700, "A", "B", { value: 0 }))
        .to.be.revertedWith("Cost should be greater than 0");
    });

    it("Should confirm a ride", async function () {
        await ride.connect(client).createRide(5700, "A", "B", { value: amount });
        const tx = await ride.connect(driver).confirmRide(1);

        const blockTimestamp = (await ethers.provider.getBlock('latest')).timestamp;

        const rideDetails = await ride.rides(1);
        expect(rideDetails.status).to.equal(1);
        expect(rideDetails.driver).to.equal(driver.address);
        expect(rideDetails.confirmationTime).to.equal(blockTimestamp);
        await expect(tx).to.emit(ride, "RideConfirmed").withArgs(1, driver.address, blockTimestamp);
    });

    it("Should not confirm a ride if the ride does not exist", async function () {
        await expect(ride.connect(driver).confirmRide(0))
        .to.be.revertedWith("Ride does not exist");
    });

    it("Should not confirm a ride if the ride is already confirmed", async function () {
        await ride.connect(client).createRide(5700, "A", "B", { value: amount });
        await ride.connect(driver).confirmRide(1);
        await expect(ride.connect(driver).confirmRide(1))
        .to.be.revertedWith("Ride is not in requested state");
    });

    it("Should confirm soucre arrival by client", async function () {
        await ride.connect(client).createRide(5700, "A", "B", { value: amount });
        await ride.connect(driver).confirmRide(1);
        await ride.connect(client).confirmSourceArrivalByClient(1);

        const rideDetails = await ride.rides(1);
        expect(rideDetails.status).to.equal(2);
    });

    it("Should start the ride when client confirmed source arrival after driver", async function () {
        await ride.connect(client).createRide(5700, "A", "B", { value: amount });
        await ride.connect(driver).confirmRide(1);
        await ride.connect(driver).confirmSourceArrivalByDriver(1);
        const tx = await ride.connect(client).confirmSourceArrivalByClient(1);

        const blockTimestamp = (await ethers.provider.getBlock('latest')).timestamp;

        const rideDetails = await ride.rides(1);
        expect(rideDetails.status).to.equal(4);
        expect(rideDetails.startTime).to.equal(blockTimestamp);
        await expect(tx).to.emit(ride, "RideStarted").withArgs(1, blockTimestamp);
    });

    it("Should not confirm source arrival by client if the ride does not exist", async function () {
        await expect(ride.connect(client).confirmSourceArrivalByClient(0))
        .to.be.revertedWith("Ride does not exist");
    });

    it("Only client can confirm source arrival", async function () {
        await ride.connect(client).createRide(5700, "A", "B", { value: amount });
        await ride.connect(driver).confirmRide(1);
        await expect(ride.connect(driver).confirmSourceArrivalByClient(1))
        .to.be.revertedWith("Only client can perform this action");
    });

    it("Should not confirm source arrival by client if the ride is not in confirmed state", async function () {
        await ride.connect(client).createRide(5700, "A", "B", { value: amount });
        await expect(ride.connect(client).confirmSourceArrivalByClient(1))
        .to.be.revertedWith("Ride is not in confirmed state");
    });

    it("Should confirm source arrival by driver", async function () {
        await ride.connect(client).createRide(5700, "A", "B", { value: amount });
        await ride.connect(driver).confirmRide(1);
        await ride.connect(driver).confirmSourceArrivalByDriver(1);

        const rideDetails = await ride.rides(1);
        expect(rideDetails.status).to.equal(3);
    });

    it("Should start the ride when driver confirmed source arrival after client", async function () {
        await ride.connect(client).createRide(5700, "A", "B", { value: amount });
        await ride.connect(driver).confirmRide(1);
        await ride.connect(client).confirmSourceArrivalByClient(1);
        const tx = await ride.connect(driver).confirmSourceArrivalByDriver(1);

        const blockTimestamp = (await ethers.provider.getBlock('latest')).timestamp;

        const rideDetails = await ride.rides(1);
        expect(rideDetails.status).to.equal(4);
        expect(rideDetails.startTime).to.equal(blockTimestamp);
        await expect(tx).to.emit(ride, "RideStarted").withArgs(1, blockTimestamp);
    });

    it("Should not confirm source arrival by driver if the ride does not exist", async function () {
        await expect(ride.connect(driver).confirmSourceArrivalByDriver(0))
        .to.be.revertedWith("Ride does not exist");
    });

    it("Only driver can confirm source arrival", async function () {
        await ride.connect(client).createRide(5700, "A", "B", { value: amount });
        await ride.connect(driver).confirmRide(1);
        await expect(ride.connect(client).confirmSourceArrivalByDriver(1))
        .to.be.revertedWith("Only driver can perform this action");
    });

    it("Should not confirm source arrival by driver if the ride is not in confirmed state", async function () {
        await ride.connect(client).createRide(5700, "A", "B", { value: amount });
        await expect(ride.connect(driver).confirmSourceArrivalByDriver(1))
        .to.be.revertedWith("Only driver can perform this action");
    });

    it("Should confirm destination arrival by client", async function () {
        await ride.connect(client).createRide(5700, "A", "B", { value: amount });
        await ride.connect(driver).confirmRide(1);
        await ride.connect(driver).confirmSourceArrivalByDriver(1);
        await ride.connect(client).confirmSourceArrivalByClient(1);
        await ride.connect(client).confirmDestinationArrivalByClient(1);

        const rideDetails = await ride.rides(1);
        expect(rideDetails.status).to.equal(5);
    });

    it("Should end the ride when client confirmed destination arrival after driver", async function () {
        await ride.connect(client).createRide(5700, "A", "B", { value: amount });
        await ride.connect(driver).confirmRide(1);
        await ride.connect(driver).confirmSourceArrivalByDriver(1);
        await ride.connect(client).confirmSourceArrivalByClient(1);
        await ride.connect(driver).confirmDestinationArrivalByDriver(1);
        const tx = await ride.connect(client).confirmDestinationArrivalByClient(1);

        const blockTimestamp = (await ethers.provider.getBlock('latest')).timestamp;

        const rideDetails = await ride.rides(1);
        expect(rideDetails.status).to.equal(7);
        expect(rideDetails.endTime).to.equal(blockTimestamp);
        await expect(tx).to.emit(ride, "RideCompleted").withArgs(1, blockTimestamp);
    });

    it("Should not confirm destination arrival by client if the ride does not exist", async function () {
        await expect(ride.connect(client).confirmDestinationArrivalByClient(0))
        .to.be.revertedWith("Ride does not exist");
    });

    it("Only client can confirm destination arrival", async function () {
        await ride.connect(client).createRide(5700, "A", "B", { value: amount });
        await ride.connect(driver).confirmRide(1);
        await ride.connect(driver).confirmSourceArrivalByDriver(1);
        await ride.connect(client).confirmSourceArrivalByClient(1);
        await expect(ride.connect(driver).confirmDestinationArrivalByClient(1))
        .to.be.revertedWith("Only client can perform this action");
    });

    it("Should not confirm destination arrival by client if the ride is not in source arrived state", async function () {
        await ride.connect(client).createRide(5700, "A", "B", { value: amount });
        await expect(ride.connect(client).confirmDestinationArrivalByClient(1))
        .to.be.revertedWith("Ride is not in in-progress state");
    });

    it("Should confirm destination arrival by driver", async function () {
        await ride.connect(client).createRide(5700, "A", "B", { value: amount });
        await ride.connect(driver).confirmRide(1);
        await ride.connect(driver).confirmSourceArrivalByDriver(1);
        await ride.connect(client).confirmSourceArrivalByClient(1);
        await ride.connect(driver).confirmDestinationArrivalByDriver(1);

        const rideDetails = await ride.rides(1);
        expect(rideDetails.status).to.equal(6);
    });

    it("Should end the ride when driver confirmed destination arrival after client", async function () {
        await ride.connect(client).createRide(5700, "A", "B", { value: amount });
        await ride.connect(driver).confirmRide(1);
        await ride.connect(driver).confirmSourceArrivalByDriver(1);
        await ride.connect(client).confirmSourceArrivalByClient(1);
        await ride.connect(client).confirmDestinationArrivalByClient(1);
        const tx = await ride.connect(driver).confirmDestinationArrivalByDriver(1);

        const blockTimestamp = (await ethers.provider.getBlock('latest')).timestamp;

        const rideDetails = await ride.rides(1);
        expect(rideDetails.status).to.equal(7);
        expect(rideDetails.endTime).to.equal(blockTimestamp);
        await expect(tx).to.emit(ride, "RideCompleted").withArgs(1, blockTimestamp);
    });

    it("Should not confirm destination arrival by driver if the ride does not exist", async function () {
        await expect(ride.connect(driver).confirmDestinationArrivalByDriver(0))
        .to.be.revertedWith("Ride does not exist");
    });

    it("Only driver can confirm destination arrival", async function () {
        await ride.connect(client).createRide(5700, "A", "B", { value: amount });
        await ride.connect(driver).confirmRide(1);
        await ride.connect(driver).confirmSourceArrivalByDriver(1);
        await ride.connect(client).confirmSourceArrivalByClient(1);
        await expect(ride.connect(client).confirmDestinationArrivalByDriver(1))
        .to.be.revertedWith("Only driver can perform this action");
    });

    it("Should not confirm destination arrival by driver if the ride is not in source arrived state", async function () {
        await ride.connect(client).createRide(5700, "A", "B", { value: amount });
        await ride.connect(driver).confirmRide(1);
        await expect(ride.connect(driver).confirmDestinationArrivalByDriver(1))
        .to.be.revertedWith("Ride is not in in-progress state");
    });

    it("Should cancel the ride by client", async function () {
        await ride.connect(client).createRide(5700, "A", "B", { value: amount });
;
        const tx = await ride.connect(client).cancelRide(1);

        const rideDetails = await ride.rides(1);
        expect(rideDetails.status).to.equal(8);
        await expect(tx).to.emit(ride, "RideCancelled").withArgs(1);
    });

    it("Should not cancel the ride by client if the ride does not exist", async function () {
        await expect(ride.connect(client).cancelRide(0))
        .to.be.revertedWith("Ride does not exist");
    });

    it("Should cancel the ride by driver", async function () {
        await ride.connect(client).createRide(5700, "A", "B", { value: amount });
        await ride.connect(driver).confirmRide(1);
        const tx = await ride.connect(driver).cancelRide(1);

        const rideDetails = await ride.rides(1);
        expect(rideDetails.status).to.equal(8);
        await expect(tx).to.emit(ride, "RideCancelled").withArgs(1);
    });
});
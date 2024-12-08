// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.27;

contract Ride {
    enum RideStatus {
        Requested,
        Confirmed,
        SourceArrivedByClient,
        SourceArrivedByDriver,
        InProgress,
        DestinationArrivedByClient,
        DestinationArrivedByDriver,
        Completed,
        Cancelled
    }

    struct RideDetails {
        address payable client;
        address payable driver;
        uint256 cost;
        uint64 distance;
        string source;
        string destination;
        uint256 confirmationTime;
        uint256 startTime;
        uint256 endTime;
        RideStatus status;
    }

    mapping(uint64 => RideDetails) public rides;
    uint64 public rideCounter;

    event RideCreated(uint64 indexed rideId, address indexed client, uint256 indexed cost);
    event RideConfirmed(
        uint64 indexed rideId,
        address indexed driver,
        uint256 indexed confirmationTime
    );
    event RideStarted(uint64 indexed rideId, uint256 indexed startTime);
    event RideCompleted(uint64 indexed rideId, uint256 indexed endTime);
    event RideCancelled(uint64 indexed rideId);

    function createRide(
        uint64 _distance,
        string memory _source,
        string memory _destination
    ) external payable returns (uint64) {
        require(msg.value > 0, "Cost should be greater than 0");
        rideCounter++;
        rides[rideCounter] = RideDetails(
            payable(msg.sender),
            payable(address(0)),
            msg.value,
            _distance,
            _source,
            _destination,
            0,
            0,
            0,
            RideStatus.Requested
        );
        emit RideCreated(rideCounter, msg.sender, msg.value);

        return rideCounter;
    }

    modifier notExistingRide(uint64 _rideId) {
        require(rides[_rideId].client != address(0), "Ride does not exist");
        _;
    }

    modifier onlyClient(uint64 _rideId) {
        require(
            msg.sender == rides[_rideId].client,
            "Only client can perform this action"
        );
        _;
    }

    modifier onlyDriver(uint64 _rideId) {
        require(
            msg.sender == rides[_rideId].driver,
            "Only driver can perform this action"
        );
        _;
    }

    function confirmRide(uint64 _rideId) external notExistingRide(_rideId) {
        require(
            rides[_rideId].status == RideStatus.Requested,
            "Ride is not in requested state"
        );
        rides[_rideId].driver = payable(msg.sender);
        rides[_rideId].confirmationTime = block.timestamp;
        rides[_rideId].status = RideStatus.Confirmed;

        emit RideConfirmed(
            _rideId,
            msg.sender,
            rides[_rideId].confirmationTime
        );
    }

    function confirmSourceArrivalByClient(
        uint64 _rideId
    ) external notExistingRide(_rideId) onlyClient(_rideId) {
        require(
            rides[_rideId].status == RideStatus.Confirmed ||
                rides[_rideId].status == RideStatus.SourceArrivedByDriver,
            "Ride is not in confirmed state"
        );
        if (rides[_rideId].status == RideStatus.Confirmed) {
            rides[_rideId].status = RideStatus.SourceArrivedByClient;
        } else {
            rides[_rideId].startTime = block.timestamp;
            rides[_rideId].status = RideStatus.InProgress;

            emit RideStarted(_rideId, rides[_rideId].startTime);
        }
    }

    function confirmSourceArrivalByDriver(
        uint64 _rideId
    ) external notExistingRide(_rideId) onlyDriver(_rideId) {
        require(
            rides[_rideId].status == RideStatus.Confirmed ||
                rides[_rideId].status == RideStatus.SourceArrivedByClient,
            "Ride is not in confirmed state"
        );
        if (rides[_rideId].status == RideStatus.Confirmed) {
            rides[_rideId].status = RideStatus.SourceArrivedByDriver;
        } else {
            rides[_rideId].startTime = block.timestamp;
            rides[_rideId].status = RideStatus.InProgress;

            emit RideStarted(_rideId, rides[_rideId].startTime);
        }
    }

    function confirmDestinationArrivalByClient(
        uint64 _rideId
    ) external notExistingRide(_rideId) onlyClient(_rideId) {
        require(
            rides[_rideId].status == RideStatus.InProgress ||
                rides[_rideId].status == RideStatus.DestinationArrivedByDriver,
            "Ride is not in in-progress state"
        );
        if (rides[_rideId].status == RideStatus.InProgress) {
            rides[_rideId].status = RideStatus.DestinationArrivedByClient;
        } else {
            rides[_rideId].endTime = block.timestamp;
            rides[_rideId].status = RideStatus.Completed;
            rides[_rideId].driver.transfer(rides[_rideId].cost);
            emit RideCompleted(
                _rideId,
                rides[_rideId].endTime
            );
        }
    }

    function confirmDestinationArrivalByDriver(
        uint64 _rideId
    ) external notExistingRide(_rideId) onlyDriver(_rideId) {
        require(
            rides[_rideId].status == RideStatus.InProgress ||
                rides[_rideId].status == RideStatus.DestinationArrivedByClient,
            "Ride is not in in-progress state"
        );
        if (rides[_rideId].status == RideStatus.InProgress) {
            rides[_rideId].status = RideStatus.DestinationArrivedByDriver;
        } else {
            rides[_rideId].endTime = block.timestamp;
            rides[_rideId].status = RideStatus.Completed;
            rides[_rideId].driver.transfer(rides[_rideId].cost);
            emit RideCompleted(
                _rideId,
                rides[_rideId].endTime
            );
        }
    }

    function cancelRide(uint64 _rideId) external notExistingRide(_rideId) {
        require(
            msg.sender == rides[_rideId].client ||
                msg.sender == rides[_rideId].driver,
            "Only client or driver can cancel the ride"
        );
        rides[_rideId].status = RideStatus.Cancelled;
        rides[_rideId].client.transfer(rides[_rideId].cost);
        emit RideCancelled(_rideId);
    }
}

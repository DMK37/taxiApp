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
        address client;
        address driver;
        uint256 cost;
        uint256 distance;
        string source;
        string destination;
        uint256 confirmationTime;
        uint256 startTime;
        uint256 endTime;
        RideStatus status;
    }

    mapping(uint256 => RideDetails) public rides;
    uint256 public rideCounter;

    event RideCreated(uint256 rideId, address client, uint256 cost);
    event RideConfirmed(uint256 rideId, address driver, uint256 confirmationTime);
    event RideStarted(uint256 rideId, uint256 startTime);
    event RideCompleted(uint256 rideId, address driver, uint256 payout);
    event RideCancelled(uint256 rideId);

    function createRide(
        address _client,
        uint256 _cost,
        uint256 _distance,
        string memory _source,
        string memory _destination
    ) public returns (uint256) {
        rideCounter++;
        rides[rideCounter] = RideDetails(
            _client,
            address(0),
            _cost,
            _distance,
            _source,
            _destination,
            0,
            0,
            0,
            RideStatus.Requested
        );

        emit RideCreated(rideCounter, _client, _cost);

        return rideCounter;
    }

    function confirmRide(uint256 _rideId, address _driver) public {
        require(
            rides[_rideId].status == RideStatus.Requested,
            "Ride is not in requested state"
        );
        rides[_rideId].driver = _driver;
        rides[_rideId].confirmationTime = block.timestamp;
        rides[_rideId].status = RideStatus.Confirmed;

        emit RideConfirmed(_rideId, _driver, rides[_rideId].confirmationTime);
    }

    function confirmSourceArrivalByClient(uint256 _rideId) public {
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

    function confirmSourceArrivalByDriver(uint256 _rideId) public {
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

    function destinationArrivedByClient(uint256 _rideId) public {
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

            emit RideCompleted(_rideId, rides[_rideId].driver, rides[_rideId].cost);
        }
    }

    function destinationArrivedByDriver(uint256 _rideId) public {
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

            emit RideCompleted(_rideId, rides[_rideId].driver, rides[_rideId].cost);
        }
    }

    function cancelRide(uint256 _rideId) public {
        require(
            rides[_rideId].status == RideStatus.Requested,
            "Ride is not in requested state"
        );
        rides[_rideId].status = RideStatus.Cancelled;

        emit RideCancelled(_rideId);
    }
}

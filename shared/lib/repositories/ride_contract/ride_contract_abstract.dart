import 'package:reown_appkit/reown_appkit.dart';

abstract class RideContractAbstract {
  Future<bool> createRide(
      ReownAppKitModal modal,
      int distance,
      String source,
      String destination,
      String sourceLocation,
      String destinationLocation,
      BigInt price);
  Future<bool> confirmRide(ReownAppKitModal modal, int rideId);
  Future<bool> confirmSourceArrivalByClient(ReownAppKitModal modal, int rideId);
  Future<bool> confirmDestinationArrivalByClient(
      ReownAppKitModal modal, int rideId);
  Future<bool> confirmSourceArrivalByDriver(ReownAppKitModal modal, int rideId);
  Future<bool> confirmDestinationArrivalByDriver(
      ReownAppKitModal modal, int rideId);
  Future<bool> cancelRide(ReownAppKitModal modal, int rideId);
}

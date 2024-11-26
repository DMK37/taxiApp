import 'package:reown_appkit/reown_appkit.dart';

abstract class RideContractAbstract {
  Future<bool> createRide(ReownAppKitModal modal, int distance, String source,
      String destination, BigInt price);
  Future<void> confirmRide(ReownAppKitModal modal, int rideId);
  Future<void> confirmSourceArrivalByClient(ReownAppKitModal modal, int rideId);
  Future<void> confirmDestinationArrivalByClient(
      ReownAppKitModal modal, int rideId);
  Future<void> confirmSourceArrivalByDriver(ReownAppKitModal modal, int rideId);
  Future<void> confirmDestinationArrivalByDriver(
      ReownAppKitModal modal, int rideId);
  Future<void> cancelRide(ReownAppKitModal modal, int rideId);
}

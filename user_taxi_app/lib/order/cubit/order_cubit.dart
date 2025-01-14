import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reown_appkit/reown_appkit.dart';
import 'package:shared/models/driver_model.dart';
import 'package:shared/repositories/driver/driver_repository.dart';
import 'package:shared/repositories/ride_contract/ride_contract.dart';
import 'package:shared/repositories/ride_contract/ride_contract_abstract.dart';
import 'package:taxiapp/order/cubit/order_state.dart';

class OrderCubit extends Cubit<OrderState> {
  final RideContractAbstract rideRepository = RideContract();
  final driverRepository = DriverRepository();
  OrderCubit() : super(OrderInitial());
  Future<bool> createRide(
    ReownAppKitModal modal,
    double price,
    String source,
    String destination,
    String sourceLocation,
    String destinationLocation,
    int distance,
  ) async {
    emit(OrderLoading());
    final response = await rideRepository.createRide(
        modal,
        distance,
        source,
        destination,
        sourceLocation,
        destinationLocation,
        BigInt.from(price * 1000000000000000000));
    if (response) {
      emit(OrderWaiting());
      return true;
    } else {
      // emit(RideError());
    }

    return false;
  }

  Future<void> cancelRide(ReownAppKitModal modal, int rideId) async {
    // emit(OrderLoading());
    final response = await rideRepository.cancelRide(modal, rideId);

    if (response) {
      emit(OrderCancelled());
    } else {
      // emit(RideError());
    }
  }

  Future<void> confirmSourceArrival(ReownAppKitModal modal, int rideId) async {
    // emit(OrderLoading());
    final response =
        await rideRepository.confirmSourceArrivalByClient(modal, rideId);

    if (response) {
      final rideId = (state as OrderSourceArrival).rideId;
      emit(OrderDestinationArrival(rideId: rideId));
    } else {
      // emit(RideError());
    }
  }

  Future<void> confirmDestinationArrival(ReownAppKitModal modal, int rideId) async {
    // emit(OrderLoading());
    final response =
        await rideRepository.confirmDestinationArrivalByClient(modal, rideId);

    if (response) {
      emit(OrderCompleted());
    } else {
      // emit(RideError());
    }
  }

  void destinationArrival(int rideId) {
    emit(OrderDestinationArrival(rideId: rideId));
  }

  void completedOrder() {
    emit(OrderCompleted());
  }

  Future<DriverModel?> getDriver(String driverId) async {
    return await driverRepository.getDriver(driverId);
  }

  void sourceArrival(String driverId, int rideId) {
    emit(OrderSourceArrival(driverId: driverId, rideId: rideId));
  }
}

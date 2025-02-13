import 'dart:async';

import 'package:driver_taxi_app/firebase/data_providers/driver_location_dp.dart';
import 'package:driver_taxi_app/initial_state/cubit/initial_state.dart';
import 'package:driver_taxi_app/models/order_message.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:reown_appkit/modal/appkit_modal_impl.dart';
import 'package:shared/models/car_type.dart';
import 'package:shared/repositories/driver/driver_repository.dart';
import 'package:shared/repositories/ride_contract/ride_contract.dart';

class DriverInitCubit extends Cubit<DriverState> {
  DriverInitCubit() : super(DriverOfflineState());

  Timer? _locationTimer;
  DriverRepository repository = DriverRepository();
  RideContract rideContract = RideContract();

  startLocationUpdate(
      LatLng driverLocation, String driverId, String ref) async {
    DriverLocationDataProvider provider =
        DriverLocationDataProvider(db: FirebaseDatabase.instance.ref(ref));
    provider.setDriverCurrenLocation(driverLocation, driverId);
    _locationTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      provider.setDriverCurrenLocation(driverLocation, driverId);
    });
  }

  stopLocationUpdate(String driverId, String ref) async {
    DriverLocationDataProvider provider =
        DriverLocationDataProvider(db: FirebaseDatabase.instance.ref(ref));
    _locationTimer?.cancel();
    provider.removeActiveDriver(driverId);
  }

  Future<List<CarType>> getCarTypeList() async {
    final res = await repository.getCarTypes();
    return res;
  }

  void messageReceived(String driverId, OrderMessageModel message) {
    stopLocationUpdate(driverId, "drivers/$driverId");
    emit(DriverMessagedState(message: message));
  }

  void cancelRide() {
    emit(DriverOfflineState());
  }

    Future<bool> confirmRide(
    ReownAppKitModal modal,
    int rideId,
    OrderMessageModel orderMessageModel,
  ) async {
    final res = await rideContract.confirmRide(modal, rideId);
    if (res) {
      emit(UpcomingOrderState(message: orderMessageModel));
    }
    return res;
  }

  Future<bool> confirmSourceArrival(
    ReownAppKitModal modal,
    int rideId,
    OrderMessageModel orderMessageModel,
  ) async {
    final res = await rideContract.confirmSourceArrivalByDriver(modal, rideId);
    return res;
  }

  Future<bool> confirmDestinationArrival(
    ReownAppKitModal modal,
    int rideId,
    OrderMessageModel orderMessageModel,
  ) async {
    final res = await rideContract.confirmDestinationArrivalByDriver(modal, rideId);
    return res;
  }

  void orderCompleted(OrderMessageModel orderMessageModel) {
    emit(CompletedOrderState(orderMessageModel));
  }

  void orderInProgress(OrderMessageModel orderMessageModel) {
    emit(InProgressOrderState(orderMessageModel));
  }
}

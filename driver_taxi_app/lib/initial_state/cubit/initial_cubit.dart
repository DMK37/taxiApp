import 'dart:async';

import 'package:driver_taxi_app/firebase/data_providers/driver_location_dp.dart';
import 'package:driver_taxi_app/initial_state/cubit/initial_state.dart';
import 'package:driver_taxi_app/models/order_message.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:reown_appkit/reown_appkit.dart';
import 'package:shared/models/car_type.dart';
import 'package:shared/repositories/driver/driver_repository.dart';
import 'package:shared/repositories/ride_contract/ride_contract.dart';

class DriverInitCubit extends Cubit<DriverState> {
  DriverInitCubit() : super(DriverOfflineState());

  Timer? _locationTimer;
  DriverLocationDataProvider provider = DriverLocationDataProvider();
  DriverRepository repository = DriverRepository();
  RideContract rideContract = RideContract();

  startLocationUpdate(LatLng driverLocation, String driverId) async {
    provider.setDriverCurrenLocation(driverLocation, driverId);
    _locationTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      provider.setDriverCurrenLocation(driverLocation, driverId);
    });
  }

  stopLocationUpdate(String driverId) async {
    _locationTimer?.cancel();
    provider.removeActiveDriver(driverId);
  }

  Future<List<CarType>> getCarTypeList() async {
    final res = await repository.getCarTypes();
    return res;
  }

  void messageReceived(String driverId, OrderMessageModel message) {
    stopLocationUpdate(driverId);
    emit(DriverMessagedState(message: message));
  }

  Future<bool> confirmRide(ReownAppKitModal modal, int rideId, ) async {
    final res = await rideContract.confirmRide(modal, rideId);
    return res;
  }

  void cancelRide() {
    emit(DriverOfflineState());
  }
}

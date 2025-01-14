import 'dart:async';

import 'package:driver_taxi_app/firebase/data_providers/driver_location_dp.dart';
import 'package:driver_taxi_app/initial_state/cubit/initial_state.dart';
import 'package:driver_taxi_app/models/order_message.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared/models/car_type.dart';
import 'package:shared/repositories/driver/driver_repository.dart';

class DriverInitCubit extends Cubit<DriverState> {
  DriverInitCubit() : super(DriverOfflineState());

  Timer? _locationTimer;
  DriverRepository repository = DriverRepository();

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
}

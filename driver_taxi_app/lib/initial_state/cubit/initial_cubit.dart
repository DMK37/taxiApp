import 'dart:async';

import 'package:driver_taxi_app/firebase/data_providers/driver_location_dp.dart';
import 'package:driver_taxi_app/initial_state/cubit/initial_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared/models/car_type.dart';
import 'package:shared/repositories/driver/driver_repository.dart';

class DriverInitCubit extends Cubit<DriverInitState> {
  DriverInitCubit() : super(DriverOfflineState());

  Timer? _locationTimer;
  DriverLocationDataProvider provider = DriverLocationDataProvider();
  DriverRepository repository = DriverRepository();

  // TODO: driver id as database id

  startLocationUpdate(LatLng driverLocation) async
  {
    provider.setDriverCurrenLocation(driverLocation);
     _locationTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
    provider.setDriverCurrenLocation(driverLocation);
  });
  }

  stopLocationUpdate() async {
    _locationTimer?.cancel();
    provider.removeActiveDriver();
  }

  Future<List<CarType>> getCarTypeList() async {
    final res = await repository.getCarTypes();
    return res;
  }
}

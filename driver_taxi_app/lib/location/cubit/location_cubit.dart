import 'package:driver_taxi_app/location/cubit/location_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DriverLocationCubit extends Cubit<DriverLocationState> {
  DriverLocationCubit() : super(DriverLocationLoadingState());

  Future<void> getLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      emit(DriverNoPermissionState());
      return;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      emit(DriverNoPermissionState());
      return;
    }
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        emit(DriverNoPermissionState());
        return;
      }
    }

    final currentPosition = await Geolocator.getCurrentPosition();

    emit(DriverLocationSuccessState(
        location: LatLng(currentPosition.latitude, currentPosition.longitude)));
  }
}

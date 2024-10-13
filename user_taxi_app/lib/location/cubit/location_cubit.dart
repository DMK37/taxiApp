import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:taxiapp/location/cubit/location_state.dart';

class LocationCubit extends Cubit<LocationState> {
  LocationCubit() : super(LocationLoadingState());

  Future<void> checkPermissionsAndGetLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      emit(NoPermissionState());
      return;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      emit(NoPermissionState());
      return;
    }
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        emit(NoPermissionState());
        return;
      }
    }

    await getLocation();
  }

  Future<(LatLng, String)> getLocation() async {
    final currentPosition = await Geolocator.getCurrentPosition();

    final data = await placemarkFromCoordinates(
        currentPosition.latitude, currentPosition.longitude);

    final street = data[0].street;

    emit(LocationSuccessState(
        location: LatLng(currentPosition.latitude, currentPosition.longitude),
        address: street!));

    return (
      LatLng(currentPosition.latitude, currentPosition.longitude),
      street
    );
  }
}

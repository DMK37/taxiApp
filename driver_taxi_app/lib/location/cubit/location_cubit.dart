import 'dart:async';

import 'package:driver_taxi_app/location/cubit/location_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class LocationCubit extends Cubit<LocationState> {
  LocationCubit() : super(LocationLoadingState());

  PolylinePoints polylinePoints = PolylinePoints();
  static const String apiKey = "AIzaSyAJI-buaRrNN3x2RASJk6yv_UltK2fePzM";

  Future<(LatLng, String)> getLocation() async {
    final currentPosition = await Geolocator.getCurrentPosition();
    final data = await placemarkFromCoordinates(
        currentPosition.latitude, currentPosition.longitude);

    final street = "${data[0].street}, ${data[0].locality}";
    emit(LocationSuccessState(
        location: LatLng(currentPosition.latitude, currentPosition.longitude),
        address: street));

    return (
      LatLng(currentPosition.latitude, currentPosition.longitude),
      street
    );
  }

  Future<void> checkPerrmissionsAndGetLocation() async {
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

  Future<void> goToTheLocation(LatLng location,
      Completer<GoogleMapController> googleMapController) async {
    final GoogleMapController controller = await googleMapController.future;
    await controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: location, zoom: 17)));
  }
}

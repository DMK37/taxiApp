import 'package:google_maps_flutter/google_maps_flutter.dart';

abstract class DriverLocationState {}

class DriverLocationLoadingState extends DriverLocationState {}

class DriverLocationSuccessState extends DriverLocationState {
  final LatLng location;
  final String address;

  DriverLocationSuccessState({required this.location, required this.address});
}

class DriverNoPermissionState extends DriverLocationState {}
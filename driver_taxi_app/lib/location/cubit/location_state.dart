import 'package:google_maps_flutter/google_maps_flutter.dart';

abstract class DriverLocationState {}

class DriverLocationLoadingState extends DriverLocationState {}

class DriverLocationSuccessState extends DriverLocationState {
  final LatLng location;

  DriverLocationSuccessState({required this.location});
}

class DriverNoPermissionState extends DriverLocationState {}
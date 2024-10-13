import 'package:google_maps_flutter/google_maps_flutter.dart';

abstract class LocationState {}

class LocationLoadingState extends LocationState {}

class LocationSuccessState extends LocationState {
  final LatLng location;
  final String address;

  LocationSuccessState({required this.location, required this.address});
}

class NoPermissionState extends LocationState {}

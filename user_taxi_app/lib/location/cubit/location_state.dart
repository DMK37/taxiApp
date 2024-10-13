import 'package:google_maps_flutter/google_maps_flutter.dart';

abstract class LocationState {}

class LocationLoadingState extends LocationState {}

class LocationSuccessState extends LocationState {
  final LatLng location;

  LocationSuccessState({required this.location});
}

class NoPermissionState extends LocationState {}
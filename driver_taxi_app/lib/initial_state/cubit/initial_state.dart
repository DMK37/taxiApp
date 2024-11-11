import 'package:google_maps_flutter/google_maps_flutter.dart';

abstract class DriverInitState {}

class InitState extends DriverInitState{
  LatLng? current;
  String? currentAddress;
  InitState({this.current, this.currentAddress});
}

class ErrorState extends DriverInitState{
  
}

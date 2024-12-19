import 'package:google_maps_flutter/google_maps_flutter.dart';

abstract class DriverInitState {}

class DriverOnlineState extends DriverInitState{
  LatLng? current;
  String? currentAddress;
  DriverOnlineState({this.current, this.currentAddress});
}

class DriverOfflineState extends DriverInitState{
  LatLng? current;
  String? currentAddress;
  DriverOfflineState({this.current, this.currentAddress});
}

class DriverLoadingState extends DriverInitState{
  
}

class ErrorState extends DriverInitState{
  
}

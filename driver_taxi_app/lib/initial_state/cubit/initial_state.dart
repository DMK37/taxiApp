import 'package:driver_taxi_app/models/order_message.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

abstract class DriverState {}

class DriverOnlineState extends DriverState{
  LatLng? current;
  String? currentAddress;
  DriverOnlineState({this.current, this.currentAddress});
}

class DriverOfflineState extends DriverState{
  LatLng? current;
  String? currentAddress;
  DriverOfflineState({this.current, this.currentAddress});
}

class DriverLoadingState extends DriverState{
  
}

class DriverMessagedState extends DriverState{
  final OrderMessageModel message;

  DriverMessagedState({required this.message});
}

class ErrorState extends DriverState{
  
}

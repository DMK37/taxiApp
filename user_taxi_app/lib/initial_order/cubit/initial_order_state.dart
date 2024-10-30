import 'package:google_maps_flutter/google_maps_flutter.dart';

abstract class InitialOrderState {}

class OrderInitial extends InitialOrderState {
  LatLng? source;
  String? sourceAddress;
  LatLng? destination;
  String? destinationAddress;
  OrderInitial({this.source, this.sourceAddress, this.destination, this.destinationAddress});
}

class OrderWithAssignedDriver extends InitialOrderState {}

class OrderWithPoints extends InitialOrderState {
  LatLng source;
  String sourceAddress;
  LatLng destination;
  String destinationAddress;

  OrderWithPoints({required this.source, required this.sourceAddress, required this.destination, required this.destinationAddress});
}
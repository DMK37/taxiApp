import 'package:google_maps_flutter/google_maps_flutter.dart';

abstract class InitialOrderState {}

class OrderInitial extends InitialOrderState {
  LatLng? source;
  LatLng? destination;
  OrderInitial({this.source, this.destination});
}

class OrderWithAssignedDriver extends InitialOrderState {}

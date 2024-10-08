import 'package:google_maps_flutter/google_maps_flutter.dart';

abstract class OrderState {}

class OrderInitial extends OrderState {
  final LatLng location;

  OrderInitial({required this.location});
}

class OrderLoading extends OrderState {}

class OrderWithAddress extends OrderState {
}

class OrderFailure extends OrderState {
  final String errorMessage;

  OrderFailure({required this.errorMessage});
}

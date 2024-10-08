import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:taxiapp/order/cubit/order_state.dart';

class OrderCubit extends Cubit<OrderState> {
  OrderCubit() : super(OrderLoading());

  void getUserLocation() async {
    emit(OrderLoading());
    bool serviceEnabled;
    LocationPermission permission;
    Position currentPosition;
// Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      emit(OrderFailure(errorMessage: 'Location permission denied'));
      return;
    }
// Request permission to get the user's location
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      emit(OrderFailure(errorMessage: 'Location permission denied'));
      return;
    }
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        emit(OrderFailure(errorMessage: 'Location permission denied'));
        return;
      }
    }
// Get the current location of the user
    currentPosition = await Geolocator.getCurrentPosition();

    emit(OrderInitial(
        location: LatLng(currentPosition.latitude, currentPosition.longitude)));
  }
}

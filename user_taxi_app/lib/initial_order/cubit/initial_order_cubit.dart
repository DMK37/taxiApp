import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:taxiapp/initial_order/cubit/initial_order_state.dart';

class InitialOrderCubit extends Cubit<InitialOrderState> {
  InitialOrderCubit() : super(OrderInitial());

  void pickSource(LatLng location) {
    final currentState = state;

    if (currentState is OrderInitial) {
      emit(OrderInitial(
          source: location, destination: currentState.destination));
    }
  }

  void pickDestination(LatLng location) {
    final currentState = state;

    if (currentState is OrderInitial) {
      emit(OrderInitial(
          source: currentState.source, destination: currentState.destination));
    }
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:taxiapp/initial_order/cubit/initial_order_state.dart';

class InitialOrderCubit extends Cubit<InitialOrderState> {
  InitialOrderCubit() : super(OrderInitial());

  void pickSource(LatLng location, String address) {
    final currentState = state;

    if (currentState is OrderInitial) {
      // if all go to next state
      emit(OrderInitial(
          source: location,
          sourceAddress: address,
          destination: currentState.destination,
          destinationAddress: currentState.destinationAddress));
    }
  }

  void pickDestination(LatLng location, String address) {
    final currentState = state;

    if (currentState is OrderInitial) {
      // if all go to next state

      emit(OrderInitial(
          source: currentState.source,
          sourceAddress: currentState.sourceAddress,
          destination: currentState.destination,
          destinationAddress: address));
    }
  }
}

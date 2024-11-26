import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared/models/ride_price_model.dart';
import 'package:shared/repositories/client/client_repository.dart';
import 'package:shared/repositories/client/client_repository_abstract.dart';
import 'package:taxiapp/initial_order/cubit/initial_order_state.dart';

class InitialOrderCubit extends Cubit<InitialOrderState> {
  InitialOrderCubit() : super(OrderInitial());
  final ClientRepositoryAbstract clientRepository = ClientRepository();
  void pickSource(LatLng location, String address) {
    final currentState = state;

    if (currentState is OrderInitial) {
      // if all go to next state
      if (currentState.destination != null &&
          currentState.destinationAddress != null) {
        emit(OrderWithPoints(
            source: location,
            sourceAddress: address,
            destination: currentState.destination!,
            destinationAddress: currentState.destinationAddress!));
      } else {
        emit(OrderInitial(
            source: location,
            sourceAddress: address,
            destination: currentState.destination,
            destinationAddress: currentState.destinationAddress));
      }
    }
  }

  void pickDestination(LatLng location, String address) {
    final currentState = state;

    if (currentState is OrderInitial) {
      // if all go to next state
      if (currentState.source != null && currentState.sourceAddress != null) {
        emit(OrderWithPoints(
            source: currentState.source!,
            sourceAddress: currentState.sourceAddress!,
            destination: location,
            destinationAddress: address));
      } else {
        emit(OrderInitial(
            source: currentState.source,
            sourceAddress: currentState.sourceAddress,
            destination: location,
            destinationAddress: address));
      }
    }
  }

  void clearPoints() {
    emit(OrderInitial());
  }

  Future<List<RidePriceModel>> getPrices(
      LatLng source, LatLng destination, int distance) async {
    final res = await clientRepository.getPrices(source, destination, distance);
    if (res != null) {
      return res;
    }

    return [];
  }
}

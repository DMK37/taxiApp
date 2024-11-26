import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reown_appkit/reown_appkit.dart';
import 'package:shared/repositories/ride_contract/ride_contract.dart';
import 'package:shared/repositories/ride_contract/ride_contract_abstract.dart';
import 'package:taxiapp/ride/cubit/ride_state.dart';

class RideCubit extends Cubit<RideState> {
  final RideContractAbstract rideRepository = RideContract();

  RideCubit() : super(RideInitial());
  Future<void> createRide(
    ReownAppKitModal modal,
    double price,
    String source,
    String destination,
    int distance,
  ) async {
    emit(RideLoading());
    final response = await rideRepository.createRide(modal, distance, source,
        destination, BigInt.from(price * 1000000000000000000));

    if (response) {
      emit(RideInitial());
    } else {
      // emit(RideError());
    }
  }
}

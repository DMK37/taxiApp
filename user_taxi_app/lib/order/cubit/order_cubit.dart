import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reown_appkit/reown_appkit.dart';
import 'package:shared/repositories/ride_contract/ride_contract.dart';
import 'package:shared/repositories/ride_contract/ride_contract_abstract.dart';
import 'package:taxiapp/order/cubit/order_state.dart';

class OrderCubit extends Cubit<OrderState> {
  final RideContractAbstract rideRepository = RideContract();

  OrderCubit() : super(OrderInitial());
  Future<void> createRide(
    ReownAppKitModal modal,
    double price,
    String source,
    String destination,
    int distance,
  ) async {
    emit(OrderLoading());
    final response = await rideRepository.createRide(modal, distance, source,
        destination, BigInt.from(price * 1000000000000000000));
    print(response);
    if (response) {
      emit(OrderWaiting());
    } else {
      // emit(RideError());
    }
  }

  Future<void> cancelRide(ReownAppKitModal modal) async {
    // emit(OrderLoading());
    // final response = await rideRepository.cancelRide(modal);

    // if (response) {
    //   emit(OrderInitial());
    // } else {
    //   // emit(RideError());
    // }
  }
}

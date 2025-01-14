import 'package:driver_taxi_app/models/order_message.dart';
import 'package:driver_taxi_app/order/cubit/order_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reown_appkit/reown_appkit.dart';
import 'package:shared/repositories/ride_contract/ride_contract.dart';

class OrderCubit extends Cubit<OrderState> {
  RideContract rideContract = RideContract();

  OrderCubit() : super(OrderInitial());

  Future<bool> confirmRide(
    ReownAppKitModal modal,
    int rideId,
    OrderMessageModel orderMessageModel,
  ) async {
    final res = await rideContract.confirmRide(modal, rideId);
    if (res) {
      emit(OrderUpcoming(orderMessageModel));
    }
    return res;
  }

  void orderInProgress(OrderMessageModel orderMessageModel) {
    emit(OrderInProgress(orderMessageModel));
  }

  void orderCompleted(OrderMessageModel orderMessageModel) {
    emit(OrderCompleted(orderMessageModel));
  }

}

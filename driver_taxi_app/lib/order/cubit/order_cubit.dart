import 'package:driver_taxi_app/models/order_message.dart';
import 'package:driver_taxi_app/order/cubit/order_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OrderCubit extends Cubit<OrderState>{
  OrderCubit() : super(OrderInitial());

  void orderUpcoming(OrderMessageModel orderMessageModel) {
    emit(OrderUpcoming(orderMessageModel));
  }

  void orderInProgress(OrderMessageModel orderMessageModel) {
    emit(OrderInProgress(orderMessageModel));
  }

  void orderCompleted(OrderMessageModel orderMessageModel) {
    emit(OrderCompleted(orderMessageModel));
  }
}
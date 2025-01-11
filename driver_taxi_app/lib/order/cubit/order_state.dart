import 'package:driver_taxi_app/models/order_message.dart';

abstract class OrderState {}

class OrderInitial extends OrderState {}

class OrderUpcoming extends OrderState {
  final OrderMessageModel orderMessageModel;

  OrderUpcoming(this.orderMessageModel);
}

class OrderInProgress extends OrderState {
  final OrderMessageModel orderMessageModel;

  OrderInProgress(this.orderMessageModel);
}

class OrderCompleted extends OrderState {
  final OrderMessageModel orderMessageModel;

  OrderCompleted(this.orderMessageModel);
}
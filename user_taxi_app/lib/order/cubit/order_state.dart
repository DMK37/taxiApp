abstract class OrderState {}

class OrderInitial extends OrderState {}

class OrderLoading extends OrderState {}

class OrderWaiting extends OrderState {}

class OrderSourceArrival extends OrderState {
  final String driverId;
  final int rideId;


  OrderSourceArrival({
    required this.driverId,
    required this.rideId,
  });
}

class OrderDestinationArrival extends OrderState {}

class OrderCancelled extends OrderState {}
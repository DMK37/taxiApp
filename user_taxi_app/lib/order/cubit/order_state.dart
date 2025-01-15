abstract class OrderState {}

class OrderInitial extends OrderState {}

class OrderLoading extends OrderState {}

class OrderWaiting extends OrderState {}

class OrderCompleted extends OrderState {}

class OrderSourceArrival extends OrderState {
  final String driverId;
  final int rideId;

  OrderSourceArrival({
    required this.driverId,
    required this.rideId,
  });
}

class OrderDestinationArrival extends OrderState {
  final int rideId;

  OrderDestinationArrival({
    required this.rideId,
  });
}

class OrderCancelled extends OrderState {}

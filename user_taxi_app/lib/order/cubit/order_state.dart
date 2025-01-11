abstract class OrderState {}

class OrderInitial extends OrderState {}

class OrderLoading extends OrderState {}

class OrderWaiting extends OrderState {}

class OrderSourceArrival extends OrderState {}

class OrderDestinationArrival extends OrderState {}

class OrderCancelled extends OrderState {}
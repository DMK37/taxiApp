import 'package:shared/models/car_type.dart';

class RidePriceModel {
  CarType carType;
  double price;

  RidePriceModel({required this.carType, required this.price});

  Map<String, dynamic> toJson() {
    return {
      'type': carType.value,
      'amount': price,
    };
  }

  factory RidePriceModel.fromJson(Map<String, dynamic> json) {
    return RidePriceModel(
      carType: CarType.fromValue(json['type']),
      price: json['amount'],
    );
  }
}
import 'package:shared/models/car_type.dart';

class CarModel {
  String carName;
  CarType carType;

  CarModel({required this.carName, required this.carType});

  Map<String, dynamic> toJson() {
    return {
      'carName': carName,
      'carType': carType.value,
    };
  }

  factory CarModel.fromJson(Map<String, dynamic> json) {
    return CarModel(
      carName: json['carName'],
      carType: CarType.fromValue(json['carType']),
    );
  }
}
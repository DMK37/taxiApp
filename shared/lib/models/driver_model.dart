import 'package:shared/models/car_model.dart';

class DriverModel {
  String id;
  String firstName;
  String lastName;
  CarModel car;
  DriverModel(
      {required this.id,
      required this.firstName,
      required this.lastName,
      required this.car});

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'car': car.toJson(),
    };
  }

  factory DriverModel.fromJson(Map<String, dynamic> json) {
    return DriverModel(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      car: CarModel.fromJson(json['car']),
    );
  }
}

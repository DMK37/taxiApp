import 'package:flutter/material.dart';

enum CarType {
  basic(1),
  comfort(2),
  premium(3);

  final int value;

  const CarType(this.value);

  factory CarType.fromValue(int value) {
    return CarType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => throw ArgumentError('Invalid TaxiType value: $value'),
    );
  }

  @override
  String toString() {
    switch (this) {
      case CarType.basic:
        return 'Basic';
      case CarType.comfort:
        return 'Comfort';
      case CarType.premium:
        return 'Premium';
    }
  }

  Icon getIcon() {
    switch (this) {
      case CarType.basic:
        return Icon(Icons.directions_car);
      case CarType.comfort:
        return Icon(Icons.local_taxi);
      case CarType.premium:
        return Icon(Icons.local_taxi_rounded);
    }
  }

  String getDescription() {
    switch (this) {
      case CarType.basic:
        return 'Affordable, everyday rides';
      case CarType.comfort:
        return 'Rides for groups up to 6';
      case CarType.premium:
        return 'Luxury rides with professional drivers';
    }
  }
}

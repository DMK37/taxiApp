import 'package:flutter/material.dart';
import 'package:shared/models/driver_model.dart';

class RideHistoryWidget extends StatelessWidget {
  const RideHistoryWidget({
    super.key,
    required BuildContext context,
    required this.driver,
    });

  final DriverModel driver;

  @override
  Widget build(BuildContext context) {
    return const SizedBox();
  }
}
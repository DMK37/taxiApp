import 'package:driver_taxi_app/models/order_message.dart';
import 'package:flutter/material.dart';

class OrderInProgressPage extends StatefulWidget {
  const OrderInProgressPage({super.key, required this.message});
  final OrderMessageModel message;

  @override
  State<OrderInProgressPage> createState() => _OrderInProgressPageState();
}

class _OrderInProgressPageState extends State<OrderInProgressPage> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
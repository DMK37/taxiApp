import 'package:driver_taxi_app/models/order_message.dart';
import 'package:flutter/material.dart';

class OrderCompletedPage extends StatefulWidget {
  const OrderCompletedPage({super.key, required this.message});
  final OrderMessageModel message;

  @override
  State<OrderCompletedPage> createState() => _OrderCompletedPageState();
}

class _OrderCompletedPageState extends State<OrderCompletedPage> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
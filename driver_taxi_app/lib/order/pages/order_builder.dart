import 'package:driver_taxi_app/models/order_message.dart';
import 'package:driver_taxi_app/order/cubit/order_cubit.dart';
import 'package:driver_taxi_app/order/cubit/order_state.dart';
import 'package:driver_taxi_app/order/pages/order_completed_page.dart';
import 'package:driver_taxi_app/order/pages/order_in_progress_page.dart';
import 'package:driver_taxi_app/order/pages/order_upcoming_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OrderBuilder extends StatelessWidget {
  const OrderBuilder({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrderCubit, OrderState>(
      builder: (context, state) {
        switch (state) {
          case OrderUpcoming(
              orderMessageModel: OrderMessageModel orderMessageModel
            ):
            return OrderUpcomingPage(
              message: orderMessageModel,
            );
          case OrderInProgress(
              orderMessageModel: OrderMessageModel orderMessageModel
            ):
            return OrderInProgressPage(
              message: orderMessageModel,
            );
          case OrderCompleted(
              orderMessageModel: OrderMessageModel orderMessageModel
            ):
            return OrderCompletedPage(
              message: orderMessageModel,
            );
          default:
            return const Scaffold(
              body: Center(
                child: Text('Something went wrong!'),
              ),
            );
        }
      },
    );
  }
}

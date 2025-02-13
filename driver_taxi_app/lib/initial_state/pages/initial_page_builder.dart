import 'package:driver_taxi_app/initial_state/cubit/initial_cubit.dart';
import 'package:driver_taxi_app/initial_state/cubit/initial_state.dart';
import 'package:driver_taxi_app/initial_state/pages/initial_page.dart';
import 'package:driver_taxi_app/initial_state/pages/order_completed_page.dart';
import 'package:driver_taxi_app/initial_state/pages/order_in_progress_page.dart';
import 'package:driver_taxi_app/initial_state/pages/received_message_page.dart';
import 'package:driver_taxi_app/models/order_message.dart';
import 'package:driver_taxi_app/initial_state/pages/order_upcoming_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class InitialPageBuilder extends StatelessWidget {
  const InitialPageBuilder({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<DriverInitCubit, DriverState>(
      listener: (context, state) {},
      child: BlocBuilder<DriverInitCubit, DriverState>(
        builder: (context, state) {
          switch (state) {
            case DriverOfflineState() || DriverOnlineState():
              return const InitialDriverPage();
            case DriverMessagedState(message: OrderMessageModel message):
              return ReceivedMessagePage(
                message: message,
              );
            case UpcomingOrderState(message: OrderMessageModel message):
              return OrderUpcomingPage(message: message);
            case InProgressOrderState(
                orderMessageModel: OrderMessageModel orderMessageModel
              ):
              return OrderInProgressPage(message: orderMessageModel);
            case CompletedOrderState(
                orderMessageModel: OrderMessageModel orderMessageModel
              ):
              return OrderCompletedPage(message: orderMessageModel);
            default:
              return const Scaffold(
                body: Center(
                  child: Text('Something went wrong (init)!'),
                ),
              );
          }
        },
      ),
    );
  }
}

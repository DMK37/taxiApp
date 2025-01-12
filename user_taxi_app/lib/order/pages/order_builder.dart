import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:taxiapp/initial_order/cubit/initial_order_cubit.dart';
import 'package:taxiapp/order/cubit/order_cubit.dart';
import 'package:taxiapp/order/cubit/order_state.dart';
import 'package:taxiapp/order/pages/upcoming_page.dart';
import 'package:taxiapp/order/pages/waiting_page.dart';

class OrderBuilder extends StatelessWidget {
  const OrderBuilder({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<OrderCubit, OrderState>(
      listener: (context, state) {
        if (state is OrderCancelled) {
          context.read<InitialOrderCubit>().clearPoints();
          context.go('/');
        }
      },
      child: BlocBuilder<OrderCubit, OrderState>(
        builder: (context, state) {
          switch (state) {
            case OrderWaiting():
              return const WaitingPage();
            case OrderLoading():
              return const Scaffold(
                  body: Center(child: CircularProgressIndicator()));
            case OrderSourceArrival(
                rideId: int rideId,
                driverId: String driverId
              ):
              return UpcomingPage(rideId: rideId, driverId: driverId);

            // case OrderDestinationArrival():
            //   return const DestinationArrivalPage();

            default:
              return const SizedBox.shrink();
          }
        },
      ),
    );
  }
}

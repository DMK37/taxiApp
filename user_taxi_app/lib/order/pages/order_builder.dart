import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taxiapp/order/cubit/order_cubit.dart';
import 'package:taxiapp/order/cubit/order_state.dart';
import 'package:taxiapp/order/pages/waiting_page.dart';

class OrderBuilder extends StatelessWidget {
  const OrderBuilder({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrderCubit, OrderState>(
      builder: (context, state) {
        switch (state) {
          case OrderWaiting():
            return const WaitingPage();

          // case OrderSourceArrival():
          //   return const SourceArrivalPage();

          // case OrderDestinationArrival():
          //   return const DestinationArrivalPage();

          default:
            return const SizedBox.shrink();
        }
      },
    );
  }
}

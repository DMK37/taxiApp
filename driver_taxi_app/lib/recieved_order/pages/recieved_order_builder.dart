import 'package:driver_taxi_app/recieved_order/cubit/recieved_order_cubit.dart';
import 'package:driver_taxi_app/recieved_order/cubit/recieved_order_state.dart';
import 'package:driver_taxi_app/recieved_order/pages/recieved_order_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RecievedOrderBuilder extends StatelessWidget {
  const RecievedOrderBuilder({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RecievedOrderCubit, RecievedOrderState>(
      builder: (context, state) {
        switch(state) {
          case RecievedInitState():
            return const RecievedOrderPage();

          default:
            return const SizedBox.shrink();
        }
    },
    );
  }
}

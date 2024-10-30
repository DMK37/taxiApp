import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:taxiapp/initial_order/cubit/initial_order_cubit.dart';
import 'package:taxiapp/initial_order/cubit/initial_order_state.dart';
import 'package:taxiapp/initial_order/pages/initial_order_page.dart';
import 'package:taxiapp/initial_order/pages/order_type_page.dart';

class InitialOrderBuilder extends StatelessWidget {
  const InitialOrderBuilder({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InitialOrderCubit, InitialOrderState>(
      builder: (context, state) {
        switch (state) {
          case OrderInitial():
            return const InitialOrderPage();

          case OrderWithPoints():
            return const OrderTypePage();

          default:
            return const SizedBox.shrink();
        }
      },
    );
  }
}
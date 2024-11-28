import 'package:driver_taxi_app/auth/cubit/auth_cubit.dart';
import 'package:driver_taxi_app/auth/cubit/auth_state.dart';
import 'package:driver_taxi_app/auth/pages/login_page.dart';
import 'package:shared/widgets/error_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class AuthListenerWrapper extends StatelessWidget {
  final Widget child;

  const AuthListenerWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocListener<DriverAuthCubit, DriverAuthState>(
      listener: (context, state) {
        if (state is DriverAuthFailureState) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.transparent,
            elevation: 0,
            content: ErrorSnackBar(
              errorMessage: state.errorMessage,
            ),
          ));
          context.go('/');
        }
        if (state is DriverUnauthenticatedState) {
          context.go('/');
        }
      },
      child: BlocBuilder<DriverAuthCubit, DriverAuthState>(builder: (context, state) {

        switch (state) {
          case DriverAuthLoadingState():
            return const Center(child: CircularProgressIndicator());
          case DriverAuthenticatedState():
            return child;
          case DriverUnauthenticatedState():
              return DriverLoginPage();
              //return child;

          default:
            return const SizedBox.shrink();
        }
      }),
    );
  }
}

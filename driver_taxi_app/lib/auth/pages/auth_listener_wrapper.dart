import 'package:driver_taxi_app/auth/cubit/auth_cubit.dart';
import 'package:driver_taxi_app/auth/cubit/auth_state.dart';
import 'package:driver_taxi_app/auth/pages/login_page.dart';
import 'package:driver_taxi_app/auth/pages/register_page.dart';
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
          print("driver failure");
          context.go('/login');
        }
        if (state is DriverUnauthenticatedState) {
          print("driver unauth");
          context.go('/login');
        }
        if (state is DriverAuthenticatedState) {
          print("driver logged in");
          context.go('/');
        }
      },
      child: BlocBuilder<DriverAuthCubit, DriverAuthState>(
          builder: (context, state) {
        switch (state) {
          case DriverAuthLoadingState():
            return const Scaffold(
                body: Center(child: CircularProgressIndicator()));
          case DriverAuthenticatedState():
            return child;
          case DriverUnauthenticatedState():
            return const DriverLoginPage();

          case DriverFirstLoginState(address: String address):
            return RegisterPage(address: address);
          default:
            return const Scaffold(
              body: Center(
                child: Text('Something went wrong!'),
              ),
            );
        }
      }),
    );
  }
}

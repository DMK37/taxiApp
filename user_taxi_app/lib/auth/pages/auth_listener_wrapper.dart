import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:taxiapp/auth/cubit/auth_cubit.dart';
import 'package:taxiapp/auth/cubit/auth_state.dart';
import 'package:taxiapp/auth/pages/login_page.dart';
import 'package:taxiapp/components/error_snack_bar.dart';

class AuthListenerWrapper extends StatelessWidget {
  final Widget child;

  const AuthListenerWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthFailureState) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.transparent,
            elevation: 0,
            content: ErrorSnackBar(
              errorMessage: state.errorMessage,
            ),
          ));
          context.go('/login');
        }
        if (state is UnauthenticatedState) {
          context.go('/login');
        }
        if (state is AuthenticatedState) {
          context.go('/');
        }
      },
      child: BlocBuilder<AuthCubit, AuthState>(builder: (context, state) {

        switch (state) {
          case AuthLoadingState():
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          case AuthenticatedState():
            return child;
          case UnauthenticatedState():
            return  const LoginPage();
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
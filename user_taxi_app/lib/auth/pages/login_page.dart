import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taxiapp/auth/cubit/auth_cubit.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              'assets/images/MetaMask_Fox.png',
              height: 200,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                context.read<AuthCubit>().signIn();
              },
              child: const Text('Connect MetaMask'),
            ),
          ],
        ),
      ),
    );
  }
}

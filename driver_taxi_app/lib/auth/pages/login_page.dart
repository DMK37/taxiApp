import 'package:driver_taxi_app/auth/cubit/auth_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DriverLoginPage extends StatelessWidget {
  DriverLoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              'packages/shared/assets/images/MetaMask_Fox.png',
              height: 200,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                //context.read<DriverAuthCubit>().signIn();
                
              },
              child: const Text('Connect MetaMask'),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:driver_taxi_app/auth/cubit/auth_cubit.dart';
import 'package:flutter/material.dart';
import 'package:reown_appkit/reown_appkit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DriverLoginPage extends StatefulWidget {
  const DriverLoginPage({super.key});

  @override
  State<DriverLoginPage> createState() => _DriverLoginPageState();
}

class _DriverLoginPageState extends State<DriverLoginPage> {
  late ReownAppKitModal _appKitModal;

  @override
  void initState() {
    super.initState();
    final appKit = context.read<DriverAuthCubit>().appKit;

    _appKitModal = ReownAppKitModal(
      context: context,
      appKit: appKit,
      
    );
    _appKitModal.init();
    _appKitModal.disconnect();
  }

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
            // ElevatedButton(
            //   onPressed: () async {
            //     //context.read<DriverAuthCubit>().signIn();
                
            //     context.push('/map');
            //   },
            //   child: const Text('Connect MetaMask'),
            // ),
            AppKitModalConnectButton(
              appKit: _appKitModal,
            ),
          ],
        ),
      ),
    );
  }
}

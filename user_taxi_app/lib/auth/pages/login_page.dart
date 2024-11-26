import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reown_appkit/reown_appkit.dart';
import 'package:taxiapp/auth/cubit/auth_cubit.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late ReownAppKitModal _appKitModal;
  @override
  void initState() {
    super.initState();
    final appKit = context.read<AuthCubit>().appKit;
    final testNetworks = ReownAppKitModalNetworks.test['eip155'] ?? [];
    ReownAppKitModalNetworks.addNetworks('eip155', testNetworks);
    _appKitModal = ReownAppKitModal(
      context: context,
      appKit: appKit,
      
    );
    _appKitModal.init();

    context.read<AuthCubit>().isConnected(_appKitModal);
  }

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
            AppKitModalConnectButton(
              appKit: _appKitModal,
            ),
            // AppKitModalAccountButton(appKit: _appKitModal),
          ],
        ),
      ),
    );
  }
}

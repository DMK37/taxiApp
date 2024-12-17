import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared/utils/custom_http_override.dart';
import 'firebase/firebase_options.dart';
import 'package:shared/repositories/client/client_repository.dart';

import 'package:taxiapp/auth/cubit/auth_cubit.dart';
import 'package:taxiapp/initial_order/cubit/initial_order_cubit.dart';
import 'package:taxiapp/location/cubit/location_cubit.dart';
import 'package:taxiapp/ride/cubit/ride_cubit.dart';
import 'package:taxiapp/router_config.dart';
import 'package:taxiapp/theme/light_theme.dart';


void main() async {
  final appRouter = AppRouter();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // only for development ---
  // [TODO] uncomment for check on ios
  if (const bool.fromEnvironment('dart.vm.product') == false) {
    HttpOverrides.global = CustomHttpOverrides();
  }
  // ---
  runApp(MyApp(router: appRouter.router));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.router});
  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => LocationCubit()..checkPermissionsAndGetLocation(),
          ),
          BlocProvider(
            create: (context) => AuthCubit(ClientRepository())..init(),
          ),
          BlocProvider(
            create: (context) => InitialOrderCubit(),
          ),
          BlocProvider(create: (context) => RideCubit()),
        ],
        child: MaterialApp.router(
          routerConfig: router,
          title: 'Taxi App',
          debugShowCheckedModeBanner: false,
          theme: lightTheme,
        ));
  }
}

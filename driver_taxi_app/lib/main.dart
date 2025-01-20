import 'dart:io';

import 'package:driver_taxi_app/auth/cubit/auth_cubit.dart';
import 'package:driver_taxi_app/initial_state/cubit/initial_cubit.dart';
import 'package:driver_taxi_app/location/cubit/location_cubit.dart';
import 'package:driver_taxi_app/router_config.dart';
import 'package:driver_taxi_app/theme/theme_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared/repositories/driver/driver_repository.dart';
import 'package:shared/theme/dark_theme.dart';
import 'package:shared/theme/light_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase/firebase_options.dart';
import 'package:shared/utils/custom_http_override.dart';
import 'package:flutter_driver/driver_extension.dart';

void main() async {
  final appRouter = AppRouter();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (const bool.fromEnvironment('dart.vm.product') == false) {
    HttpOverrides.global = CustomHttpOverrides();
  }
  enableFlutterDriverExtension();
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeNotifier(),
      child: MyApp(router: appRouter.router),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.router});
  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => LocationCubit()..checkPerrmissionsAndGetLocation(),
          ),
          BlocProvider(
            create: (context) => DriverAuthCubit(DriverRepository())..init(),
          ),
          BlocProvider(create: (context) => DriverInitCubit()),
        ],
        child: MaterialApp.router(
          routerConfig: router,
          title: 'Taxi Driver App',
          debugShowCheckedModeBanner: false,
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: Provider.of<ThemeNotifier>(context).themeMode,
        ));
  }
}

import 'package:driver_taxi_app/auth/cubit/auth_cubit.dart';
import 'package:driver_taxi_app/auth/repository/metamask_repository.dart';
import 'package:driver_taxi_app/initial_state/cubit/initial_cubit.dart';
import 'package:driver_taxi_app/location/cubit/location_cubit.dart';
import 'package:driver_taxi_app/router_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared/theme/light_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase/firebase_options.dart';

void main() async {
  final appRouter = AppRouter();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
            create: (context) => DriverLocationCubit()..checkPerrmissionsAndGetLocation(),
          ),
          BlocProvider(
            create: (context) => DriverAuthCubit(MetamaskDriverRepository()),
          ),
          BlocProvider(create: 
          (context) => DriverInitCubit()
          ),
        ],
        child: MaterialApp.router(
          routerConfig: router,
          title: 'Taxi Driver App',
          debugShowCheckedModeBanner: false,
          theme: lightTheme,
        ));
  }
}

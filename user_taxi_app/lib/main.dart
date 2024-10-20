import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:taxiapp/auth/cubit/auth_cubit.dart';
import 'package:taxiapp/auth/repository/metamask_repository.dart';
import 'package:taxiapp/initial_order/cubit/initial_order_cubit.dart';
import 'package:taxiapp/location/cubit/location_cubit.dart';
import 'package:taxiapp/router_config.dart';
import 'package:taxiapp/theme/light_theme.dart';

void main() async {
  final appRouter = AppRouter();
  WidgetsFlutterBinding.ensureInitialized();
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
            create: (context) =>
                LocationCubit()..checkPermissionsAndGetLocation(),
          ),
          BlocProvider(
            create: (context) =>
                AuthCubit(MetamaskRepository())..isAuthenticated(),
          ),
          BlocProvider(
            create: (context) => InitialOrderCubit(),
          )
        ],
        child: MaterialApp.router(
          routerConfig: router,
          title: 'Taxi App',
          debugShowCheckedModeBanner: false,
          theme: lightTheme,
        ));
  }
}
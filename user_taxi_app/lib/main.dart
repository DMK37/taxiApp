import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:taxiapp/auth/cubit/auth_cubit.dart';
import 'package:taxiapp/auth/pages/auth_listener_wrapper.dart';
import 'package:taxiapp/auth/repository/metamask_repository.dart';
import 'package:taxiapp/router_config.dart';

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
                AuthCubit(MetamaskRepository())..isAuthenticated(),
          ),
        ],
        child: AuthListenerWrapper(
            child: MaterialApp.router(
          routerConfig: router,
          title: 'Taxi App',
          debugShowCheckedModeBanner: false,
        )));
  }
}

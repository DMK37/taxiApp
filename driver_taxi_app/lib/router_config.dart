import 'package:driver_taxi_app/auth/pages/auth_listener_wrapper.dart';
import 'package:driver_taxi_app/auth/pages/login_page.dart';
import 'package:driver_taxi_app/initial_state/pages/initial_page_builder.dart';
import 'package:driver_taxi_app/location/pages/location_listener_wrapper.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  final router = GoRouter(routes: [
    GoRoute(
      path: '/map',
      builder: (context, state) => const LocationListenerWrapper(
        child: AuthListenerWrapper(child: InitialPageBuilder()),
      ),
    ),
    GoRoute(
      path: '/',
      builder: (context, state) =>
          AuthListenerWrapper(child: DriverLoginPage()),
    )
  ]);
}
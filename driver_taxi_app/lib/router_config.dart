import 'package:driver_taxi_app/auth/pages/auth_listener_wrapper.dart';
import 'package:driver_taxi_app/auth/pages/login_page.dart';
import 'package:driver_taxi_app/driver/pages/driver_page.dart';
import 'package:driver_taxi_app/initial_state/pages/initial_page_builder.dart';
import 'package:driver_taxi_app/location/pages/location_listener_wrapper.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  final router = GoRouter(routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const LocationListenerWrapper(
        child: AuthListenerWrapper(child: InitialPageBuilder()),
      ),
    ),
    GoRoute(
        path: '/driver',
        builder: (context, state) =>
            const AuthListenerWrapper(child: DriverPage())),
    GoRoute(
      path: '/login',
      builder: (context, state) =>
          const AuthListenerWrapper(child: DriverLoginPage()),
    ),
    // GoRoute(
    //     path: '/order',
    //     builder: (context, state) => const LocationListenerWrapper(
    //         child: AuthListenerWrapper(child: OrderBuilder()))),
  ]);
}

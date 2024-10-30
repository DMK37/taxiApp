import 'package:go_router/go_router.dart';
import 'package:taxiapp/auth/pages/auth_listener_wrapper.dart';
import 'package:taxiapp/auth/pages/login_page.dart';
import 'package:taxiapp/initial_order/pages/initial_order_builder.dart';
import 'package:taxiapp/location/pages/location_listener_wrapper.dart';

class AppRouter {
  final router = GoRouter(routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const LocationListenerWrapper(
        child: AuthListenerWrapper(child: InitialOrderBuilder()),
      ),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
  ]);
}

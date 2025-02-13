import 'package:go_router/go_router.dart';
import 'package:taxiapp/auth/pages/auth_listener_wrapper.dart';
import 'package:taxiapp/auth/pages/login_page.dart';
import 'package:taxiapp/initial_order/pages/initial_order_builder.dart';
import 'package:taxiapp/location/pages/location_listener_wrapper.dart';
import 'package:taxiapp/order/pages/order_builder.dart';
import 'package:taxiapp/user/pages/user_page.dart';

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
      builder: (context, state) =>
          const AuthListenerWrapper(child: LoginPage()),
    ),
    GoRoute(
        path: '/user',
        builder: (context, state) =>
            const AuthListenerWrapper(child: UserPage())),
    GoRoute(
        path: '/order',
        builder: (context, state) => const LocationListenerWrapper(
            child: AuthListenerWrapper(child: OrderBuilder()))),
  ]);
}

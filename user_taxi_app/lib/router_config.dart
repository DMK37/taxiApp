import 'package:go_router/go_router.dart';
import 'package:taxiapp/temp/maps_view.dart';

class AppRouter {
  final router = GoRouter(routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const  MapsView(),
    ),
  ]);
}

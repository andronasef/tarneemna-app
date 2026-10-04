import 'package:go_router/go_router.dart';
import '../screens/home/home_screen.dart';
import '../screens/settings/settings_screen.dart';

abstract class Routes {
  static const home = '/';
  static const settings = '/settings';
}

final appRouter = GoRouter(
  initialLocation: Routes.home,
  routes: [
    GoRoute(
      path: Routes.home,
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: Routes.settings,
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);

abstract class AppPages {
  static const initial = Routes.home;
  static final routes = [
    Routes.home,
    Routes.settings,
  ];
}

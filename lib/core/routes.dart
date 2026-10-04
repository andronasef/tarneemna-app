import 'package:go_router/go_router.dart';
import 'package:tarneemna/features/downloads/presentation/screens/offline_downloads_screen.dart';
import 'package:tarneemna/features/downloads/presentation/screens/storage_manager_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/settings/settings_screen.dart';

abstract class Routes {
  static const home = '/';
  static const settings = '/settings';
  static const downloads = '/downloads';
  static const storage = '/storage';
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
    GoRoute(
      path: Routes.downloads,
      builder: (context, state) => const OfflineDownloadsScreen(),
    ),
    GoRoute(
      path: Routes.storage,
      builder: (context, state) => const StorageManagerScreen(),
    ),
  ],
);

abstract class AppPages {
  static const initial = Routes.home;
  static final routes = [
    Routes.home,
    Routes.settings,
    Routes.downloads,
    Routes.storage,
  ];
}

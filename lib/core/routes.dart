import 'package:go_router/go_router.dart';
import 'package:tarneemna/features/albums/presentation/screens/albums_screen.dart';
import 'package:tarneemna/features/downloads/presentation/screens/offline_downloads_screen.dart';
import 'package:tarneemna/features/downloads/presentation/screens/storage_manager_screen.dart';
import 'package:tarneemna/features/library/presentation/screens/favorites_screen.dart';
import 'package:tarneemna/features/library/presentation/screens/history_screen.dart';
import 'package:tarneemna/features/library/presentation/screens/playlists_screen.dart';
import 'package:tarneemna/features/settings/presentation/screens/settings_screen.dart';
import 'package:tarneemna/features/singers/presentation/screens/singers_screen.dart';
import '../screens/home/home_screen.dart';

abstract class Routes {
  static const home = '/';
  static const settings = '/settings';
  static const downloads = '/downloads';
  static const storage = '/storage';
  static const singers = '/singers';
  static const albums = '/albums';
  static const favorites = '/favorites';
  static const playlists = '/playlists';
  static const history = '/history';
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
      builder: (context, state) => const ModernSettingsScreen(),
    ),
    GoRoute(
      path: Routes.downloads,
      builder: (context, state) => const OfflineDownloadsScreen(),
    ),
    GoRoute(
      path: Routes.storage,
      builder: (context, state) => const StorageManagerScreen(),
    ),
    GoRoute(
      path: Routes.singers,
      builder: (context, state) => const SingersScreen(),
    ),
    GoRoute(
      path: Routes.albums,
      builder: (context, state) => const AlbumsScreen(),
    ),
    GoRoute(
      path: Routes.favorites,
      builder: (context, state) => const FavoritesScreen(),
    ),
    GoRoute(
      path: Routes.playlists,
      builder: (context, state) => const PlaylistsScreen(),
    ),
    GoRoute(
      path: Routes.history,
      builder: (context, state) => const HistoryScreen(),
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
    Routes.singers,
    Routes.albums,
    Routes.favorites,
    Routes.playlists,
    Routes.history,
  ];
}

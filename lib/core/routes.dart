import 'package:get/get.dart';
import '../screens/home/home_screen.dart';

// ignore: avoid_classes_with_only_static_members
abstract class AppPages {
  static const initial = Routes.home;
  static final routes = [
    GetPage(name: Routes.home, page: () => const HomeScreen()),
  ];
}

abstract class Routes {
  static const home = '/home';
}

import 'package:get/get.dart';

import '../screens/home/home_controller.dart';

class AppController extends GetxController {}

class AppControllerBinder implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AppController>(() => AppController());
    Get.lazyPut<HomeController>(() => HomeController());
  }
}

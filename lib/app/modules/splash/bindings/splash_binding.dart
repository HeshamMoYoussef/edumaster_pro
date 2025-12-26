import 'package:get/get.dart';

import '../controllers/splash_controller.dart';

/// Splash screen binding
class SplashBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SplashController>(() => SplashController());
  }
}

import 'package:get/get.dart';

import '../controllers/home_controller.dart';

/// Home module binding
class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController(), fenix: true);
  }
}

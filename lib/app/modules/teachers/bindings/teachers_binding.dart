import 'package:get/get.dart';

import '../controllers/teachers_controller.dart';

/// Teachers module binding
class TeachersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TeachersController>(() => TeachersController(), fenix: true);
  }
}

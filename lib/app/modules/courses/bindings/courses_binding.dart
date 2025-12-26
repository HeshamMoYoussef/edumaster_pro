import 'package:get/get.dart';

import '../controllers/courses_controller.dart';

/// Courses module binding
class CoursesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CoursesController>(() => CoursesController(), fenix: true);
  }
}

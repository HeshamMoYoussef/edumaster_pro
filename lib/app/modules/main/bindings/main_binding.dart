import 'package:get/get.dart';

import '../controllers/main_controller.dart';
import '../../home/bindings/home_binding.dart';
import '../../courses/bindings/courses_binding.dart';
import '../../teachers/bindings/teachers_binding.dart';
import '../../sessions/bindings/sessions_binding.dart';
import '../../profile/bindings/profile_binding.dart';

/// Main module binding
class MainBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MainController>(() => MainController());

    // Initialize child module bindings
    HomeBinding().dependencies();
    CoursesBinding().dependencies();
    TeachersBinding().dependencies();
    SessionsBinding().dependencies();
    ProfileBinding().dependencies();
  }
}

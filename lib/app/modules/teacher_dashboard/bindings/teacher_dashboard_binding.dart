import 'package:get/get.dart';

import '../controllers/teacher_dashboard_controller.dart';

/// Teacher Dashboard Binding
class TeacherDashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TeacherDashboardController>(
      () => TeacherDashboardController(),
      fenix: true,
    );
  }
}

import 'package:get/get.dart';

import '../controllers/auth_controller.dart';

/// Auth module binding
class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthController>(() => AuthController(), fenix: true);
  }
}

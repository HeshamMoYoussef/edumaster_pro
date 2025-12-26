import 'package:get/get.dart';

import '../controllers/sessions_controller.dart';
import '../controllers/live_session_controller.dart';
import '../controllers/book_session_controller.dart';

class SessionsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SessionsController>(() => SessionsController(), fenix: true);
    Get.lazyPut<LiveSessionController>(() => LiveSessionController(), fenix: true);
    Get.lazyPut<BookSessionController>(() => BookSessionController(), fenix: true);
  }
}

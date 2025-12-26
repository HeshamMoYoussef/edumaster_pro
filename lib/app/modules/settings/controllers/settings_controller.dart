import 'package:get/get.dart';
import '../../../global/controllers/theme_controller.dart';
import '../../../global/controllers/locale_controller.dart';
import '../../../global/controllers/app_controller.dart';
import '../../../routes/app_routes.dart';

class SettingsController extends GetxController {
  final ThemeController themeController = Get.find();
  final LocaleController localeController = Get.find();
  final AppController _appController = Get.find();

  /// تسجيل الخروج
  Future<void> logout() async {
    await _appController.clearUser();
    Get.offAllNamed(Routes.login);
  }
}

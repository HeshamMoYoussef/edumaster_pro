import 'package:get/get.dart';

import '../../core/network/api_client.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/course_repository.dart';
import '../../data/repositories/teacher_repository.dart';
import '../../data/repositories/session_repository.dart';
import '../../data/repositories/wallet_repository.dart';
import '../../data/repositories/achievement_repository.dart';
import '../../data/repositories/user_repository.dart';
import '../../global/controllers/app_controller.dart';
import '../../global/controllers/theme_controller.dart';
import '../../global/controllers/locale_controller.dart';

/// Initial binding for core services and repositories
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Core Services (Permanent)
    // Note: StorageService is already initialized in main.dart
    // Only register ApiClient here
    if (!Get.isRegistered<ApiClient>()) {
      Get.put(ApiClient(), permanent: true);
    }

    // Global Controllers (Permanent)
    if (!Get.isRegistered<AppController>()) {
      Get.put(AppController(), permanent: true);
    }
    if (!Get.isRegistered<ThemeController>()) {
      Get.put(ThemeController(), permanent: true);
    }
    if (!Get.isRegistered<LocaleController>()) {
      Get.put(LocaleController(), permanent: true);
    }

    // Repositories (Lazy with fenix for recreation)
    Get.lazyPut(() => AuthRepository(), fenix: true);
    Get.lazyPut(() => CourseRepository(), fenix: true);
    Get.lazyPut(() => TeacherRepository(), fenix: true);
    Get.lazyPut(() => SessionRepository(), fenix: true);
    Get.lazyPut(() => WalletRepository(), fenix: true);
    Get.lazyPut(() => AchievementRepository(), fenix: true);
    Get.lazyPut(() => UserRepository(), fenix: true);
  }
}

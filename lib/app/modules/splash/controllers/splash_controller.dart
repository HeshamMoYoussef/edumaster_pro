import 'package:get/get.dart';

import '../../../core/utils/storage_service.dart';
import '../../../routes/app_routes.dart';
import '../../../global/controllers/app_controller.dart';
import '../../../data/repositories/user_repository.dart';

/// Splash screen controller
class SplashController extends GetxController {
  final StorageService _storage = Get.find();
  final AppController _appController = Get.find();

  final _isLoading = true.obs;
  bool get isLoading => _isLoading.value;

  final _loadingProgress = 0.0.obs;
  double get loadingProgress => _loadingProgress.value;

  @override
  void onInit() {
    super.onInit();
    _initializeApp();
  }

  /// Initialize app and navigate accordingly
  Future<void> _initializeApp() async {
    try {
      // Simulate loading progress
      await _updateProgress(0.2);
      await Future.delayed(const Duration(milliseconds: 300));

      // Load essential data
      await _updateProgress(0.4);
      await Future.delayed(const Duration(milliseconds: 300));

      // Check authentication
      await _updateProgress(0.6);
      await Future.delayed(const Duration(milliseconds: 300));

      // Load user data if logged in
      if (_storage.isLoggedIn) {
        try {
          final userRepo = Get.find<UserRepository>();
          final user = await userRepo.getProfile();
          await _appController.updateUser(user);
        } catch (e) {
          // If failed to get user, clear auth
          await _storage.clearAuthData();
        }
      }

      await _updateProgress(0.8);
      await Future.delayed(const Duration(milliseconds: 300));

      // Finalize
      await _updateProgress(1.0);
      await Future.delayed(const Duration(milliseconds: 500));

      // Navigate based on state
      _navigate();
    } catch (e) {
      // On error, still try to navigate
      _navigate();
    }
  }

  Future<void> _updateProgress(double value) async {
    _loadingProgress.value = value;
  }

  void _navigate() {
    // Check if first time user
    if (_storage.isFirstTime) {
      Get.offAllNamed(Routes.onboarding);
      return;
    }

    // Check if logged in
    if (_storage.isLoggedIn) {
      Get.offAllNamed(Routes.main);
      return;
    }

    // Go to login
    Get.offAllNamed(Routes.login);
  }
}

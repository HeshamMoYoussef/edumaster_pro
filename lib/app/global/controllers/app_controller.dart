import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../../core/utils/storage_service.dart';
import '../../data/models/user_model.dart';

/// Global application controller
class AppController extends GetxController {
  final StorageService _storage = Get.find();

  // Current user
  final _currentUser = Rxn<UserModel>();
  UserModel? get currentUser => _currentUser.value;
  set currentUser(UserModel? user) => _currentUser.value = user;

  // App state
  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;
  set isLoading(bool value) => _isLoading.value = value;

  // Network status
  final _isOnline = true.obs;
  bool get isOnline => _isOnline.value;
  set isOnline(bool value) => _isOnline.value = value;

  // Notification badge count
  final _notificationCount = 0.obs;
  int get notificationCount => _notificationCount.value;
  set notificationCount(int value) => _notificationCount.value = value;

  @override
  void onInit() {
    super.onInit();
    _loadUser();
    _initConnectivityListener();
  }

  /// Load user from storage
  void _loadUser() {
    final userData = _storage.getUserData();
    if (userData != null) {
      _currentUser.value = UserModel.fromJson(userData);
    }
  }

  /// Initialize connectivity listener
  void _initConnectivityListener() {
    // TODO: Implement connectivity listener
  }

  /// Update current user
  Future<void> updateUser(UserModel user) async {
    _currentUser.value = user;
    await _storage.setUserData(user.toJson());
  }

  /// Clear user data (logout)
  Future<void> clearUser() async {
    _currentUser.value = null;
    await _storage.clearAuthData();
  }

  /// Check if user is logged in
  bool get isLoggedIn => _storage.isLoggedIn && _currentUser.value != null;

  /// Check if user is student
  bool get isStudent => currentUser?.role == UserRole.student;

  /// Check if user is parent
  bool get isParent => currentUser?.role == UserRole.parent;

  /// Check if user is teacher
  bool get isTeacher => currentUser?.role == UserRole.teacher;

  /// Show global loading indicator
  void showLoading() => _isLoading.value = true;

  /// Hide global loading indicator
  void hideLoading() => _isLoading.value = false;

  /// Show snackbar message
  void showMessage(String message, {bool isError = false}) {
    Get.snackbar(
      isError ? 'خطأ' : 'تنبيه',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor:
          isError ? Colors.red.withValues(alpha: 0.9) : Colors.green.withValues(alpha: 0.9),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 3),
    );
  }
}

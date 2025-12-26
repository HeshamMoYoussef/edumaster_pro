import 'dart:convert';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../constants/app_constants.dart';

/// Service for local storage operations using GetStorage
class StorageService extends GetxService {
  late final GetStorage _storage;

  /// Initialize the storage service
  Future<StorageService> init() async {
    await GetStorage.init('EduMasterPro');
    _storage = GetStorage('EduMasterPro');
    return this;
  }

  // ============ Generic Methods ============

  /// Write a value to storage
  Future<void> write<T>(String key, T value) async {
    await _storage.write(key, value);
  }

  /// Read a value from storage
  T? read<T>(String key) {
    return _storage.read<T>(key);
  }

  /// Check if a key exists in storage
  bool hasData(String key) {
    return _storage.hasData(key);
  }

  /// Remove a key from storage
  Future<void> remove(String key) async {
    await _storage.remove(key);
  }

  /// Clear all storage
  Future<void> clearAll() async {
    await _storage.erase();
  }

  // ============ Auth Token Methods ============

  /// Get the auth token
  String? get authToken => read<String>(AppConstants.storageKeyToken);

  /// Set the auth token
  Future<void> setAuthToken(String token) async {
    await write(AppConstants.storageKeyToken, token);
  }

  /// Get the refresh token
  String? get refreshToken => read<String>(AppConstants.storageKeyRefreshToken);

  /// Set the refresh token
  Future<void> setRefreshToken(String token) async {
    await write(AppConstants.storageKeyRefreshToken, token);
  }

  /// Clear auth tokens
  Future<void> clearAuthTokens() async {
    await remove(AppConstants.storageKeyToken);
    await remove(AppConstants.storageKeyRefreshToken);
  }

  /// Check if user is logged in
  bool get isLoggedIn => authToken != null && authToken!.isNotEmpty;

  // ============ User Data Methods ============

  /// Get user data as Map
  Map<String, dynamic>? get userData {
    final data = read<String>(AppConstants.storageKeyUser);
    if (data == null) return null;
    return json.decode(data) as Map<String, dynamic>;
  }

  /// Set user data
  Future<void> setUserData(Map<String, dynamic> data) async {
    await write(AppConstants.storageKeyUser, json.encode(data));
  }

  /// Clear user data
  Future<void> clearUserData() async {
    await remove(AppConstants.storageKeyUser);
  }

  // ============ Theme Methods ============

  /// Get theme mode (0: system, 1: light, 2: dark)
  int get themeMode => read<int>(AppConstants.storageKeyTheme) ?? 0;

  /// Set theme mode
  Future<void> setThemeMode(int mode) async {
    await write(AppConstants.storageKeyTheme, mode);
  }

  /// Check if dark mode is enabled
  bool get isDarkMode => themeMode == 2;

  // ============ Locale Methods ============

  /// Get locale code (e.g., 'ar', 'en')
  String get locale => read<String>(AppConstants.storageKeyLocale) ?? 'ar';

  /// Set locale
  Future<void> setLocale(String localeCode) async {
    await write(AppConstants.storageKeyLocale, localeCode);
  }

  /// Check if Arabic is the current locale
  bool get isArabic => locale == 'ar';

  // ============ Onboarding Methods ============

  /// Check if onboarding is completed
  bool get isOnboardingCompleted =>
      read<bool>(AppConstants.storageKeyOnboarding) ?? false;

  /// Set onboarding as completed
  Future<void> setOnboardingCompleted() async {
    await write(AppConstants.storageKeyOnboarding, true);
  }

  // ============ First Launch Methods ============

  /// Check if this is the first launch
  bool get isFirstLaunch =>
      read<bool>(AppConstants.storageKeyFirstLaunch) ?? true;

  /// Set first launch as complete
  Future<void> setFirstLaunchComplete() async {
    await write(AppConstants.storageKeyFirstLaunch, false);
  }

  // ============ Notification Methods ============

  /// Check if notifications are enabled
  bool get notificationsEnabled =>
      read<bool>(AppConstants.storageKeyNotifications) ?? true;

  /// Set notifications enabled/disabled
  Future<void> setNotificationsEnabled(bool enabled) async {
    await write(AppConstants.storageKeyNotifications, enabled);
  }

  // ============ Cache Methods ============

  /// Save data with expiry time
  Future<void> saveWithExpiry(
    String key,
    dynamic value, {
    Duration expiry = const Duration(hours: 24),
  }) async {
    final expiryTime = DateTime.now().add(expiry).millisecondsSinceEpoch;
    await write(key, {
      'data': value,
      'expiry': expiryTime,
    });
  }

  /// Read data with expiry check
  T? readWithExpiry<T>(String key) {
    final data = read<Map<String, dynamic>>(key);
    if (data == null) return null;

    final expiryTime = data['expiry'] as int?;
    if (expiryTime == null) return data['data'] as T?;

    if (DateTime.now().millisecondsSinceEpoch > expiryTime) {
      remove(key);
      return null;
    }

    return data['data'] as T?;
  }

  // ============ Logout ============

  /// Clear all user-related data on logout
  Future<void> logout() async {
    await clearAuthTokens();
    await clearUserData();
    // Keep settings like theme and locale
  }

  // ============ Compatibility Methods ============

  /// Alias for getting user data (for compatibility)
  Map<String, dynamic>? getUserData() => userData;

  /// Clear all auth related data
  Future<void> clearAuthData() async {
    await clearAuthTokens();
    await clearUserData();
  }

  /// Get locale (method version for compatibility)
  String getLocale() => locale;

  /// Get theme mode (method version for compatibility)
  int getThemeMode() => themeMode;

  /// Check if this is the first time (alias for isFirstLaunch)
  bool get isFirstTime => isFirstLaunch;

  /// Set first time complete (alias)
  Future<void> setFirstTime(bool value) async {
    await write(AppConstants.storageKeyFirstLaunch, !value);
  }

  /// Set token (alias for setAuthToken)
  Future<void> setToken(String token) async {
    await setAuthToken(token);
  }
}

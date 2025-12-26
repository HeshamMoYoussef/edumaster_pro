import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/utils/storage_service.dart';

/// Theme controller for managing app theme
class ThemeController extends GetxController {
  final StorageService _storage = Get.find();

  final _themeMode = ThemeMode.system.obs;
  ThemeMode get themeMode => _themeMode.value;

  @override
  void onInit() {
    super.onInit();
    _loadTheme();
  }

  /// Load theme from storage
  void _loadTheme() {
    final themeModeIndex = _storage.getThemeMode();
    _themeMode.value = ThemeMode.values[themeModeIndex];
    }

  /// Check if dark mode is active
  bool get isDarkMode {
    if (_themeMode.value == ThemeMode.system) {
      return Get.isPlatformDarkMode;
    }
    return _themeMode.value == ThemeMode.dark;
  }

  /// Set theme mode
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode.value = mode;
    Get.changeThemeMode(mode);
    await _storage.setThemeMode(mode.index);
  }

  /// Toggle between light and dark mode
  Future<void> toggleTheme() async {
    if (isDarkMode) {
      await setThemeMode(ThemeMode.light);
    } else {
      await setThemeMode(ThemeMode.dark);
    }
  }

  /// Set system theme
  Future<void> useSystemTheme() async {
    await setThemeMode(ThemeMode.system);
  }

  /// Get theme mode name in Arabic
  String get themeModeName {
    switch (_themeMode.value) {
      case ThemeMode.light:
        return 'فاتح';
      case ThemeMode.dark:
        return 'داكن';
      case ThemeMode.system:
        return 'تلقائي';
    }
  }

  /// Get theme mode icon
  IconData get themeModeIcon {
    switch (_themeMode.value) {
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.dark:
        return Icons.dark_mode;
      case ThemeMode.system:
        return Icons.brightness_auto;
    }
  }
}

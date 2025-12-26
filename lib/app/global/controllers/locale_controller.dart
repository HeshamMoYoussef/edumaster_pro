import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/utils/storage_service.dart';

/// Locale controller for managing app language
class LocaleController extends GetxController {
  final StorageService _storage = Get.find();

  // Supported locales
  static const Locale arabicLocale = Locale('ar', 'SA');
  static const Locale englishLocale = Locale('en', 'US');

  static const List<Locale> supportedLocales = [
    arabicLocale,
    englishLocale,
  ];

  final _currentLocale = arabicLocale.obs;
  Locale get currentLocale => _currentLocale.value;

  @override
  void onInit() {
    super.onInit();
    _loadLocale();
  }

  /// Load locale from storage
  void _loadLocale() {
    final localeCode = _storage.getLocale();
    final parts = localeCode.split('_');
    if (parts.length == 2) {
      _currentLocale.value = Locale(parts[0], parts[1]);
    }
    }

  /// Check if current locale is Arabic
  bool get isArabic => _currentLocale.value.languageCode == 'ar';

  /// Check if current locale is English
  bool get isEnglish => _currentLocale.value.languageCode == 'en';

  /// Check if current locale is RTL
  bool get isRtl => isArabic;

  /// Set locale
  Future<void> setLocale(Locale locale) async {
    _currentLocale.value = locale;
    Get.updateLocale(locale);
    await _storage.setLocale('${locale.languageCode}_${locale.countryCode}');
  }

  /// Toggle between Arabic and English
  Future<void> toggleLocale() async {
    if (isArabic) {
      await setLocale(englishLocale);
    } else {
      await setLocale(arabicLocale);
    }
  }

  /// Get locale name
  String get localeName {
    if (isArabic) return 'العربية';
    return 'English';
  }

  /// Get locale flag emoji
  String get localeFlag {
    if (isArabic) return '🇸🇦';
    return '🇺🇸';
  }

  /// Get text direction
  TextDirection get textDirection {
    return isRtl ? TextDirection.rtl : TextDirection.ltr;
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../constants/color_constants.dart';

/// Helper functions for the application
class Helpers {
  Helpers._();

  /// Format currency with SAR symbol
  static String formatCurrency(double amount, {String symbol = 'ر.س'}) {
    final formatter = NumberFormat('#,##0.00', 'ar_SA');
    return '${formatter.format(amount)} $symbol';
  }

  /// Format number with thousands separator
  static String formatNumber(num number) {
    final formatter = NumberFormat('#,##0', 'ar_SA');
    return formatter.format(number);
  }

  /// Format compact number (e.g., 1.5K, 2M)
  static String formatCompactNumber(num number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  /// Format duration in hours and minutes
  static String formatDuration(int minutes) {
    if (minutes < 60) {
      return '$minutes ${'minute'.tr}';
    }
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    if (remainingMinutes == 0) {
      return '$hours ${hours == 1 ? 'hour'.tr : 'hours'.tr}';
    }
    return '$hours:${remainingMinutes.toString().padLeft(2, '0')} ${'hour'.tr}';
  }

  /// Format date to readable string
  static String formatDate(DateTime date, {String? pattern}) {
    final formatter = DateFormat(pattern ?? 'dd MMM yyyy', 'ar_SA');
    return formatter.format(date);
  }

  /// Format time to readable string
  static String formatTime(DateTime time) {
    final formatter = DateFormat('hh:mm a', 'ar_SA');
    return formatter.format(time);
  }

  /// Format date and time
  static String formatDateTime(DateTime dateTime) {
    return '${formatDate(dateTime)} - ${formatTime(dateTime)}';
  }

  /// Get relative time string (e.g., "2 hours ago")
  static String getRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '${'ago'.tr} ${years == 1 ? 'year'.tr : '$years ${'years'.tr}'}';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '${'ago'.tr} ${months == 1 ? 'month'.tr : '$months ${'months'.tr}'}';
    } else if (difference.inDays > 7) {
      final weeks = (difference.inDays / 7).floor();
      return '${'ago'.tr} ${weeks == 1 ? 'week'.tr : '$weeks ${'weeks'.tr}'}';
    } else if (difference.inDays > 0) {
      return '${'ago'.tr} ${difference.inDays == 1 ? 'day'.tr : '${difference.inDays} ${'days'.tr}'}';
    } else if (difference.inHours > 0) {
      return '${'ago'.tr} ${difference.inHours == 1 ? 'hour'.tr : '${difference.inHours} ${'hours'.tr}'}';
    } else if (difference.inMinutes > 0) {
      return '${'ago'.tr} ${difference.inMinutes == 1 ? 'minute'.tr : '${difference.inMinutes} ${'minutes'.tr}'}';
    } else {
      return 'just_now'.tr;
    }
  }

  /// Get greeting based on time of day
  static String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'good_morning'.tr;
    } else if (hour < 17) {
      return 'good_afternoon'.tr;
    } else {
      return 'good_evening'.tr;
    }
  }

  /// Get initials from name
  static String getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '';
    if (parts.length == 1) {
      return parts[0].isNotEmpty ? parts[0][0].toUpperCase() : '';
    }
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  /// Truncate string with ellipsis
  static String truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  /// Get color from level
  static Color getLevelColor(String level) {
    switch (level.toLowerCase()) {
      case 'beginner':
      case 'مبتدئ':
        return AppColors.levelBeginner;
      case 'intermediate':
      case 'متوسط':
        return AppColors.levelIntermediate;
      case 'advanced':
      case 'متقدم':
        return AppColors.levelAdvanced;
      case 'expert':
      case 'خبير':
        return AppColors.levelExpert;
      default:
        return AppColors.primary;
    }
  }

  /// Get category color
  static Color getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'math':
      case 'رياضيات':
        return AppColors.categoryMath;
      case 'science':
      case 'علوم':
        return AppColors.categoryScience;
      case 'language':
      case 'لغات':
        return AppColors.categoryLanguage;
      case 'art':
      case 'فنون':
        return AppColors.categoryArt;
      case 'music':
      case 'موسيقى':
        return AppColors.categoryMusic;
      case 'history':
      case 'تاريخ':
        return AppColors.categoryHistory;
      case 'technology':
      case 'تقنية':
        return AppColors.categoryTech;
      default:
        return AppColors.primary;
    }
  }

  /// Show success snackbar
  static void showSuccess(String message) {
    Get.snackbar(
      'success'.tr,
      message,
      backgroundColor: AppColors.success,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      icon: const Icon(Icons.check_circle, color: Colors.white),
    );
  }

  /// Show error snackbar
  static void showError(String message) {
    Get.snackbar(
      'error'.tr,
      message,
      backgroundColor: AppColors.error,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      icon: const Icon(Icons.error, color: Colors.white),
    );
  }

  /// Show warning snackbar
  static void showWarning(String message) {
    Get.snackbar(
      'warning'.tr,
      message,
      backgroundColor: AppColors.warning,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      icon: const Icon(Icons.warning, color: Colors.white),
    );
  }

  /// Show info snackbar
  static void showInfo(String message) {
    Get.snackbar(
      'info'.tr,
      message,
      backgroundColor: AppColors.info,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      icon: const Icon(Icons.info, color: Colors.white),
    );
  }

  /// Show loading dialog
  static void showLoading({String? message}) {
    Get.dialog(
      PopScope(
        canPop: false,
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Get.theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                if (message != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    message,
                    style: Get.textTheme.bodyMedium,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  /// Hide loading dialog
  static void hideLoading() {
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
  }

  /// Show confirmation dialog
  static Future<bool> showConfirmation({
    required String title,
    required String message,
    String? confirmText,
    String? cancelText,
    bool isDangerous = false,
  }) async {
    confirmText ??= 'confirm'.tr;
    cancelText ??= 'cancel'.tr;
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: isDangerous
                ? ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: Colors.white,
                  )
                : null,
            child: Text(confirmText),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// Copy text to clipboard
  static Future<void> copyToClipboard(String text) async {
    // await Clipboard.setData(ClipboardData(text: text));
    showSuccess('copied'.tr);
  }

  /// Check if device is in dark mode
  static bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  /// Check if device is mobile
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 600;
  }

  /// Check if device is tablet
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 600 && width < 1200;
  }

  /// Check if device is desktop
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1200;
  }

  /// Get responsive value based on screen size
  static T responsive<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop(context)) {
      return desktop ?? tablet ?? mobile;
    } else if (isTablet(context)) {
      return tablet ?? mobile;
    }
    return mobile;
  }

  /// Calculate percentage
  static double calculatePercentage(num value, num total) {
    if (total == 0) return 0;
    return (value / total) * 100;
  }

  /// Format percentage
  static String formatPercentage(double percentage, {int decimals = 0}) {
    return '${percentage.toStringAsFixed(decimals)}%';
  }
}

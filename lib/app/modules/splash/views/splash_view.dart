import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/color_constants.dart';
import '../../../core/constants/app_constants.dart';
import '../controllers/splash_controller.dart';

/// Splash screen view
class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [
                    AppColors.primaryDark,
                    AppColors.backgroundDark,
                  ]
                : [
                    AppColors.primary,
                    AppColors.primaryLight,
                  ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

              // Logo
              _buildLogo(isDark),

              const SizedBox(height: AppConstants.paddingXL),

              // App name
              _buildAppName(),

              const SizedBox(height: AppConstants.paddingS),

              // Tagline
              _buildTagline(),

              const Spacer(flex: 2),

              // Loading indicator
              _buildLoadingIndicator(),

              const SizedBox(height: AppConstants.paddingXL),

              // Version
              _buildVersion(),

              const SizedBox(height: AppConstants.paddingXL),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo(bool isDark) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          Icons.school_rounded,
          size: 60,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildAppName() {
    return const Text(
      'EduMaster Pro',
      style: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildTagline() {
    return Text(
      'منصة التعليم الذكي',
      style: TextStyle(
        fontSize: 16,
        color: Colors.white.withValues(alpha: 0.9),
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Obx(() {
      return Column(
        children: [
          // Progress bar
          Container(
            width: 200,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
            child: Align(
              alignment: Alignment.centerRight,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 200 * controller.loadingProgress,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppConstants.paddingM),

          // Loading text
          Text(
            _getLoadingText(),
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ],
      );
    });
  }

  String _getLoadingText() {
    final progress = controller.loadingProgress;
    if (progress < 0.3) return 'جاري التحميل...';
    if (progress < 0.5) return 'جاري تحميل البيانات...';
    if (progress < 0.7) return 'جاري التحقق...';
    if (progress < 0.9) return 'جاري التحضير...';
    return 'جاهز!';
  }

  Widget _buildVersion() {
    return Text(
      'الإصدار 1.0.0',
      style: TextStyle(
        fontSize: 12,
        color: Colors.white.withValues(alpha: 0.6),
      ),
    );
  }
}

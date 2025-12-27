import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/utils/storage_service.dart';
import '../../../routes/app_routes.dart';

/// Onboarding page data
class OnboardingPage {
  final String titleKey;
  final String descriptionKey;
  final IconData icon;
  final Color color;

  const OnboardingPage({
    required this.titleKey,
    required this.descriptionKey,
    required this.icon,
    required this.color,
  });

  String get title => titleKey.tr;
  String get description => descriptionKey.tr;
}

/// Onboarding controller
class OnboardingController extends GetxController {
  final StorageService _storage = Get.find();

  final pageController = PageController();

  final _currentPage = 0.obs;
  int get currentPage => _currentPage.value;

  final pages = <OnboardingPage>[
    OnboardingPage(
      titleKey: 'onboarding_learn_smart',
      descriptionKey: 'onboarding_learn_smart_desc',
      icon: Icons.psychology,
      color: const Color(0xFF7C3AED),
    ),
    OnboardingPage(
      titleKey: 'onboarding_great_teachers',
      descriptionKey: 'onboarding_great_teachers_desc',
      icon: Icons.people,
      color: const Color(0xFF10B981),
    ),
    OnboardingPage(
      titleKey: 'onboarding_diverse_courses',
      descriptionKey: 'onboarding_diverse_courses_desc',
      icon: Icons.menu_book,
      color: const Color(0xFF3B82F6),
    ),
    OnboardingPage(
      titleKey: 'onboarding_achievements',
      descriptionKey: 'onboarding_achievements_desc',
      icon: Icons.emoji_events,
      color: const Color(0xFFF59E0B),
    ),
  ];

  bool get isLastPage => _currentPage.value == pages.length - 1;

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  void onPageChanged(int page) {
    _currentPage.value = page;
  }

  void nextPage() {
    if (isLastPage) {
      finishOnboarding();
    } else {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void skipOnboarding() {
    finishOnboarding();
  }

  void finishOnboarding() {
    _storage.setFirstTime(false);
    Get.offAllNamed(Routes.login);
  }
}

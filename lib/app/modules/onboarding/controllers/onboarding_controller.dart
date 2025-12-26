import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/utils/storage_service.dart';
import '../../../routes/app_routes.dart';

/// Onboarding page data
class OnboardingPage {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  const OnboardingPage({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}

/// Onboarding controller
class OnboardingController extends GetxController {
  final StorageService _storage = Get.find();

  final pageController = PageController();

  final _currentPage = 0.obs;
  int get currentPage => _currentPage.value;

  final pages = <OnboardingPage>[
    OnboardingPage(
      title: 'تعلم بذكاء',
      description:
          'استفد من الذكاء الاصطناعي لتخصيص تجربة تعلمك وتحقيق أهدافك بشكل أسرع',
      icon: Icons.psychology,
      color: const Color(0xFF7C3AED),
    ),
    OnboardingPage(
      title: 'معلمون متميزون',
      description:
          'تواصل مع أفضل المعلمين في مختلف المجالات واحجز جلسات خاصة مباشرة',
      icon: Icons.people,
      color: const Color(0xFF10B981),
    ),
    OnboardingPage(
      title: 'كورسات متنوعة',
      description:
          'مئات الكورسات في مختلف المواد الدراسية والمهارات العملية',
      icon: Icons.menu_book,
      color: const Color(0xFF3B82F6),
    ),
    OnboardingPage(
      title: 'إنجازات ومكافآت',
      description:
          'اجمع النقاط والشارات وتنافس مع الآخرين على لوحة المتصدرين',
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

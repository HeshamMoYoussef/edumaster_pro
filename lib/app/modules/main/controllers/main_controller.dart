import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Main controller for bottom navigation
class MainController extends GetxController {
  final _currentIndex = 0.obs;
  int get currentIndex => _currentIndex.value;
  set currentIndex(int index) => _currentIndex.value = index;

  final pageController = PageController();

  final List<BottomNavItem> navItems = const [
    BottomNavItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      label: 'الرئيسية',
    ),
    BottomNavItem(
      icon: Icons.school_outlined,
      activeIcon: Icons.school,
      label: 'الكورسات',
    ),
    BottomNavItem(
      icon: Icons.people_outlined,
      activeIcon: Icons.people,
      label: 'المعلمون',
    ),
    BottomNavItem(
      icon: Icons.calendar_today_outlined,
      activeIcon: Icons.calendar_today,
      label: 'الجلسات',
    ),
    BottomNavItem(
      icon: Icons.person_outlined,
      activeIcon: Icons.person,
      label: 'حسابي',
    ),
  ];

  void changePage(int index) {
    _currentIndex.value = index;
    pageController.jumpToPage(index);
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}

class BottomNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const BottomNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

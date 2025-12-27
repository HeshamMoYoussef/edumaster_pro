import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Main controller for bottom navigation
class MainController extends GetxController {
  final _currentIndex = 0.obs;
  int get currentIndex => _currentIndex.value;
  set currentIndex(int index) => _currentIndex.value = index;

  final pageController = PageController();

  List<BottomNavItem> get navItems => [
    BottomNavItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      labelKey: 'home',
    ),
    BottomNavItem(
      icon: Icons.school_outlined,
      activeIcon: Icons.school,
      labelKey: 'courses',
    ),
    BottomNavItem(
      icon: Icons.people_outlined,
      activeIcon: Icons.people,
      labelKey: 'teachers',
    ),
    BottomNavItem(
      icon: Icons.calendar_today_outlined,
      activeIcon: Icons.calendar_today,
      labelKey: 'sessions',
    ),
    BottomNavItem(
      icon: Icons.person_outlined,
      activeIcon: Icons.person,
      labelKey: 'my_account',
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
  final String labelKey;

  const BottomNavItem({
    required this.icon,
    required this.activeIcon,
    required this.labelKey,
  });

  String get label => labelKey.tr;
}

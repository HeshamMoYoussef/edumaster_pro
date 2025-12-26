import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/color_constants.dart';
import '../../../global/widgets/loading_widget.dart';
import '../../../routes/app_routes.dart';
import '../controllers/teacher_dashboard_controller.dart';
import 'widgets/teacher_home_tab.dart';
import 'widgets/teacher_schedule_tab.dart';
import 'widgets/teacher_students_tab.dart';
import 'widgets/teacher_earnings_tab.dart';

/// Teacher Dashboard View
class TeacherDashboardView extends GetView<TeacherDashboardController> {
  const TeacherDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (controller.isLoading) {
          return const LoadingWidget();
        }

        return IndexedStack(
          index: controller.currentIndex,
          children: const [
            TeacherHomeTab(),
            TeacherScheduleTab(),
            TeacherStudentsTab(),
            TeacherEarningsTab(),
          ],
        );
      }),
      bottomNavigationBar: Obx(() => NavigationBar(
        selectedIndex: controller.currentIndex,
        onDestinationSelected: (index) => controller.currentIndex = index,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'الرئيسية',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_today_outlined),
            selectedIcon: Icon(Icons.calendar_today),
            label: 'الجدول',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: 'الطلاب',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet),
            label: 'الأرباح',
          ),
        ],
      )),
    );
  }
}

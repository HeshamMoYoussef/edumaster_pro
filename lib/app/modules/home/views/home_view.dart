import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/color_constants.dart';
import '../../../routes/app_routes.dart';
import '../../../global/widgets/loading_widget.dart';
import '../controllers/home_controller.dart';
import 'widgets/home_header.dart';
import 'widgets/category_list.dart';
import 'widgets/course_card.dart';
import 'widgets/teacher_card.dart';
import 'widgets/session_card.dart';
import 'widgets/streak_card.dart';

/// Home screen view
class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (controller.isLoading) {
          return const LoadingWidget(message: 'جاري تحميل البيانات...');
        }

        return RefreshIndicator(
          onRefresh: controller.refresh,
          color: AppColors.primary,
          child: CustomScrollView(
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: HomeHeader(
                  greeting: controller.greeting,
                  userName: controller.userName,
                ),
              ),

              // ========================================
              // زر اختبار البث المباشر - للتطوير فقط
              // TODO: إزالته في الإنتاج
              // ========================================
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.paddingM),
                  child: Container(
                    padding: const EdgeInsets.all(AppConstants.paddingM),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppConstants.radiusL),
                      border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.developer_mode, color: Colors.green[700], size: 18),
                            const SizedBox(width: 8),
                            Text(
                              'اختبار البث المباشر',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.green[800],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppConstants.paddingM),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => Get.toNamed(Routes.liveSessionPath('session_1')),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            icon: const Icon(Icons.videocam),
                            label: const Text('دخول جلسة تجريبية'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Streak card
              if (controller.streak != null)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.paddingM,
                    ),
                    child: StreakCard(
                      streak: controller.streak!,
                      onCheckIn: controller.checkIn,
                    ),
                  ),
                ),

              // Categories
              SliverToBoxAdapter(
                child: _buildSection(
                  title: 'التصنيفات',
                  child: CategoryList(
                    categories: controller.categories,
                    onCategoryTap: (category) {
                      Get.toNamed(
                        Routes.courses,
                        arguments: {'categoryId': category.id},
                      );
                    },
                  ),
                ),
              ),

              // Continue learning
              if (controller.myEnrollments.isNotEmpty)
                SliverToBoxAdapter(
                  child: _buildSection(
                    title: 'متابعة التعلم',
                    onSeeAll: () => Get.toNamed(Routes.courses),
                    child: SizedBox(
                      height: 220,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.paddingM,
                        ),
                        itemCount: controller.myEnrollments.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(width: AppConstants.paddingM),
                        itemBuilder: (context, index) {
                          final enrollment = controller.myEnrollments[index];
                          if (enrollment.course == null) {
                            return const SizedBox.shrink();
                          }
                          return CourseCard(
                            course: enrollment.course!,
                            progress: enrollment.progress,
                            onTap: () => Get.toNamed(
                              Routes.courseDetailsPath(enrollment.courseId),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),

              // Upcoming sessions
              if (controller.upcomingSessions.isNotEmpty)
                SliverToBoxAdapter(
                  child: _buildSection(
                    title: 'الجلسات القادمة',
                    onSeeAll: () => Get.toNamed(Routes.sessions),
                    child: SizedBox(
                      height: 140,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.paddingM,
                        ),
                        itemCount: controller.upcomingSessions.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(width: AppConstants.paddingM),
                        itemBuilder: (context, index) {
                          return SessionCard(
                            session: controller.upcomingSessions[index],
                            onTap: () => Get.toNamed(
                              // TODO: في الإنتاج - تغيير إلى sessionDetailsPath
                              Routes.liveSessionPath(
                                controller.upcomingSessions[index].id,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),

              // Featured courses
              SliverToBoxAdapter(
                child: _buildSection(
                  title: 'كورسات مميزة',
                  onSeeAll: () => Get.toNamed(Routes.courses),
                  child: SizedBox(
                    height: 220,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.paddingM,
                      ),
                      itemCount: controller.featuredCourses.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: AppConstants.paddingM),
                      itemBuilder: (context, index) {
                        return CourseCard(
                          course: controller.featuredCourses[index],
                          onTap: () => Get.toNamed(
                            Routes.courseDetailsPath(
                              controller.featuredCourses[index].id,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),

              // Featured teachers
              SliverToBoxAdapter(
                child: _buildSection(
                  title: 'معلمون مميزون',
                  onSeeAll: () => Get.toNamed(Routes.teachers),
                  child: SizedBox(
                    height: 180,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.paddingM,
                      ),
                      itemCount: controller.featuredTeachers.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: AppConstants.paddingM),
                      itemBuilder: (context, index) {
                        return TeacherCard(
                          teacher: controller.featuredTeachers[index],
                          onTap: () => Get.toNamed(
                            Routes.teacherProfilePath(
                              controller.featuredTeachers[index].id,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),

              // Bottom spacing
              const SliverToBoxAdapter(
                child: SizedBox(height: AppConstants.paddingXXL),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSection({
    required String title,
    required Widget child,
    VoidCallback? onSeeAll,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: AppConstants.paddingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingM,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (onSeeAll != null)
                  TextButton(
                    onPressed: onSeeAll,
                    child: Text(
                      'عرض الكل',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppConstants.paddingM),
          child,
        ],
      ),
    );
  }
}

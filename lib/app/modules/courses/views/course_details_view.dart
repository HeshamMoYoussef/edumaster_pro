import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/color_constants.dart';
import '../../../global/widgets/loading_widget.dart';
import '../../../global/widgets/custom_button.dart';
import '../controllers/courses_controller.dart';

/// Course details view
class CourseDetailsView extends GetView<CoursesController> {
  const CourseDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final courseId = Get.parameters['id'];

    // Use addPostFrameCallback to avoid setState during build
    if (courseId != null && controller.selectedCourse?.id != courseId) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (controller.selectedCourse?.id != courseId) {
          controller.loadCourseDetails(courseId);
        }
      });
    }

    return Scaffold(
      body: Obx(() {
        if (controller.isLoading || controller.selectedCourse == null) {
          return const LoadingWidget();
        }

        final course = controller.selectedCourse!;

        return CustomScrollView(
          slivers: [
            // App bar with cover
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.primary,
                        AppColors.primaryDark,
                      ],
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.play_circle_outline,
                      size: 80,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ),
              ),
            ),

            // Content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.paddingM),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      course.title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: AppConstants.paddingS),

                    // Teacher
                    if (course.teacher != null)
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                            child: Text(
                              course.teacher!.fullName[0],
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            course.teacher!.fullName,
                            style: TextStyle(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),

                    const SizedBox(height: AppConstants.paddingM),

                    // Stats row
                    Row(
                      children: [
                        _StatItem(
                          icon: Icons.star,
                          value: course.formattedRating,
                          label: '(${course.totalReviews})',
                          color: AppColors.warning,
                        ),
                        const SizedBox(width: 24),
                        _StatItem(
                          icon: Icons.people_outline,
                          value: '${course.totalStudents}',
                          label: 'طالب',
                        ),
                        const SizedBox(width: 24),
                        _StatItem(
                          icon: Icons.schedule,
                          value: course.formattedDuration,
                          label: '',
                        ),
                        const SizedBox(width: 24),
                        _StatItem(
                          icon: Icons.play_lesson,
                          value: '${course.totalLessons}',
                          label: 'درس',
                        ),
                      ],
                    ),

                    const SizedBox(height: AppConstants.paddingL),
                    const Divider(),
                    const SizedBox(height: AppConstants.paddingL),

                    // Description
                    const Text(
                      'وصف الكورس',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingS),
                    Text(
                      course.description,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        height: 1.6,
                      ),
                    ),

                    // What you'll learn
                    if (course.whatYouWillLearn.isNotEmpty) ...[
                      const SizedBox(height: AppConstants.paddingL),
                      const Text(
                        'ماذا ستتعلم',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppConstants.paddingS),
                      ...course.whatYouWillLearn.map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.check_circle,
                                size: 20,
                                color: AppColors.success,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  item,
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],

                    // Requirements
                    if (course.requirements.isNotEmpty) ...[
                      const SizedBox(height: AppConstants.paddingL),
                      const Text(
                        'المتطلبات',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppConstants.paddingS),
                      ...course.requirements.map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.fiber_manual_record,
                                size: 8,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  item,
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 100), // Space for bottom bar
                  ],
                ),
              ),
            ),
          ],
        );
      }),

      // Bottom bar with price and enroll button
      bottomNavigationBar: Obx(() {
        if (controller.selectedCourse == null) return const SizedBox.shrink();
        final course = controller.selectedCourse!;

        return Container(
          padding: const EdgeInsets.all(AppConstants.paddingM),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: Row(
              children: [
                // Price
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (course.hasDiscount)
                      Text(
                        '${course.price.toInt()} ر.س',
                        style: TextStyle(
                          decoration: TextDecoration.lineThrough,
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    Text(
                      course.isFree
                          ? 'مجاني'
                          : '${course.effectivePrice.toInt()} ر.س',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),

                const SizedBox(width: 16),

                // Enroll button
                Expanded(
                  child: CustomButton(
                    text: 'سجل الآن',
                    onPressed: () => controller.enrollInCourse(course.id),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color? color;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: color ?? AppColors.textSecondary,
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        if (label.isNotEmpty) ...[
          const SizedBox(width: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}

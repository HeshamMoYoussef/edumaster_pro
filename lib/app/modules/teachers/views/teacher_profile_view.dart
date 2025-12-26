import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/color_constants.dart';
import '../../../global/widgets/loading_widget.dart';
import '../../../global/widgets/custom_button.dart';
import '../../../routes/app_routes.dart';
import '../controllers/teachers_controller.dart';

/// Teacher profile view
class TeacherProfileView extends GetView<TeachersController> {
  const TeacherProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final teacherId = Get.parameters['id'];

    // Use addPostFrameCallback to avoid setState during build
    if (teacherId != null && controller.selectedTeacher?.id != teacherId) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (controller.selectedTeacher?.id != teacherId) {
          controller.loadTeacherProfile(teacherId);
        }
      });
    }

    return Scaffold(
      body: Obx(() {
        if (controller.isLoading || controller.selectedTeacher == null) {
          return const LoadingWidget();
        }

        final teacher = controller.selectedTeacher!;

        return CustomScrollView(
          slivers: [
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
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.white,
                          child: Text(
                            teacher.fullName[0],
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.paddingM),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name and verification
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            teacher.fullName,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (teacher.isVerified)
                          Icon(
                            Icons.verified,
                            color: AppColors.info,
                          ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Subjects
                    Wrap(
                      spacing: 8,
                      children: teacher.subjects.map((subject) {
                        return Chip(
                          label: Text(subject),
                          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                          labelStyle: TextStyle(color: AppColors.primary),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: AppConstants.paddingL),

                    // Stats
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _StatColumn(
                          value: teacher.formattedRating,
                          label: 'التقييم',
                          icon: Icons.star,
                          iconColor: AppColors.warning,
                        ),
                        _StatColumn(
                          value: '${teacher.totalStudents}',
                          label: 'طالب',
                          icon: Icons.people,
                        ),
                        _StatColumn(
                          value: '${teacher.totalSessions}',
                          label: 'جلسة',
                          icon: Icons.video_call,
                        ),
                        _StatColumn(
                          value: teacher.experienceText,
                          label: 'خبرة',
                          icon: Icons.workspace_premium,
                        ),
                      ],
                    ),

                    const SizedBox(height: AppConstants.paddingL),
                    const Divider(),
                    const SizedBox(height: AppConstants.paddingL),

                    // Bio
                    if (teacher.bio != null) ...[
                      const Text(
                        'نبذة عني',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppConstants.paddingS),
                      Text(
                        teacher.bio!,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          height: 1.6,
                        ),
                      ),
                    ],

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        );
      }),

      bottomNavigationBar: Obx(() {
        if (controller.selectedTeacher == null) return const SizedBox.shrink();
        final teacher = controller.selectedTeacher!;

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
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${teacher.hourlyRate.toInt()} ر.س',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      'للساعة',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomButton(
                    text: 'احجز جلسة',
                    onPressed: () {
                      // Navigate to booking screen with teacher ID
                      Get.toNamed(Routes.bookSessionPath(teacher.id));
                    },
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

class _StatColumn extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color? iconColor;

  const _StatColumn({
    required this.value,
    required this.label,
    required this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: iconColor ?? AppColors.primary, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

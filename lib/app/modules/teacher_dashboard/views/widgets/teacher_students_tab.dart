import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/color_constants.dart';
import '../../controllers/teacher_dashboard_controller.dart';

/// Teacher Students Tab
class TeacherStudentsTab extends GetView<TeacherDashboardController> {
  const TeacherStudentsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('طلابي'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Show search
            },
          ),
        ],
      ),
      body: Obx(() {
        if (controller.students.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people_outline, size: 64, color: AppColors.textSecondary),
                const SizedBox(height: 16),
                Text(
                  'لا يوجد طلاب بعد',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(AppConstants.paddingM),
          itemCount: controller.students.length,
          itemBuilder: (context, index) {
            final student = controller.students[index];
            return _StudentCard(
              name: student.fullName,
              email: student.email,
              level: student.level,
              totalSessions: student.stats.sessionsAttended,
              lastSession: DateTime.now().subtract(Duration(days: index * 2)),
              onTap: () {
                // View student details
              },
              onMessage: () {
                // Send message
              },
            );
          },
        );
      }),
    );
  }
}

class _StudentCard extends StatelessWidget {
  final String name;
  final String email;
  final int level;
  final int totalSessions;
  final DateTime lastSession;
  final VoidCallback onTap;
  final VoidCallback onMessage;

  const _StudentCard({
    required this.name,
    required this.email,
    required this.level,
    required this.totalSessions,
    required this.lastSession,
    required this.onTap,
    required this.onMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    child: Text(
                      name[0],
                      style: TextStyle(
                        fontSize: 24,
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          email,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: onMessage,
                    icon: Icon(Icons.message, color: AppColors.primary),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _StatItem(
                    icon: Icons.school,
                    label: 'المستوى',
                    value: '$level',
                  ),
                  _StatItem(
                    icon: Icons.video_call,
                    label: 'الجلسات',
                    value: '$totalSessions',
                  ),
                  _StatItem(
                    icon: Icons.calendar_today,
                    label: 'آخر جلسة',
                    value: '${lastSession.day}/${lastSession.month}',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

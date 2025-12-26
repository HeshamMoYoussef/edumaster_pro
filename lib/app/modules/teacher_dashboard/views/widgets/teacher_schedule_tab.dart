import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/color_constants.dart';
import '../../../../data/models/session_model.dart';
import '../../controllers/teacher_dashboard_controller.dart';

/// Teacher Schedule Tab
class TeacherScheduleTab extends GetView<TeacherDashboardController> {
  const TeacherScheduleTab({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('الجدول'),
          centerTitle: true,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'القادمة'),
              Tab(text: 'المعلقة'),
              Tab(text: 'المكتملة'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildUpcomingSessions(),
            _buildPendingSessions(),
            _buildCompletedSessions(),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingSessions() {
    return Obx(() {
      if (controller.upcomingSessions.isEmpty) {
        return _buildEmptyState('لا توجد جلسات قادمة', Icons.event);
      }

      return ListView.builder(
        padding: const EdgeInsets.all(AppConstants.paddingM),
        itemCount: controller.upcomingSessions.length,
        itemBuilder: (context, index) {
          final session = controller.upcomingSessions[index];
          return _SessionCard(
            session: session,
            showActions: true,
            onStart: () => controller.startSession(session.id),
          );
        },
      );
    });
  }

  Widget _buildPendingSessions() {
    // Mock pending sessions
    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.paddingM),
      itemCount: 3,
      itemBuilder: (context, index) {
        return _PendingSessionCard(
          studentName: ['أحمد محمد', 'سارة علي', 'خالد عمر'][index],
          subject: ['رياضيات', 'فيزياء', 'كيمياء'][index],
          requestedTime: DateTime.now().add(Duration(days: index + 1)),
          duration: [60, 45, 90][index],
          onAccept: () => controller.acceptSession('session_$index'),
          onReject: () => controller.rejectSession('session_$index'),
        );
      },
    );
  }

  Widget _buildCompletedSessions() {
    return Obx(() {
      if (controller.completedSessions.isEmpty) {
        return _buildEmptyState('لا توجد جلسات مكتملة', Icons.check_circle);
      }

      return ListView.builder(
        padding: const EdgeInsets.all(AppConstants.paddingM),
        itemCount: controller.completedSessions.length,
        itemBuilder: (context, index) {
          final session = controller.completedSessions[index];
          return _SessionCard(
            session: session,
            showActions: false,
          );
        },
      );
    });
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: AppColors.textSecondary),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  final SessionModel session;
  final bool showActions;
  final VoidCallback? onStart;

  const _SessionCard({
    required this.session,
    this.showActions = false,
    this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  child: Text(
                    (session.student?.fullName ?? 'ط')[0],
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        session.student?.fullName ?? 'طالب',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        session.subject ?? 'جلسة',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                _StatusChip(status: session.status),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _InfoItem(
                  icon: Icons.calendar_today,
                  text: _formatDate(session.scheduledAt),
                ),
                const SizedBox(width: 16),
                _InfoItem(
                  icon: Icons.access_time,
                  text: _formatTime(session.scheduledAt),
                ),
                const SizedBox(width: 16),
                _InfoItem(
                  icon: Icons.timer,
                  text: '${session.durationMinutes} دقيقة',
                ),
              ],
            ),
            if (showActions && session.canJoin) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onStart,
                  icon: const Icon(Icons.video_call),
                  label: const Text('ابدأ الجلسة'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                  ),
                ),
              ),
            ],
            if (session.status == SessionStatus.completed && session.rating != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    session.rating!.toStringAsFixed(1),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  if (session.review != null) ...[
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        session.review!,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(DateTime date) {
    return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

class _PendingSessionCard extends StatelessWidget {
  final String studentName;
  final String subject;
  final DateTime requestedTime;
  final int duration;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const _PendingSessionCard({
    required this.studentName,
    required this.subject,
    required this.requestedTime,
    required this.duration,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.warning.withValues(alpha: 0.1),
                  child: Text(
                    studentName[0],
                    style: TextStyle(
                      color: AppColors.warning,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        studentName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        subject,
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'بانتظار الموافقة',
                    style: TextStyle(
                      color: AppColors.warning,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _InfoItem(
                  icon: Icons.calendar_today,
                  text: '${requestedTime.day}/${requestedTime.month}/${requestedTime.year}',
                ),
                const SizedBox(width: 16),
                _InfoItem(
                  icon: Icons.access_time,
                  text: '${requestedTime.hour}:${requestedTime.minute.toString().padLeft(2, '0')}',
                ),
                const SizedBox(width: 16),
                _InfoItem(
                  icon: Icons.timer,
                  text: '$duration دقيقة',
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onReject,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: BorderSide(color: AppColors.error),
                    ),
                    child: const Text('رفض'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onAccept,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                    ),
                    child: const Text('قبول'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final SessionStatus status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case SessionStatus.confirmed:
        color = AppColors.success;
        break;
      case SessionStatus.pending:
        color = AppColors.warning;
        break;
      case SessionStatus.completed:
        color = AppColors.info;
        break;
      case SessionStatus.cancelled:
        color = AppColors.error;
        break;
      default:
        color = AppColors.textSecondary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

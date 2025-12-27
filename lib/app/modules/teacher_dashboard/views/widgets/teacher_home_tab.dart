import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/color_constants.dart';
import '../../../../routes/app_routes.dart';
import '../../controllers/teacher_dashboard_controller.dart';

/// Teacher Home Tab
class TeacherHomeTab extends GetView<TeacherDashboardController> {
  const TeacherHomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('teacher_dashboard'.tr),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => Get.toNamed(Routes.notifications),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Get.toNamed(Routes.settings),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: controller.loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppConstants.paddingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting
              _buildGreeting(),
              const SizedBox(height: 24),

              // ========================================
              // Test live session button - for development only
              // TODO: Remove in production
              // ========================================
              _buildTestLiveSessionButton(),
              const SizedBox(height: 24),

              // Stats Cards
              _buildStatsGrid(),
              const SizedBox(height: 24),

              // Pending Requests
              if (controller.pendingRequests > 0) ...[
                _buildPendingRequestsCard(),
                const SizedBox(height: 24),
              ],

              // Today's Sessions
              _buildSectionTitle('today_sessions'.tr, onSeeAll: controller.goToSchedule),
              const SizedBox(height: 12),
              _buildTodaySessions(),
              const SizedBox(height: 24),

              // Quick Actions
              _buildSectionTitle('quick_actions'.tr),
              const SizedBox(height: 12),
              _buildQuickActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGreeting() {
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = 'good_morning'.tr;
    } else if (hour < 17) {
      greeting = 'good_afternoon'.tr;
    } else {
      greeting = 'good_evening'.tr;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greeting,
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${'teacher_prefix'.tr} ${controller.teacherName}',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid() {
    return Obx(() => GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _StatCard(
          title: 'total_students'.tr,
          value: '${controller.totalStudents}',
          icon: Icons.people,
          color: AppColors.primary,
          onTap: controller.goToStudents,
        ),
        _StatCard(
          title: 'completed_sessions'.tr,
          value: '${controller.totalSessions}',
          icon: Icons.video_call,
          color: AppColors.success,
          onTap: controller.goToSchedule,
        ),
        _StatCard(
          title: 'monthly_earnings'.tr,
          value: '${controller.monthlyEarnings.toInt()} ${'sar'.tr}',
          icon: Icons.account_balance_wallet,
          color: AppColors.warning,
          onTap: controller.goToEarnings,
        ),
        _StatCard(
          title: 'rating'.tr,
          value: controller.rating.toStringAsFixed(1),
          icon: Icons.star,
          color: Colors.amber,
        ),
      ],
    ));
  }

  Widget _buildPendingRequestsCard() {
    return Obx(() => Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.pending_actions, color: AppColors.warning),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'new_requests'.tr,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  'pending_booking_requests'.trParams({'count': '${controller.pendingRequests}'}),
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: controller.goToSchedule,
            child: Text('view'.tr),
          ),
        ],
      ),
    ));
  }

  Widget _buildSectionTitle(String title, {VoidCallback? onSeeAll}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        if (onSeeAll != null)
          TextButton(
            onPressed: onSeeAll,
            child: Text('see_all'.tr),
          ),
      ],
    );
  }

  Widget _buildTodaySessions() {
    return Obx(() {
      if (controller.todaySessions.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.event_available, size: 48, color: AppColors.textSecondary),
                const SizedBox(height: 12),
                Text(
                  'no_sessions_today'.tr,
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        );
      }

      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controller.todaySessions.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final session = controller.todaySessions[index];
          return _SessionCard(
            studentName: session.student?.fullName ?? 'student'.tr,
            subject: session.subject ?? 'session'.tr,
            time: '${session.scheduledAt.hour}:${session.scheduledAt.minute.toString().padLeft(2, '0')}',
            duration: '${session.durationMinutes} ${'minute'.tr}',
            canStart: session.canJoin,
            onStart: () => controller.startSession(session.id),
          );
        },
      );
    });
  }

  Widget _buildQuickActions() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _QuickActionButton(
          icon: Icons.schedule,
          label: 'manage_schedule'.tr,
          onTap: controller.goToSchedule,
        ),
        _QuickActionButton(
          icon: Icons.people,
          label: 'students_list'.tr,
          onTap: controller.goToStudents,
        ),
        _QuickActionButton(
          icon: Icons.analytics,
          label: 'reports'.tr,
          onTap: controller.goToEarnings,
        ),
        _QuickActionButton(
          icon: Icons.chat,
          label: 'messages'.tr,
          onTap: () {},
        ),
      ],
    );
  }

  /// Test live session button - for development only
  Widget _buildTestLiveSessionButton() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingM),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
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
                'test_live_session'.tr,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
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
              label: Text('start_test_session'.tr),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: color, size: 28),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
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

class _SessionCard extends StatelessWidget {
  final String studentName;
  final String subject;
  final String time;
  final String duration;
  final bool canStart;
  final VoidCallback onStart;

  const _SessionCard({
    required this.studentName,
    required this.subject,
    required this.time,
    required this.duration,
    required this.canStart,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            child: Text(
              studentName[0],
              style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(studentName, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  '$subject • $duration',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                time,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              if (canStart)
                ElevatedButton(
                  onPressed: onStart,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    minimumSize: Size.zero,
                  ),
                  child: Text('start'.tr, style: const TextStyle(fontSize: 12)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(label),
          ],
        ),
      ),
    );
  }
}

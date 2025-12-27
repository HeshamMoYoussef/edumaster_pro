import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/color_constants.dart';
import '../../../global/widgets/loading_widget.dart';
import '../../../routes/app_routes.dart';
import '../controllers/parent_controller.dart';

class ParentDashboardView extends GetView<ParentController> {
  const ParentDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (controller.isLoading) return const LoadingWidget();

        return IndexedStack(
          index: controller.currentIndex,
          children: [
            _buildHomeTab(),
            _buildChildrenTab(),
            _buildReportsTab(),
            _buildSettingsTab(),
          ],
        );
      }),
      bottomNavigationBar: Obx(() => NavigationBar(
        selectedIndex: controller.currentIndex,
        onDestinationSelected: (index) => controller.currentIndex = index,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: 'home'.tr,
          ),
          NavigationDestination(
            icon: const Icon(Icons.people_outline),
            selectedIcon: const Icon(Icons.people),
            label: 'my_children'.tr,
          ),
          NavigationDestination(
            icon: const Icon(Icons.analytics_outlined),
            selectedIcon: const Icon(Icons.analytics),
            label: 'reports'.tr,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings),
            label: 'settings'.tr,
          ),
        ],
      )),
    );
  }

  Widget _buildHomeTab() {
    return Scaffold(
      appBar: AppBar(
        title: Text('parent_dashboard'.tr),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => Get.toNamed(Routes.notifications),
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
              // Welcome
              Text(
                '${'hello'.tr}، ${controller.parentName}',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'follow_children_progress'.tr,
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),

              // Quick stats
              _buildQuickStats(),
              const SizedBox(height: 24),

              // Children overview
              _buildSectionTitle('my_children'.tr, onSeeAll: () => controller.currentIndex = 1),
              const SizedBox(height: 12),
              _buildChildrenList(),
              const SizedBox(height: 24),

              // Recent activity
              _buildSectionTitle('recent_activity'.tr),
              const SizedBox(height: 12),
              _buildRecentActivity(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    return Obx(() => Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.people,
            value: '${controller.children.length}',
            label: 'my_children'.tr,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.school,
            value: '${controller.children.fold<int>(0, (sum, c) => sum + c.stats.completedCourses)}',
            label: 'completed_courses'.tr,
            color: AppColors.success,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.access_time,
            value: '${(controller.children.fold<int>(0, (sum, c) => sum + c.stats.totalStudyMinutes) / 60).toInt()}${'h'.tr}',
            label: 'study_time'.tr,
            color: AppColors.info,
          ),
        ),
      ],
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

  Widget _buildChildrenList() {
    return Obx(() => Column(
      children: controller.children.map((child) => Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: InkWell(
          onTap: () => controller.viewChildProgress(child.id),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  child: Text(
                    child.fullName[0],
                    style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(child.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(
                        '${'level'.tr} ${child.level} • ${child.streak} ${'day_streak'.tr}',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${child.points}',
                      style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                    Text('points'.tr, style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                  ],
                ),
                const SizedBox(width: 8),
                Icon(Icons.chevron_right, color: AppColors.textSecondary),
              ],
            ),
          ),
        ),
      )).toList(),
    ));
  }

  Widget _buildRecentActivity() {
    // Mock activity
    final activities = [
      {'icon': Icons.check_circle, 'text': 'activity_completed_lesson'.trParams({'name': 'Ahmed', 'lesson': 'Linear Equations'}), 'time': 'time_ago_hour'.tr, 'color': AppColors.success},
      {'icon': Icons.video_call, 'text': 'activity_attended_session'.trParams({'name': 'Sara', 'teacher': 'Mr. Mohammed'}), 'time': 'time_ago_hours'.trParams({'count': '3'}), 'color': AppColors.info},
      {'icon': Icons.star, 'text': 'activity_earned_badge'.trParams({'name': 'Ahmed', 'badge': 'persistent'.tr}), 'time': 'time_ago_day'.tr, 'color': Colors.amber},
      {'icon': Icons.quiz, 'text': 'activity_completed_quiz'.trParams({'name': 'Sara', 'subject': 'subject_physics'.tr, 'score': '85'}), 'time': 'time_ago_days'.trParams({'count': '2'}), 'color': AppColors.primary},
    ];

    return Column(
      children: activities.map((activity) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (activity['color'] as Color).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(activity['icon'] as IconData, color: activity['color'] as Color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(activity['text'] as String, style: const TextStyle(fontSize: 13)),
                  Text(
                    activity['time'] as String,
                    style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
      )).toList(),
    );
  }

  Widget _buildChildrenTab() {
    return Scaffold(
      appBar: AppBar(
        title: Text('my_children'.tr),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: controller.linkNewChild,
          ),
        ],
      ),
      body: Obx(() => ListView.builder(
        padding: const EdgeInsets.all(AppConstants.paddingM),
        itemCount: controller.children.length,
        itemBuilder: (context, index) {
          final child = controller.children[index];
          return _ChildDetailCard(
            child: child,
            onTap: () => controller.viewChildProgress(child.id),
            onSetLimit: () => _showLimitDialog(child.id),
          );
        },
      )),
    );
  }

  void _showLimitDialog(String childId) {
    final limits = [30, 60, 90, 120, 180];
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'set_daily_study_time'.tr,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: limits.map((limit) => ChoiceChip(
                label: Text('$limit ${'minute'.tr}'),
                selected: false,
                onSelected: (_) {
                  controller.setStudyLimit(childId, limit);
                  Get.back();
                },
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportsTab() {
    return Scaffold(
      appBar: AppBar(
        title: Text('reports'.tr),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Weekly summary
            _buildReportCard(
              title: 'weekly_summary'.tr,
              icon: Icons.date_range,
              stats: [
                {'label': 'study_hours'.tr, 'value': '12'},
                {'label': 'completed_lessons'.tr, 'value': '8'},
                {'label': 'quizzes'.tr, 'value': '3'},
              ],
            ),
            const SizedBox(height: 16),

            // Progress chart placeholder
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.bar_chart, size: 48, color: AppColors.textSecondary),
                    const SizedBox(height: 8),
                    Text('progress_chart'.tr, style: TextStyle(color: AppColors.textSecondary)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Subjects breakdown
            Text('subject_performance'.tr, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildSubjectProgress('subject_math'.tr, 0.85),
            _buildSubjectProgress('subject_physics'.tr, 0.72),
            _buildSubjectProgress('subject_chemistry'.tr, 0.68),
            _buildSubjectProgress('subject_arabic'.tr, 0.91),
          ],
        ),
      ),
    );
  }

  Widget _buildReportCard({
    required String title,
    required IconData icon,
    required List<Map<String, String>> stats,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: stats.map((stat) => Column(
              children: [
                Text(
                  stat['value']!,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
                Text(stat['label']!, style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ],
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectProgress(String subject, double progress) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(subject),
              Text('${(progress * 100).toInt()}%', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            color: AppColors.primary,
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTab() {
    return Scaffold(
      appBar: AppBar(
        title: Text('settings'.tr),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.person),
            title: Text('profile'.tr),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Get.toNamed(Routes.profile),
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: Text('notifications'.tr),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Get.toNamed(Routes.notifications),
          ),
          ListTile(
            leading: const Icon(Icons.lock),
            title: Text('privacy_security'.tr),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.help),
            title: Text('help'.tr),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Get.toNamed(Routes.help),
          ),
          const Divider(),
          ListTile(
            leading: Icon(Icons.logout, color: AppColors.error),
            title: Text('logout'.tr, style: TextStyle(color: AppColors.error)),
            onTap: controller.logout,
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ChildDetailCard extends StatelessWidget {
  final dynamic child;
  final VoidCallback onTap;
  final VoidCallback onSetLimit;

  const _ChildDetailCard({
    required this.child,
    required this.onTap,
    required this.onSetLimit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  child: Text(
                    child.fullName[0],
                    style: TextStyle(fontSize: 24, color: AppColors.primary, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(child.fullName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text('${'level'.tr} ${child.level}', style: TextStyle(color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _MiniStat(icon: Icons.school, value: '${child.stats.completedCourses}', label: 'courses'.tr),
                _MiniStat(icon: Icons.access_time, value: '${(child.stats.totalStudyMinutes / 60).toInt()}${'h'.tr}', label: 'study'.tr),
                _MiniStat(icon: Icons.local_fire_department, value: '${child.streak}', label: 'streak'.tr),
                _MiniStat(icon: Icons.emoji_events, value: '${child.points}', label: 'points'.tr),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onSetLimit,
                    icon: const Icon(Icons.timer),
                    label: Text('set_time'.tr),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onTap,
                    icon: const Icon(Icons.visibility),
                    label: Text('details'.tr),
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

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _MiniStat({required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
      ],
    );
  }
}

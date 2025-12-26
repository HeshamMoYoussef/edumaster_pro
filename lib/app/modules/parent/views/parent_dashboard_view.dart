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
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'الرئيسية',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: 'الأبناء',
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics_outlined),
            selectedIcon: Icon(Icons.analytics),
            label: 'التقارير',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'الإعدادات',
          ),
        ],
      )),
    );
  }

  Widget _buildHomeTab() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة ولي الأمر'),
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
                'مرحباً، ${controller.parentName}',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'تابع تقدم أبنائك في التعلم',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),

              // Quick stats
              _buildQuickStats(),
              const SizedBox(height: 24),

              // Children overview
              _buildSectionTitle('الأبناء', onSeeAll: () => controller.currentIndex = 1),
              const SizedBox(height: 12),
              _buildChildrenList(),
              const SizedBox(height: 24),

              // Recent activity
              _buildSectionTitle('النشاط الأخير'),
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
            label: 'الأبناء',
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.school,
            value: '${controller.children.fold<int>(0, (sum, c) => sum + c.stats.completedCourses)}',
            label: 'كورسات مكتملة',
            color: AppColors.success,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.access_time,
            value: '${(controller.children.fold<int>(0, (sum, c) => sum + c.stats.totalStudyMinutes) / 60).toInt()}س',
            label: 'وقت الدراسة',
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
            child: const Text('عرض الكل'),
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
                        'المستوى ${child.level} • ${child.streak} يوم تتابع',
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
                    Text('نقطة', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
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
      {'icon': Icons.check_circle, 'text': 'أحمد أكمل درس "المعادلات الخطية"', 'time': 'منذ ساعة', 'color': AppColors.success},
      {'icon': Icons.video_call, 'text': 'سارة حضرت جلسة مع أ. محمد', 'time': 'منذ 3 ساعات', 'color': AppColors.info},
      {'icon': Icons.star, 'text': 'أحمد حصل على شارة "المثابر"', 'time': 'منذ يوم', 'color': Colors.amber},
      {'icon': Icons.quiz, 'text': 'سارة أكملت اختبار الفيزياء (85%)', 'time': 'منذ يومين', 'color': AppColors.primary},
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
        title: const Text('الأبناء'),
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
            const Text(
              'تحديد وقت الدراسة اليومي',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: limits.map((limit) => ChoiceChip(
                label: Text('$limit دقيقة'),
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
        title: const Text('التقارير'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Weekly summary
            _buildReportCard(
              title: 'ملخص الأسبوع',
              icon: Icons.date_range,
              stats: [
                {'label': 'ساعات الدراسة', 'value': '12'},
                {'label': 'الدروس المكتملة', 'value': '8'},
                {'label': 'الاختبارات', 'value': '3'},
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
                    Text('رسم بياني للتقدم', style: TextStyle(color: AppColors.textSecondary)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Subjects breakdown
            const Text('أداء المواد', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildSubjectProgress('الرياضيات', 0.85),
            _buildSubjectProgress('الفيزياء', 0.72),
            _buildSubjectProgress('الكيمياء', 0.68),
            _buildSubjectProgress('اللغة العربية', 0.91),
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
        title: const Text('الإعدادات'),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('الملف الشخصي'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Get.toNamed(Routes.profile),
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('الإشعارات'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Get.toNamed(Routes.notifications),
          ),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text('الخصوصية والأمان'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('المساعدة'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Get.toNamed(Routes.help),
          ),
          const Divider(),
          ListTile(
            leading: Icon(Icons.logout, color: AppColors.error),
            title: Text('تسجيل الخروج', style: TextStyle(color: AppColors.error)),
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
                      Text('المستوى ${child.level}', style: TextStyle(color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _MiniStat(icon: Icons.school, value: '${child.stats.completedCourses}', label: 'كورسات'),
                _MiniStat(icon: Icons.access_time, value: '${(child.stats.totalStudyMinutes / 60).toInt()}س', label: 'دراسة'),
                _MiniStat(icon: Icons.local_fire_department, value: '${child.streak}', label: 'تتابع'),
                _MiniStat(icon: Icons.emoji_events, value: '${child.points}', label: 'نقاط'),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onSetLimit,
                    icon: const Icon(Icons.timer),
                    label: const Text('تحديد الوقت'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onTap,
                    icon: const Icon(Icons.visibility),
                    label: const Text('التفاصيل'),
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

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/color_constants.dart';
import '../../../routes/app_routes.dart';
import '../../../modules/auth/controllers/auth_controller.dart';
import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('حسابي'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Get.toNamed(Routes.settings),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.paddingM),
        children: [
          // Profile header
          _buildProfileHeader(),
          const SizedBox(height: AppConstants.paddingXL),

          // Stats
          _buildStatsRow(),
          const SizedBox(height: AppConstants.paddingXL),

          // Menu items
          _buildMenuItem(Icons.school, 'كورساتي', () => Get.toNamed(Routes.courses)),
          _buildMenuItem(Icons.emoji_events, 'إنجازاتي', () => Get.toNamed(Routes.achievements)),
          _buildMenuItem(Icons.account_balance_wallet, 'محفظتي', () => Get.toNamed(Routes.wallet)),
          _buildMenuItem(Icons.favorite, 'المفضلة', () => Get.toNamed(Routes.favorites)),
          _buildMenuItem(Icons.help, 'المساعدة', () => Get.toNamed(Routes.help)),

          const SizedBox(height: AppConstants.paddingXL),

          // Logout
          _buildLogoutButton(),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    final user = controller.user;
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
          child: Text(
            user?.fullName.substring(0, 1) ?? 'م',
            style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: AppColors.primary),
          ),
        ),
        const SizedBox(height: 16),
        Text(user?.fullName ?? 'متعلم', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        Text(user?.email ?? '', style: TextStyle(color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text('المستوى ${user?.level ?? 1}', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    final user = controller.user;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _StatItem(value: '${user?.points ?? 0}', label: 'نقطة'),
        _StatItem(value: '${user?.eduCoins ?? 0}', label: 'عملة'),
        _StatItem(value: '${user?.currentStreak ?? 0}', label: 'يوم متتالي'),
      ],
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildLogoutButton() {
    return ListTile(
      leading: Icon(Icons.logout, color: AppColors.error),
      title: Text('تسجيل الخروج', style: TextStyle(color: AppColors.error)),
      onTap: () {
        Get.find<AuthController>().logout();
      },
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;

  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(color: AppColors.textSecondary)),
      ],
    );
  }
}

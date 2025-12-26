import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/color_constants.dart';
import '../controllers/achievements_controller.dart';

class LeaderboardView extends GetView<AchievementsController> {
  const LeaderboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('لوحة المتصدرين'), centerTitle: true),
      body: Obx(() => ListView.builder(
        padding: const EdgeInsets.all(AppConstants.paddingM),
        itemCount: controller.leaderboard.length,
        itemBuilder: (context, index) {
          final entry = controller.leaderboard[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: index < 3 ? [Colors.amber, Colors.grey, Colors.brown][index] : AppColors.primary.withValues(alpha: 0.1),
              child: Text('${entry.rank}', style: TextStyle(color: index < 3 ? Colors.white : AppColors.primary, fontWeight: FontWeight.bold)),
            ),
            title: Text(entry.userName),
            subtitle: Text('المستوى ${entry.level}'),
            trailing: Text('${entry.points} نقطة', style: const TextStyle(fontWeight: FontWeight.bold)),
          );
        },
      )),
    );
  }
}

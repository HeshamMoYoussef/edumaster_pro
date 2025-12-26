import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/color_constants.dart';
import '../../../global/widgets/loading_widget.dart';
import '../controllers/achievements_controller.dart';

class AchievementsView extends GetView<AchievementsController> {
  const AchievementsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الإنجازات'), centerTitle: true),
      body: Obx(() {
        if (controller.isLoading) return const LoadingWidget();

        return GridView.builder(
          padding: const EdgeInsets.all(AppConstants.paddingM),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 16, mainAxisSpacing: 16),
          itemCount: controller.achievements.length,
          itemBuilder: (context, index) {
            final achievement = controller.achievements[index];
            return Container(
              decoration: BoxDecoration(
                color: achievement.isUnlocked ? AppColors.primary.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: achievement.isUnlocked ? AppColors.primary : Colors.grey.withValues(alpha: 0.3)),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(achievement.icon, style: TextStyle(fontSize: 40, color: achievement.isUnlocked ? null : Colors.grey)),
                  const SizedBox(height: 8),
                  Text(achievement.title ?? achievement.name, style: TextStyle(fontWeight: FontWeight.bold, color: achievement.isUnlocked ? null : Colors.grey), textAlign: TextAlign.center),
                  if (!achievement.isUnlocked && achievement.maxProgress != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: LinearProgressIndicator(value: achievement.progress / achievement.maxProgress!, backgroundColor: Colors.grey.shade300),
                    ),
                ],
              ),
            );
          },
        );
      }),
    );
  }
}

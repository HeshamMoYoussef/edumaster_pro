import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/color_constants.dart';
import '../../../../data/models/achievement_model.dart';

/// Streak card widget
class StreakCard extends StatelessWidget {
  final StreakModel streak;
  final VoidCallback onCheckIn;

  const StreakCard({
    super.key,
    required this.streak,
    required this.onCheckIn,
  });

  @override
  Widget build(BuildContext context) {
    final canCheckIn = !_hasCheckedInToday();

    return Container(
      margin: const EdgeInsets.only(top: AppConstants.paddingM),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.warning,
            AppColors.warning.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
      ),
      padding: const EdgeInsets.all(AppConstants.paddingM),
      child: Row(
        children: [
          // Fire icon
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                '🔥',
                style: TextStyle(fontSize: 28),
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Streak info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '${streak.currentStreak}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'consecutive_days'.tr,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${'longest_streak'.tr}: ${streak.longestStreak} ${'day'.tr}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Check-in button
          if (canCheckIn)
            ElevatedButton(
              onPressed: onCheckIn,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.warning,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
              ),
              child: Text(
                'check_in'.tr,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'done'.tr,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  bool _hasCheckedInToday() {
    if (streak.lastCheckIn == null) return false;
    final now = DateTime.now();
    final lastCheckIn = streak.lastCheckIn!;
    return now.year == lastCheckIn.year &&
        now.month == lastCheckIn.month &&
        now.day == lastCheckIn.day;
  }
}

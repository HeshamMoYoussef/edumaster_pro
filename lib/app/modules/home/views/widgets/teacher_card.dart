import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/color_constants.dart';
import '../../../../data/models/teacher_model.dart';

/// Teacher card widget
class TeacherCard extends StatelessWidget {
  final TeacherModel teacher;
  final VoidCallback onTap;

  const TeacherCard({
    super.key,
    required this.teacher,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(AppConstants.paddingS),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Avatar
            Stack(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  child: teacher.avatar != null
                      ? ClipOval(
                          child: Image.network(
                            teacher.avatar!,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => _buildAvatarPlaceholder(),
                          ),
                        )
                      : _buildAvatarPlaceholder(),
                ),

                // Verified badge
                if (teacher.isVerified)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.verified,
                        size: 18,
                        color: AppColors.info,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 8),

            // Name
            Text(
              teacher.fullName,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                height: 1.2,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 2),

            // Subjects
            Text(
              teacher.subjects.take(2).join(' • '),
              style: TextStyle(
                fontSize: 10,
                color: AppColors.textSecondary,
                height: 1.2,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 4),

            // Rating
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.star,
                  size: 14,
                  color: AppColors.warning,
                ),
                const SizedBox(width: 2),
                Text(
                  teacher.formattedRating,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  ' (${teacher.totalReviews})',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 4),

            // Price
            Text(
              '${teacher.hourlyRate.toInt()} ${'sar_per_hour'.tr}',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarPlaceholder() {
    return Text(
      teacher.fullName.substring(0, 1).toUpperCase(),
      style: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
      ),
    );
  }
}

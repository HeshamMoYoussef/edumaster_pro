import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/color_constants.dart';
import '../../../../data/models/session_model.dart';

/// Session card widget
class SessionCard extends StatelessWidget {
  final SessionModel session;
  final VoidCallback onTap;

  const SessionCard({
    super.key,
    required this.session,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 280,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _getStatusColor().withValues(alpha: 0.1),
              _getStatusColor().withValues(alpha: 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
          border: Border.all(
            color: _getStatusColor().withValues(alpha: 0.3),
          ),
        ),
        padding: const EdgeInsets.all(AppConstants.paddingM),
        child: Row(
          children: [
            // Date box
            _buildDateBox(),

            const SizedBox(width: 12),

            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Subject
                  Text(
                    session.subject ?? 'session'.tr,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 4),

                  // Teacher name
                  if (session.teacher != null)
                    Text(
                      '${'with'.tr} ${session.teacher!.fullName}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                  const SizedBox(height: 8),

                  // Time and type
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('hh:mm a', 'ar').format(session.scheduledAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      _buildTypeTag(),
                    ],
                  ),
                ],
              ),
            ),

            // Join button (if can join)
            if (session.canJoin)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.success,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'join'.tr,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateBox() {
    return Container(
      width: 50,
      height: 60,
      decoration: BoxDecoration(
        color: _getStatusColor(),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            DateFormat('d').format(session.scheduledAt),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            DateFormat('MMM', 'ar').format(session.scheduledAt),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeTag() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: _getTypeColor().withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        session.type.label,
        style: TextStyle(
          fontSize: 10,
          color: _getTypeColor(),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _getStatusColor() {
    switch (session.status) {
      case SessionStatus.scheduled:
        return AppColors.info;
      case SessionStatus.inProgress:
        return AppColors.success;
      case SessionStatus.completed:
        return AppColors.textSecondary;
      case SessionStatus.cancelled:
        return AppColors.error;
      case SessionStatus.pending:
        return AppColors.warning;
      case SessionStatus.rescheduled:
        return AppColors.info;
      case SessionStatus.confirmed:
        return AppColors.success;
      case SessionStatus.noShow:
        return AppColors.error;
    }
  }

  Color _getTypeColor() {
    switch (session.type) {
      case SessionType.oneOnOne:
        return AppColors.primary;
      case SessionType.group:
        return AppColors.secondary;
      case SessionType.instant:
        return AppColors.success;
      case SessionType.trial:
        return AppColors.warning;
      case SessionType.workshop:
        return AppColors.info;
      case SessionType.mentorship:
        return AppColors.secondary;
      case SessionType.instantHelp:
        return AppColors.success;
    }
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/color_constants.dart';
import '../../../data/models/teacher_model.dart';
import '../../../global/widgets/custom_button.dart';
import '../controllers/book_session_controller.dart';

/// Book Session View
class BookSessionView extends GetView<BookSessionController> {
  const BookSessionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('book_session'.tr),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.paddingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Teacher card
              _buildTeacherCard(),
              const SizedBox(height: 24),

              // Session type
              _buildSectionTitle('session_type'.tr),
              const SizedBox(height: 12),
              _buildSessionTypeSelector(),
              const SizedBox(height: 24),

              // Subject
              _buildSectionTitle('subjects'.tr),
              const SizedBox(height: 12),
              _buildSubjectSelector(),
              const SizedBox(height: 24),

              // Date selection
              _buildSectionTitle('select_date'.tr),
              const SizedBox(height: 12),
              _buildDateSelector(),
              const SizedBox(height: 24),

              // Time slots
              _buildSectionTitle('select_time'.tr),
              const SizedBox(height: 12),
              _buildTimeSlots(),
              const SizedBox(height: 24),

              // Duration
              _buildSectionTitle('duration'.tr),
              const SizedBox(height: 12),
              _buildDurationSelector(),
              const SizedBox(height: 24),

              // Notes
              _buildSectionTitle('notes_optional'.tr),
              const SizedBox(height: 12),
              TextField(
                controller: controller.notesController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'add_notes_hint'.tr,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Price summary
              _buildPriceSummary(),
              const SizedBox(height: 24),

              // Book button
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  text: 'confirm_booking'.tr,
                  onPressed: controller.bookSession,
                  isLoading: controller.isBooking,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildTeacherCard() {
    final teacher = controller.teacher;
    if (teacher == null) return const SizedBox.shrink();

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
            radius: 30,
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            child: Text(
              teacher.fullName[0],
              style: TextStyle(
                fontSize: 24,
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      teacher.fullName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (teacher.isVerified) ...[
                      const SizedBox(width: 4),
                      Icon(Icons.verified, color: AppColors.info, size: 18),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  teacher.subjects.join(' • '),
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.star, size: 16, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(teacher.formattedRating),
                    const SizedBox(width: 8),
                    Text(
                      '(${teacher.totalReviews} ${'reviews'.tr})',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildSessionTypeSelector() {
    return Obx(() => Wrap(
      spacing: 12,
      children: [
        _SelectableChip(
          label: 'one_on_one'.tr,
          icon: Icons.person,
          isSelected: controller.sessionType.value == 'one_on_one',
          onTap: () => controller.sessionType.value = 'one_on_one',
        ),
        _SelectableChip(
          label: 'group_session'.tr,
          icon: Icons.group,
          isSelected: controller.sessionType.value == 'group',
          onTap: () => controller.sessionType.value = 'group',
        ),
      ],
    ));
  }

  Widget _buildSubjectSelector() {
    final subjects = controller.teacher?.subjects ?? ['subject_default_1'.tr, 'subject_default_2'.tr, 'subject_default_3'.tr];
    return Obx(() => Wrap(
      spacing: 8,
      runSpacing: 8,
      children: subjects.map((subject) => _SelectableChip(
        label: subject,
        isSelected: controller.selectedSubject.value == subject,
        onTap: () => controller.selectedSubject.value = subject,
      )).toList(),
    ));
  }

  Widget _buildDateSelector() {
    return SizedBox(
      height: 80,
      child: Obx(() {
        // تخزين قيمة selectedDate لتفعيل Obx
        final selectedDateValue = controller.selectedDate.value;

        return ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: 14, // Next 2 weeks
          itemBuilder: (context, index) {
            final date = DateTime.now().add(Duration(days: index));
            final isSelected = selectedDateValue?.day == date.day &&
                              selectedDateValue?.month == date.month;

            return GestureDetector(
              onTap: () => controller.selectDate(date),
              child: Container(
                width: 60,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.border,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _getDayName(date.weekday),
                      style: TextStyle(
                        fontSize: 12,
                        color: isSelected ? Colors.white70 : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${date.day}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      _getMonthName(date.month),
                      style: TextStyle(
                        fontSize: 10,
                        color: isSelected ? Colors.white70 : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildTimeSlots() {
    return Obx(() {
      if (controller.availableSlots.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              controller.selectedDate.value == null
                  ? 'select_date_first'.tr
                  : 'no_available_slots'.tr,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
        );
      }

      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: controller.availableSlots.map((slot) {
          final isSelected = controller.selectedTime.value == slot;
          return GestureDetector(
            onTap: () => controller.selectedTime.value = slot,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                ),
              ),
              child: Text(
                slot,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        }).toList(),
      );
    });
  }

  Widget _buildDurationSelector() {
    return Obx(() => Row(
      children: [
        Expanded(
          child: _DurationOption(
            duration: 30,
            isSelected: controller.duration.value == 30,
            onTap: () => controller.duration.value = 30,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _DurationOption(
            duration: 60,
            isSelected: controller.duration.value == 60,
            onTap: () => controller.duration.value = 60,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _DurationOption(
            duration: 90,
            isSelected: controller.duration.value == 90,
            onTap: () => controller.duration.value = 90,
          ),
        ),
      ],
    ));
  }

  Widget _buildPriceSummary() {
    return Obx(() => Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('price_per_hour'.tr, style: TextStyle(color: AppColors.textSecondary)),
              Text('${controller.hourlyRate.toInt()} ${'sar'.tr}'),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('duration'.tr, style: TextStyle(color: AppColors.textSecondary)),
              Text('${controller.duration.value} ${'minute'.tr}'),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('total_price'.tr, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text(
                '${controller.totalPrice.toInt()} ${'sar'.tr}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    ));
  }

  String _getDayName(int weekday) {
    final days = ['mon'.tr, 'tue'.tr, 'wed'.tr, 'thu'.tr, 'fri'.tr, 'sat'.tr, 'sun'.tr];
    return days[weekday - 1];
  }

  String _getMonthName(int month) {
    final months = [
      'jan'.tr, 'feb'.tr, 'mar'.tr, 'apr'.tr, 'may_short'.tr, 'jun'.tr,
      'jul'.tr, 'aug'.tr, 'sep'.tr, 'oct'.tr, 'nov'.tr, 'dec'.tr
    ];
    return months[month - 1];
  }
}

class _SelectableChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _SelectableChip({
    required this.label,
    this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 18,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DurationOption extends StatelessWidget {
  final int duration;
  final bool isSelected;
  final VoidCallback onTap;

  const _DurationOption({
    required this.duration,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Column(
          children: [
            Text(
              '$duration',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
            ),
            Text(
              'minute'.tr,
              style: TextStyle(
                color: isSelected ? Colors.white70 : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

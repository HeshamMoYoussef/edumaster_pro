import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/color_constants.dart';
import '../../../routes/app_routes.dart';
import '../../../global/widgets/loading_widget.dart';
import '../../../global/widgets/empty_state_widget.dart';
import '../../home/views/widgets/course_card.dart';
import '../controllers/courses_controller.dart';

/// Courses list view
class CoursesView extends GetView<CoursesController> {
  const CoursesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('courses'.tr),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilters(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(AppConstants.paddingM),
            child: TextField(
              onChanged: controller.search,
              decoration: InputDecoration(
                hintText: 'search'.tr,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusL),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Theme.of(context).cardColor,
              ),
            ),
          ),

          // Category chips
          Obx(() => _buildCategoryChips()),

          // Courses list
          Expanded(
            child: Obx(() {
              if (controller.isLoading) {
                return const LoadingWidget();
              }

              if (controller.courses.isEmpty) {
                return EmptyStateWidget(
                  icon: Icons.school_outlined,
                  title: 'no_courses'.tr,
                  description: 'no_results'.tr,
                );
              }

              return GridView.builder(
                padding: const EdgeInsets.all(AppConstants.paddingM),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: AppConstants.paddingM,
                  mainAxisSpacing: AppConstants.paddingM,
                ),
                itemCount: controller.courses.length,
                itemBuilder: (context, index) {
                  final course = controller.courses[index];
                  return CourseCard(
                    course: course,
                    onTap: () => Get.toNamed(Routes.courseDetailsPath(course.id)),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingM),
      child: Row(
        children: [
          _CategoryChip(
            label: 'all'.tr,
            isSelected: controller.selectedCategoryId == null,
            onTap: () => controller.setCategory(null),
          ),
          ...controller.categories.map(
            (category) => _CategoryChip(
              label: category.name,
              isSelected: controller.selectedCategoryId == category.id,
              onTap: () => controller.setCategory(category.id),
            ),
          ),
        ],
      ),
    );
  }

  void _showFilters(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (context) => _FiltersSheet(controller: controller),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        selectedColor: AppColors.primary.withValues(alpha: 0.2),
        checkmarkColor: AppColors.primary,
        labelStyle: TextStyle(
          color: isSelected ? AppColors.primary : null,
          fontWeight: isSelected ? FontWeight.bold : null,
        ),
      ),
    );
  }
}

class _FiltersSheet extends StatelessWidget {
  final CoursesController controller;

  const _FiltersSheet({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.paddingXL),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'filter'.tr,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppConstants.paddingL),

          // Level filter
          Text(
            'level'.tr,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppConstants.paddingS),
          Obx(() => Wrap(
                spacing: 8,
                children: [
                  _FilterChip(
                    label: 'all'.tr,
                    isSelected: controller.selectedLevel == null,
                    onTap: () => controller.setLevel(null),
                  ),
                  _FilterChip(
                    label: 'beginner'.tr,
                    isSelected: controller.selectedLevel == 'beginner',
                    onTap: () => controller.setLevel('beginner'),
                  ),
                  _FilterChip(
                    label: 'intermediate'.tr,
                    isSelected: controller.selectedLevel == 'intermediate',
                    onTap: () => controller.setLevel('intermediate'),
                  ),
                  _FilterChip(
                    label: 'advanced'.tr,
                    isSelected: controller.selectedLevel == 'advanced',
                    onTap: () => controller.setLevel('advanced'),
                  ),
                ],
              )),

          const SizedBox(height: AppConstants.paddingXL),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : null,
      ),
    );
  }
}

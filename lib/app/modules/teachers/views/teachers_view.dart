import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_constants.dart';
import '../../../routes/app_routes.dart';
import '../../../global/widgets/loading_widget.dart';
import '../../../global/widgets/empty_state_widget.dart';
import '../../home/views/widgets/teacher_card.dart';
import '../controllers/teachers_controller.dart';

/// Teachers list view
class TeachersView extends GetView<TeachersController> {
  const TeachersView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('teachers'.tr),
        centerTitle: true,
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

          // Teachers list
          Expanded(
            child: Obx(() {
              if (controller.isLoading) {
                return const LoadingWidget();
              }

              if (controller.teachers.isEmpty) {
                return EmptyStateWidget(
                  icon: Icons.people_outline,
                  title: 'no_teachers'.tr,
                  description: 'no_results'.tr,
                );
              }

              return GridView.builder(
                padding: const EdgeInsets.all(AppConstants.paddingM),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.85,
                  crossAxisSpacing: AppConstants.paddingM,
                  mainAxisSpacing: AppConstants.paddingM,
                ),
                itemCount: controller.teachers.length,
                itemBuilder: (context, index) {
                  final teacher = controller.teachers[index];
                  return TeacherCard(
                    teacher: teacher,
                    onTap: () => Get.toNamed(Routes.teacherProfilePath(teacher.id)),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}

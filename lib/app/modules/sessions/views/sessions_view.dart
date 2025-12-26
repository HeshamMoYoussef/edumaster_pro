import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_constants.dart';
import '../../../routes/app_routes.dart';
import '../../../global/widgets/loading_widget.dart';
import '../../../global/widgets/empty_state_widget.dart';
import '../../home/views/widgets/session_card.dart';
import '../controllers/sessions_controller.dart';

class SessionsView extends GetView<SessionsController> {
  const SessionsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('جلساتي'),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading) {
          return const LoadingWidget();
        }

        if (controller.sessions.isEmpty) {
          return const EmptyStateWidget(
            icon: Icons.calendar_today_outlined,
            title: 'لا توجد جلسات',
            description: 'احجز جلسة مع أحد المعلمين للبدء',
            buttonText: 'تصفح المعلمين',
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(AppConstants.paddingM),
          itemCount: controller.sessions.length,
          separatorBuilder: (context, index) => const SizedBox(height: AppConstants.paddingM),
          itemBuilder: (context, index) {
            return SessionCard(
              session: controller.sessions[index],
              onTap: () => Get.toNamed(
                Routes.sessionDetailsPath(controller.sessions[index].id),
              ),
            );
          },
        );
      }),
    );
  }
}

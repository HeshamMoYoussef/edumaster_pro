import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_constants.dart';
import '../../../global/widgets/loading_widget.dart';
import '../controllers/sessions_controller.dart';

class SessionDetailsView extends GetView<SessionsController> {
  const SessionDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final sessionId = Get.parameters['id'];

    // Use addPostFrameCallback to avoid setState during build
    if (sessionId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (controller.selectedSession?.id != sessionId) {
          controller.loadSessionDetails(sessionId);
        }
      });
    }

    return Scaffold(
      appBar: AppBar(title: const Text('تفاصيل الجلسة')),
      body: Obx(() {
        if (controller.isLoading || controller.selectedSession == null) {
          return const LoadingWidget();
        }
        final session = controller.selectedSession!;
        return Padding(
          padding: const EdgeInsets.all(AppConstants.paddingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(session.subject ?? 'جلسة', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              if (session.teacher != null) Text('المعلم: ${session.teacher!.fullName}'),
              const SizedBox(height: 8),
              Text('المدة: ${session.durationMinutes} دقيقة'),
              const SizedBox(height: 8),
              Text('الحالة: ${session.status.label}'),
              const SizedBox(height: 8),
              Text('السعر: ${session.price} ر.س'),
            ],
          ),
        );
      }),
    );
  }
}

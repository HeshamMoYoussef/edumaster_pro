import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/color_constants.dart';
import '../controllers/ai_tutor_controller.dart';

class AiTutorView extends GetView<AiTutorController> {
  const AiTutorView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('المساعد الذكي'), centerTitle: true),
      body: Column(
        children: [
          Expanded(
            child: Obx(() => ListView.builder(
              padding: const EdgeInsets.all(AppConstants.paddingM),
              itemCount: controller.messages.length,
              itemBuilder: (context, index) {
                final message = controller.messages[index];
                final isUser = message['role'] == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                    decoration: BoxDecoration(
                      color: isUser ? AppColors.primary : Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(message['content'], style: TextStyle(color: isUser ? Colors.white : null)),
                  ),
                );
              },
            )),
          ),
          Container(
            padding: const EdgeInsets.all(AppConstants.paddingM),
            decoration: BoxDecoration(color: Theme.of(context).cardColor),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller.textController,
                      decoration: const InputDecoration(hintText: 'اكتب سؤالك...', border: InputBorder.none),
                      onSubmitted: (_) => controller.sendMessage(),
                    ),
                  ),
                  Obx(() => IconButton(
                    icon: controller.isLoading
                        ? SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                        : Icon(Icons.send, color: AppColors.primary),
                    onPressed: controller.isLoading ? null : controller.sendMessage,
                  )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

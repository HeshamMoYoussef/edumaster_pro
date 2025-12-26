import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AiTutorController extends GetxController {
  final textController = TextEditingController();
  final _messages = <Map<String, dynamic>>[].obs;
  List<Map<String, dynamic>> get messages => _messages;

  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  void sendMessage() async {
    if (textController.text.trim().isEmpty) return;
    final userMessage = textController.text;
    textController.clear();

    _messages.add({'role': 'user', 'content': userMessage});
    _isLoading.value = true;

    // Simulate AI response
    await Future.delayed(const Duration(seconds: 1));
    _messages.add({'role': 'assistant', 'content': 'هذا رد تجريبي من المساعد الذكي. سيتم ربط API الذكاء الاصطناعي لاحقاً.'});
    _isLoading.value = false;
  }

  @override
  void onClose() {
    textController.dispose();
    super.onClose();
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_constants.dart';
import '../../../global/widgets/custom_button.dart';
import '../controllers/profile_controller.dart';

class EditProfileView extends GetView<ProfileController> {
  const EditProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تعديل الملف الشخصي')),
      body: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingM),
        child: Column(
          children: [
            const TextField(decoration: InputDecoration(labelText: 'الاسم الكامل')),
            const SizedBox(height: 16),
            const TextField(decoration: InputDecoration(labelText: 'رقم الهاتف')),
            const SizedBox(height: 24),
            CustomButton(text: 'حفظ التغييرات', onPressed: () => Get.back()),
          ],
        ),
      ),
    );
  }
}

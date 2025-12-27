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
      appBar: AppBar(title: Text('edit_profile'.tr)),
      body: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingM),
        child: Column(
          children: [
            TextField(decoration: InputDecoration(labelText: 'full_name'.tr)),
            const SizedBox(height: 16),
            TextField(decoration: InputDecoration(labelText: 'phone'.tr)),
            const SizedBox(height: 24),
            CustomButton(text: 'save_changes'.tr, onPressed: () => Get.back()),
          ],
        ),
      ),
    );
  }
}

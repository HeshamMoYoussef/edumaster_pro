import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reactive_forms/reactive_forms.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/color_constants.dart';
import '../../../global/widgets/custom_button.dart';
import '../../../global/widgets/custom_text_field.dart';
import '../controllers/auth_controller.dart';

/// Forgot password screen view
class ForgotPasswordView extends GetView<AuthController> {
  const ForgotPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('forgot_password'.tr),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.paddingXL),
          child: ReactiveForm(
            formGroup: controller.forgotPasswordForm,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppConstants.paddingXL),

                // Icon
                _buildIcon(),

                const SizedBox(height: AppConstants.paddingXL),

                // Title and description
                _buildHeader(),

                const SizedBox(height: AppConstants.paddingXXL),

                // Email field
                _buildEmailField(),

                const SizedBox(height: AppConstants.paddingXXL),

                // Send button
                _buildSendButton(),

                const SizedBox(height: AppConstants.paddingXL),

                // Back to login link
                _buildBackToLoginLink(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Center(
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: AppColors.warning.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.lock_reset,
          size: 50,
          color: AppColors.warning,
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Text(
          'reset_password'.tr,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppConstants.paddingM),
        Text(
          'forgot_password_description'.tr,
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return CustomTextField(
      formControlName: 'email',
      label: 'email'.tr,
      hint: 'enter_email'.tr,
      prefixIcon: Icons.email_outlined,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.done,
      validationMessages: {
        'required': (error) => 'email_required'.tr,
        'email': (error) => 'invalid_email'.tr,
      },
    );
  }

  Widget _buildSendButton() {
    return Obx(() => CustomButton(
          text: 'send_verification_code'.tr,
          onPressed: controller.forgotPassword,
          isLoading: controller.isLoading,
        ));
  }

  Widget _buildBackToLoginLink() {
    return Center(
      child: TextButton.icon(
        onPressed: () => Get.back(),
        icon: const Icon(Icons.arrow_back),
        label: Text('back_to_login'.tr),
        style: TextButton.styleFrom(
          foregroundColor: AppColors.textSecondary,
        ),
      ),
    );
  }
}

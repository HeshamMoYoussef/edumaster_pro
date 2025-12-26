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
        title: const Text('نسيت كلمة المرور'),
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
        const Text(
          'إعادة تعيين كلمة المرور',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppConstants.paddingM),
        Text(
          'أدخل بريدك الإلكتروني وسنرسل لك رمز التحقق لإعادة تعيين كلمة المرور',
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
      label: 'البريد الإلكتروني',
      hint: 'أدخل بريدك الإلكتروني',
      prefixIcon: Icons.email_outlined,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.done,
      validationMessages: {
        'required': (error) => 'البريد الإلكتروني مطلوب',
        'email': (error) => 'البريد الإلكتروني غير صالح',
      },
    );
  }

  Widget _buildSendButton() {
    return Obx(() => CustomButton(
          text: 'إرسال رمز التحقق',
          onPressed: controller.forgotPassword,
          isLoading: controller.isLoading,
        ));
  }

  Widget _buildBackToLoginLink() {
    return Center(
      child: TextButton.icon(
        onPressed: () => Get.back(),
        icon: const Icon(Icons.arrow_back),
        label: const Text('العودة لتسجيل الدخول'),
        style: TextButton.styleFrom(
          foregroundColor: AppColors.textSecondary,
        ),
      ),
    );
  }
}

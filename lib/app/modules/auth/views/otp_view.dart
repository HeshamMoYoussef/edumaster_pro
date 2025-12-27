import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reactive_forms/reactive_forms.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/color_constants.dart';
import '../../../global/widgets/custom_button.dart';
import '../controllers/auth_controller.dart';

/// OTP verification screen view
class OtpView extends GetView<AuthController> {
  const OtpView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('verification'.tr),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.paddingXL),
          child: ReactiveForm(
            formGroup: controller.otpForm,
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

                // OTP input
                _buildOtpInput(),

                const SizedBox(height: AppConstants.paddingXXL),

                // Verify button
                _buildVerifyButton(),

                const SizedBox(height: AppConstants.paddingXL),

                // Resend code
                _buildResendCode(),
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
          color: AppColors.primary.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.mark_email_read,
          size: 50,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Text(
          'enter_otp'.tr,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppConstants.paddingM),
        Text(
          'verification_code_sent'.tr,
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppConstants.paddingS),
        Obx(() => Text(
              controller.otpIdentifier,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
              textAlign: TextAlign.center,
            )),
      ],
    );
  }

  Widget _buildOtpInput() {
    return ReactiveTextField<String>(
      formControlName: 'otp',
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        letterSpacing: 16,
      ),
      maxLength: 6,
      decoration: InputDecoration(
        hintText: '------',
        hintStyle: TextStyle(
          fontSize: 32,
          letterSpacing: 16,
          color: AppColors.textSecondary.withValues(alpha: 0.3),
        ),
        counterText: '',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
          borderSide: BorderSide(
            color: AppColors.primary,
            width: 2,
          ),
        ),
      ),
      validationMessages: {
        'required': (error) => 'otp_required'.tr,
        'minLength': (error) => 'otp_length'.tr,
      },
    );
  }

  Widget _buildVerifyButton() {
    return Obx(() => CustomButton(
          text: 'verify'.tr,
          onPressed: controller.verifyOtp,
          isLoading: controller.isLoading,
        ));
  }

  Widget _buildResendCode() {
    return Column(
      children: [
        Text(
          'didnt_receive_code'.tr,
          style: TextStyle(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppConstants.paddingS),
        Obx(() => TextButton(
              onPressed: controller.isLoading ? null : controller.resendOtp,
              child: Text(
                'resend_otp'.tr,
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )),
      ],
    );
  }
}

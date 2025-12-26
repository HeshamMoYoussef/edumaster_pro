import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:reactive_forms/reactive_forms.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/color_constants.dart';
import '../../../routes/app_routes.dart';
import '../../../global/widgets/custom_button.dart';
import '../../../global/widgets/custom_text_field.dart';
import '../controllers/auth_controller.dart';

/// Login screen view
class LoginView extends GetView<AuthController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.paddingXL),
          child: ReactiveForm(
            formGroup: controller.loginForm,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppConstants.paddingXL),

                // Logo and title
                _buildHeader(),

                const SizedBox(height: AppConstants.paddingXXL),

                // Email field
                _buildEmailField(),

                const SizedBox(height: AppConstants.paddingM),

                // Password field
                _buildPasswordField(),

                const SizedBox(height: AppConstants.paddingS),

                // Remember me & Forgot password
                _buildRememberForgot(),

                const SizedBox(height: AppConstants.paddingXL),

                // Login button
                _buildLoginButton(),

                const SizedBox(height: AppConstants.paddingL),

                // ========================================
                // أزرار الدخول السريع للاختبار
                // TODO: إزالتها في الإنتاج
                // ========================================
                _buildQuickLoginButtons(),

                const SizedBox(height: AppConstants.paddingXL),

                // Divider
                _buildDivider(),

                const SizedBox(height: AppConstants.paddingXL),

                // Social login buttons
                _buildSocialButtons(),

                const SizedBox(height: AppConstants.paddingXXL),

                // Register link
                _buildRegisterLink(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            Icons.school_rounded,
            size: 40,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: AppConstants.paddingL),
        const Text(
          'مرحباً بعودتك',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppConstants.paddingS),
        Text(
          'سجل دخولك للمتابعة',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textSecondary,
          ),
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
      textInputAction: TextInputAction.next,
      validationMessages: {
        'required': (error) => 'البريد الإلكتروني مطلوب',
        'email': (error) => 'البريد الإلكتروني غير صالح',
      },
    );
  }

  Widget _buildPasswordField() {
    return Obx(() => CustomTextField(
          formControlName: 'password',
          label: 'كلمة المرور',
          hint: 'أدخل كلمة المرور',
          prefixIcon: Icons.lock_outlined,
          obscureText: controller.obscurePassword,
          suffixIcon: IconButton(
            icon: Icon(
              controller.obscurePassword
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
            ),
            onPressed: controller.togglePasswordVisibility,
          ),
          textInputAction: TextInputAction.done,
          validationMessages: {
            'required': (error) => 'كلمة المرور مطلوبة',
            'minLength': (error) => 'كلمة المرور يجب أن تكون 8 أحرف على الأقل',
          },
        ));
  }

  Widget _buildRememberForgot() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Remember me
        Row(
          children: [
            ReactiveCheckbox(
              formControlName: 'remember_me',
              activeColor: AppColors.primary,
            ),
            const SizedBox(width: 8),
            Text(
              'تذكرني',
              style: TextStyle(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),

        // Forgot password
        TextButton(
          onPressed: () => Get.toNamed(Routes.forgotPassword),
          child: Text(
            'نسيت كلمة المرور؟',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return Obx(() => CustomButton(
          text: 'تسجيل الدخول',
          onPressed: controller.login,
          isLoading: controller.isLoading,
        ));
  }

  /// أزرار الدخول السريع للاختبار
  /// TODO: إزالة هذا القسم بالكامل في الإنتاج
  Widget _buildQuickLoginButtons() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingM),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        border: Border.all(
          color: Colors.amber.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          // عنوان القسم
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.developer_mode, color: Colors.amber[700], size: 18),
              const SizedBox(width: 8),
              Text(
                'دخول سريع للاختبار',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.paddingM),

          // الأزرار الثلاثة
          Row(
            children: [
              // زر الطالب
              Expanded(
                child: _QuickLoginButton(
                  label: 'طالب',
                  icon: Icons.school,
                  color: AppColors.primary,
                  onPressed: controller.quickLoginAsStudent,
                ),
              ),
              const SizedBox(width: 8),

              // زر ولي الأمر
              Expanded(
                child: _QuickLoginButton(
                  label: 'ولي أمر',
                  icon: Icons.family_restroom,
                  color: Colors.green,
                  onPressed: controller.quickLoginAsParent,
                ),
              ),
              const SizedBox(width: 8),

              // زر المعلم
              Expanded(
                child: _QuickLoginButton(
                  label: 'معلم',
                  icon: Icons.person_pin,
                  color: Colors.purple,
                  onPressed: controller.quickLoginAsTeacher,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: AppColors.textSecondary.withValues(alpha: 0.3),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingM),
          child: Text(
            'أو',
            style: TextStyle(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: AppColors.textSecondary.withValues(alpha: 0.3),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialButtons() {
    return Column(
      children: [
        // Google - مع أيقونة SVG
        SizedBox(
          width: double.infinity,
          height: AppConstants.buttonHeight,
          child: OutlinedButton(
            onPressed: () => controller.socialLogin('google'),
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.white,
              side: BorderSide(
                color: AppColors.textSecondary.withValues(alpha: 0.3),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusL),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // أيقونة Google SVG الرسمية
                SvgPicture.asset(
                  'assets/icons/google.svg',
                  width: 24,
                  height: 24,
                ),
                const SizedBox(width: 12),
                const Text(
                  'المتابعة مع Google',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppConstants.paddingM),

        // Apple - مع أيقونة SVG
        SizedBox(
          width: double.infinity,
          height: AppConstants.buttonHeight,
          child: ElevatedButton(
            onPressed: () => controller.socialLogin('apple'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusL),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // أيقونة Apple SVG الرسمية
                SvgPicture.asset(
                  'assets/icons/apple.svg',
                  width: 24,
                  height: 24,
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'المتابعة مع Apple',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'ليس لديك حساب؟',
          style: TextStyle(
            color: AppColors.textSecondary,
          ),
        ),
        TextButton(
          onPressed: () => Get.toNamed(Routes.register),
          child: Text(
            'سجل الآن',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

/// زر الدخول السريع للاختبار
/// TODO: إزالته في الإنتاج
class _QuickLoginButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const _QuickLoginButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(AppConstants.radiusM),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: AppConstants.paddingM,
            horizontal: AppConstants.paddingS,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

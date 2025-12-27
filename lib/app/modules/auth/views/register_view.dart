/// ============================================================================
/// صفحة إنشاء حساب جديد (Register View)
/// ============================================================================
///
/// هذه الصفحة تسمح للمستخدمين الجدد بإنشاء حساب في التطبيق.
///
/// الأدوار المتاحة:
/// - طالب (Student): يمكنه حضور الدروس وشراء الكورسات
/// - ولي أمر (Parent): يمكنه متابعة أبنائه ومراقبة تقدمهم
/// - معلم (Teacher): يمكنه إنشاء الدروس والكورسات وتقديم الجلسات الخاصة
///
/// TODO: للإنتاج:
/// - إضافة التحقق من البريد الإلكتروني عبر رابط
/// - إضافة التحقق من رقم الهاتف عبر OTP
/// - إضافة تسجيل الدخول عبر Google/Apple
/// - للمعلمين: إضافة خطوة تحقق من الهوية والشهادات
/// - إضافة captcha للحماية من الروبوتات
///
/// ============================================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reactive_forms/reactive_forms.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/color_constants.dart';
import '../../../core/widgets/smart_phone_field.dart';
import '../../../data/models/user_model.dart';
import '../../../global/widgets/custom_button.dart';
import '../../../global/widgets/custom_text_field.dart';
import '../controllers/auth_controller.dart';

/// صفحة التسجيل - تستخدم GetX للتحكم في الحالة
///
/// تستخدم ReactiveForm للتحقق من صحة البيانات
class RegisterView extends GetView<AuthController> {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('create_account'.tr),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.paddingXL),
          child: ReactiveForm(
            formGroup: controller.registerForm,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ========================================
                // اختيار نوع الحساب (طالب/ولي أمر/معلم)
                // ========================================
                _buildRoleSelection(),

                const SizedBox(height: AppConstants.paddingXL),

                // ========================================
                // حقل الاسم الكامل
                // ========================================
                _buildFullNameField(),

                const SizedBox(height: AppConstants.paddingM),

                // ========================================
                // حقل البريد الإلكتروني
                // ========================================
                _buildEmailField(),

                const SizedBox(height: AppConstants.paddingM),

                // ========================================
                // حقل رقم الهاتف
                // ========================================
                _buildPhoneField(),

                const SizedBox(height: AppConstants.paddingM),

                // ========================================
                // حقل كلمة المرور
                // ========================================
                _buildPasswordField(),

                const SizedBox(height: AppConstants.paddingM),

                // ========================================
                // حقل تأكيد كلمة المرور
                // ========================================
                _buildConfirmPasswordField(),

                const SizedBox(height: AppConstants.paddingL),

                // ========================================
                // حقول إضافية للمعلم
                // TODO: إضافة رفع الشهادات والوثائق
                // ========================================
                _buildTeacherFields(),

                // ========================================
                // الموافقة على الشروط والأحكام
                // ========================================
                _buildTermsCheckbox(),

                const SizedBox(height: AppConstants.paddingXL),

                // ========================================
                // زر إنشاء الحساب
                // ========================================
                _buildRegisterButton(),

                const SizedBox(height: AppConstants.paddingXL),

                // ========================================
                // رابط تسجيل الدخول
                // ========================================
                _buildLoginLink(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// بناء قسم اختيار نوع الحساب
  ///
  /// يعرض 3 خيارات: طالب، ولي أمر، معلم
  /// كل خيار له أيقونة ولون مميز
  Widget _buildRoleSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'i_am'.tr,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppConstants.paddingM),

        // ========================================
        // صف الخيارات الثلاثة
        // ========================================
        Obx(() => Row(
          children: [
            // خيار الطالب
            Expanded(
              child: _RoleCard(
                role: UserRole.student,
                icon: Icons.school,
                label: 'student'.tr,
                isSelected: controller.selectedRole == UserRole.student,
                onTap: () => controller.selectedRole = UserRole.student,
              ),
            ),
            const SizedBox(width: AppConstants.paddingS),

            // خيار ولي الأمر
            Expanded(
              child: _RoleCard(
                role: UserRole.parent,
                icon: Icons.family_restroom,
                label: 'parent'.tr,
                isSelected: controller.selectedRole == UserRole.parent,
                onTap: () => controller.selectedRole = UserRole.parent,
              ),
            ),
            const SizedBox(width: AppConstants.paddingS),

            // خيار المعلم
            Expanded(
              child: _RoleCard(
                role: UserRole.teacher,
                icon: Icons.person_pin,
                label: 'the_teacher'.tr,
                isSelected: controller.selectedRole == UserRole.teacher,
                onTap: () => controller.selectedRole = UserRole.teacher,
              ),
            ),
          ],
        )),

        // ========================================
        // وصف الدور المختار
        // ========================================
        const SizedBox(height: AppConstants.paddingM),
        Obx(() => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(AppConstants.paddingM),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(AppConstants.radiusM),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: AppConstants.paddingS),
              Expanded(
                child: Text(
                  _getRoleDescription(controller.selectedRole),
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  /// الحصول على وصف الدور
  String _getRoleDescription(UserRole role) {
    switch (role) {
      case UserRole.student:
        return 'student_role_description'.tr;
      case UserRole.parent:
        return 'parent_role_description'.tr;
      case UserRole.teacher:
        return 'teacher_role_description'.tr;
      default:
        return '';
    }
  }

  /// بناء حقل الاسم الكامل
  Widget _buildFullNameField() {
    return CustomTextField(
      formControlName: 'full_name',
      label: 'full_name'.tr,
      hint: 'enter_full_name'.tr,
      prefixIcon: Icons.person_outlined,
      textInputAction: TextInputAction.next,
      validationMessages: {
        'required': (error) => 'full_name_required'.tr,
        'minLength': (error) => 'name_min_length'.tr,
      },
    );
  }

  /// بناء حقل البريد الإلكتروني
  Widget _buildEmailField() {
    return CustomTextField(
      formControlName: 'email',
      label: 'email'.tr,
      hint: 'enter_email'.tr,
      prefixIcon: Icons.email_outlined,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      validationMessages: {
        'required': (error) => 'email_required'.tr,
        'email': (error) => 'invalid_email'.tr,
      },
    );
  }

  /// بناء حقل رقم الهاتف الذكي
  /// يكتشف الدولة تلقائياً من إعدادات الجهاز
  /// مصمم ليتوافق مع باقي الحقول (CustomTextField)
  Widget _buildPhoneField() {
    return SmartPhoneField(
      label: 'phone'.tr,
      hint: 'enter_phone'.tr,
      onChanged: (phone) {
        // تحديث قيمة الهاتف في النموذج
        controller.registerForm.control('phone').value = phone.completeNumber;
        debugPrint('📞 Phone: ${phone.completeNumber}');
        debugPrint('📍 Country: ${phone.countryCode} (${phone.countryISOCode})');
      },
      onCountryChanged: (country) {
        debugPrint('🌍 Country changed to: ${country.name} (${country.code})');
      },
    );
  }

  /// بناء حقل كلمة المرور
  Widget _buildPasswordField() {
    return Obx(() => CustomTextField(
          formControlName: 'password',
          label: 'password'.tr,
          hint: 'enter_password'.tr,
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
          textInputAction: TextInputAction.next,
          validationMessages: {
            'required': (error) => 'password_required'.tr,
            'minLength': (error) => 'password_too_short'.tr,
            'pattern': (error) => 'password_pattern'.tr,
          },
        ));
  }

  /// بناء حقل تأكيد كلمة المرور
  Widget _buildConfirmPasswordField() {
    return Obx(() => CustomTextField(
          formControlName: 'confirm_password',
          label: 'confirm_password'.tr,
          hint: 'reenter_password'.tr,
          prefixIcon: Icons.lock_outlined,
          obscureText: controller.obscureConfirmPassword,
          suffixIcon: IconButton(
            icon: Icon(
              controller.obscureConfirmPassword
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
            ),
            onPressed: controller.toggleConfirmPasswordVisibility,
          ),
          textInputAction: TextInputAction.done,
          validationMessages: {
            'required': (error) => 'confirm_password_required'.tr,
            'mustMatch': (error) => 'password_mismatch'.tr,
          },
        ));
  }

  /// بناء الحقول الإضافية للمعلم
  ///
  /// TODO: للإنتاج - إضافة:
  /// - رفع صورة الهوية
  /// - رفع الشهادات العلمية
  /// - اختيار المواد التي يدرسها
  /// - تحديد المراحل الدراسية
  /// - إضافة السيرة الذاتية
  Widget _buildTeacherFields() {
    return Obx(() {
      if (controller.selectedRole != UserRole.teacher) {
        return const SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ========================================
          // عنوان قسم معلومات المعلم
          // ========================================
          Container(
            padding: const EdgeInsets.all(AppConstants.paddingM),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
              border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.info, color: Colors.amber[700]),
                const SizedBox(width: AppConstants.paddingS),
                Expanded(
                  child: Text(
                    'teacher_registration_notice'.tr,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.amber[800],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppConstants.paddingM),

          // ========================================
          // حقل التخصص
          // TODO: تحويله لقائمة منسدلة متعددة الاختيارات
          // ========================================
          CustomTextField(
            formControlName: 'specialization',
            label: 'specialization'.tr,
            hint: 'specialization_hint'.tr,
            prefixIcon: Icons.school,
            textInputAction: TextInputAction.next,
            validationMessages: {
              'required': (error) => 'specialization_required'.tr,
            },
          ),

          const SizedBox(height: AppConstants.paddingM),

          // ========================================
          // حقل سنوات الخبرة
          // ========================================
          CustomTextField(
            formControlName: 'experience_years',
            label: 'experience_years'.tr,
            hint: 'experience_years_hint'.tr,
            prefixIcon: Icons.work_history,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            validationMessages: {
              'required': (error) => 'experience_required'.tr,
            },
          ),

          const SizedBox(height: AppConstants.paddingM),

          // ========================================
          // زر رفع الشهادات (محاكاة)
          // TODO: تفعيل رفع الملفات الفعلي
          // ========================================
          OutlinedButton.icon(
            onPressed: () {
              Get.snackbar(
                'coming_soon'.tr,
                'upload_certificates_coming_soon'.tr,
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            icon: const Icon(Icons.upload_file),
            label: Text('upload_certificates'.tr),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.all(AppConstants.paddingM),
            ),
          ),

          const SizedBox(height: AppConstants.paddingL),
        ],
      );
    });
  }

  /// بناء مربع الموافقة على الشروط والأحكام
  Widget _buildTermsCheckbox() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ReactiveCheckbox(
          formControlName: 'accept_terms',
          activeColor: AppColors.primary,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: GestureDetector(
            onTap: () {
              final control = controller.registerForm.control('accept_terms');
              control.value = !(control.value ?? false);
            },
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
                children: [
                  TextSpan(text: 'i_agree_to'.tr),
                  TextSpan(
                    text: 'terms_and_conditions'.tr,
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextSpan(text: 'and'.tr),
                  TextSpan(
                    text: 'privacy_policy'.tr,
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// بناء زر إنشاء الحساب
  Widget _buildRegisterButton() {
    return Obx(() => CustomButton(
          text: 'create_account'.tr,
          onPressed: controller.register,
          isLoading: controller.isLoading,
        ));
  }

  /// بناء رابط تسجيل الدخول
  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'already_have_account'.tr,
          style: TextStyle(
            color: AppColors.textSecondary,
          ),
        ),
        TextButton(
          onPressed: () => Get.back(),
          child: Text(
            'login'.tr,
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

/// ============================================================================
/// ويدجت بطاقة اختيار الدور
/// ============================================================================
///
/// تعرض بطاقة قابلة للنقر لاختيار نوع الحساب
/// تتغير ألوانها عند التحديد
///
class _RoleCard extends StatelessWidget {
  final UserRole role;
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.role,
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(AppConstants.paddingM),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.textSecondary.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(height: AppConstants.paddingS),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color:
                    isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

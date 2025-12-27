import 'package:get/get.dart';
import 'package:reactive_forms/reactive_forms.dart';

import '../../../core/utils/helpers.dart';
import '../../../core/utils/storage_service.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../global/controllers/app_controller.dart';
import '../../../routes/app_routes.dart';

/// Auth controller
class AuthController extends GetxController {
  final AuthRepository _authRepo = Get.find();
  final StorageService _storage = Get.find();
  final AppController _appController = Get.find();

  // Loading states
  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  // Password visibility
  final _obscurePassword = true.obs;
  bool get obscurePassword => _obscurePassword.value;

  final _obscureConfirmPassword = true.obs;
  bool get obscureConfirmPassword => _obscureConfirmPassword.value;

  // Selected role for registration
  final _selectedRole = UserRole.student.obs;
  UserRole get selectedRole => _selectedRole.value;
  set selectedRole(UserRole role) => _selectedRole.value = role;

  // OTP related
  final _otpIdentifier = ''.obs;
  String get otpIdentifier => _otpIdentifier.value;

  final _otpType = 'email'.obs;
  String get otpType => _otpType.value;

  // Login form
  late final FormGroup loginForm;

  // Register form
  late final FormGroup registerForm;

  // Forgot password form
  late final FormGroup forgotPasswordForm;

  // OTP form
  late final FormGroup otpForm;

  // Reset password form
  late final FormGroup resetPasswordForm;

  @override
  void onInit() {
    super.onInit();
    _initForms();
  }

  void _initForms() {
    // Login form
    loginForm = FormGroup({
      'email': FormControl<String>(
        validators: [
          Validators.required,
          Validators.email,
        ],
      ),
      'password': FormControl<String>(
        validators: [
          Validators.required,
          Validators.minLength(8),
        ],
      ),
      'remember_me': FormControl<bool>(value: false),
    });

    // ========================================
    // Register form
    // Includes additional fields for teachers
    // ========================================
    registerForm = FormGroup({
      'full_name': FormControl<String>(
        validators: [
          Validators.required,
          Validators.minLength(3),
        ],
      ),
      'email': FormControl<String>(
        validators: [
          Validators.required,
          Validators.email,
        ],
      ),
      'phone': FormControl<String>(
        validators: [
          Validators.required,
          Validators.pattern(r'^(05|5)(5|0|3|6|4|9|1|8|7)([0-9]{7})$'),
        ],
      ),
      'password': FormControl<String>(
        validators: [
          Validators.required,
          Validators.minLength(8),
          Validators.pattern(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)'),
        ],
      ),
      'confirm_password': FormControl<String>(
        validators: [Validators.required],
      ),
      'accept_terms': FormControl<bool>(
        value: false,
        validators: [Validators.requiredTrue],
      ),
      // ========================================
      // Additional fields for teachers
      // TODO: For production - enable dynamic validation based on role
      // ========================================
      'specialization': FormControl<String>(),
      'experience_years': FormControl<String>(),
    });
    registerForm.setValidators([Validators.mustMatch('password', 'confirm_password')]);

    // Forgot password form
    forgotPasswordForm = FormGroup({
      'email': FormControl<String>(
        validators: [
          Validators.required,
          Validators.email,
        ],
      ),
    });

    // OTP form
    otpForm = FormGroup({
      'otp': FormControl<String>(
        validators: [
          Validators.required,
          Validators.minLength(4),
          Validators.maxLength(6),
        ],
      ),
    });

    // Reset password form
    resetPasswordForm = FormGroup({
      'password': FormControl<String>(
        validators: [
          Validators.required,
          Validators.minLength(8),
          Validators.pattern(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)'),
        ],
      ),
      'confirm_password': FormControl<String>(
        validators: [Validators.required],
      ),
    });
    resetPasswordForm.setValidators([Validators.mustMatch('password', 'confirm_password')]);
  }

  // Toggle password visibility
  void togglePasswordVisibility() {
    _obscurePassword.value = !_obscurePassword.value;
  }

  void toggleConfirmPasswordVisibility() {
    _obscureConfirmPassword.value = !_obscureConfirmPassword.value;
  }

  /// Login
  Future<void> login() async {
    if (loginForm.invalid) {
      loginForm.markAllAsTouched();
      return;
    }

    _isLoading.value = true;

    try {
      final email = loginForm.control('email').value as String;
      final password = loginForm.control('password').value as String;
      final rememberMe = loginForm.control('remember_me').value as bool? ?? false;

      final user = await _authRepo.login(
        email: email,
        password: password,
      );

      // Save auth data
      await _storage.setToken('mock_token_${DateTime.now().millisecondsSinceEpoch}');
      await _storage.setUserData(user.toJson());

      if (rememberMe) {
        await _storage.setRefreshToken('mock_refresh_token');
      }

      // Update app controller
      await _appController.updateUser(user);

      // Navigate based on user role
      _navigateByRole(user.role);

      Helpers.showSuccess('success_login'.tr);
    } catch (e) {
      Helpers.showError(e.toString());
    } finally {
      _isLoading.value = false;
    }
  }

  // ========================================
  // Quick login for testing (Dev Only)
  // TODO: Remove these functions in production
  // ========================================

  /// Quick login as student
  Future<void> quickLoginAsStudent() async {
    await _quickLogin(
      email: 'student@example.com',
      password: 'password123',
      role: UserRole.student,
      name: 'Ahmed Student',
    );
  }

  /// Quick login as parent
  Future<void> quickLoginAsParent() async {
    await _quickLogin(
      email: 'parent@example.com',
      password: 'password123',
      role: UserRole.parent,
      name: 'Ahmed Parent',
    );
  }

  /// Quick login as teacher
  Future<void> quickLoginAsTeacher() async {
    await _quickLogin(
      email: 'teacher@example.com',
      password: 'password123',
      role: UserRole.teacher,
      name: 'Ms. Sara Teacher',
    );
  }

  /// Helper function for quick login
  Future<void> _quickLogin({
    required String email,
    required String password,
    required UserRole role,
    required String name,
  }) async {
    _isLoading.value = true;

    try {
      final user = await _authRepo.login(
        email: email,
        password: password,
      );

      await _storage.setToken('mock_token_${DateTime.now().millisecondsSinceEpoch}');
      await _storage.setUserData(user.toJson());
      await _appController.updateUser(user);

      _navigateByRole(user.role);
      Helpers.showSuccess('${'welcome'.tr} $name');
    } catch (e) {
      Helpers.showError(e.toString());
    } finally {
      _isLoading.value = false;
    }
  }

  /// Register
  Future<void> register() async {
    if (registerForm.invalid) {
      registerForm.markAllAsTouched();
      return;
    }

    _isLoading.value = true;

    try {
      final fullName = registerForm.control('full_name').value as String;
      final email = registerForm.control('email').value as String;
      final phone = registerForm.control('phone').value as String;
      final password = registerForm.control('password').value as String;

      await _authRepo.register(
        fullName: fullName,
        email: email,
        phone: phone,
        password: password,
        role: selectedRole,
      );

      // Set OTP identifier for verification
      _otpIdentifier.value = email;
      _otpType.value = 'email';

      // Navigate to OTP
      Get.toNamed(Routes.otp);

      Helpers.showSuccess('account_created_verify_email'.tr);
    } catch (e) {
      Helpers.showError(e.toString());
    } finally {
      _isLoading.value = false;
    }
  }

  /// Forgot password
  Future<void> forgotPassword() async {
    if (forgotPasswordForm.invalid) {
      forgotPasswordForm.markAllAsTouched();
      return;
    }

    _isLoading.value = true;

    try {
      final email = forgotPasswordForm.control('email').value as String;

      await _authRepo.forgotPassword(email: email);

      // Set OTP identifier
      _otpIdentifier.value = email;
      _otpType.value = 'email';

      // Navigate to OTP
      Get.toNamed(Routes.otp);

      Helpers.showSuccess('otp_sent_to_email'.tr);
    } catch (e) {
      Helpers.showError(e.toString());
    } finally {
      _isLoading.value = false;
    }
  }

  /// Verify OTP
  Future<void> verifyOtp() async {
    if (otpForm.invalid) {
      otpForm.markAllAsTouched();
      return;
    }

    _isLoading.value = true;

    try {
      final otp = otpForm.control('otp').value as String;

      final verified = await _authRepo.verifyOtp(
        identifier: otpIdentifier,
        otp: otp,
      );

      if (verified) {
        // Navigate to reset password or main based on flow
        Get.offAllNamed(Routes.login);
        Helpers.showSuccess('verification_success'.tr);
      } else {
        Helpers.showError('invalid_otp'.tr);
      }
    } catch (e) {
      Helpers.showError(e.toString());
    } finally {
      _isLoading.value = false;
    }
  }

  /// Resend OTP
  Future<void> resendOtp() async {
    _isLoading.value = true;

    try {
      await _authRepo.sendOtp(
        identifier: otpIdentifier,
        type: otpType,
      );

      Helpers.showSuccess('otp_resent'.tr);
    } catch (e) {
      Helpers.showError(e.toString());
    } finally {
      _isLoading.value = false;
    }
  }

  /// Social login
  Future<void> socialLogin(String provider) async {
    _isLoading.value = true;

    try {
      // In real app, implement OAuth flow here
      // For mock, simulate success
      final user = await _authRepo.socialLogin(
        provider: provider,
        accessToken: 'mock_social_token',
      );

      await _storage.setToken('mock_token_${DateTime.now().millisecondsSinceEpoch}');
      await _storage.setUserData(user.toJson());
      await _appController.updateUser(user);

      // Navigate based on user role
      _navigateByRole(user.role);
      Helpers.showSuccess('success_login'.tr);
    } catch (e) {
      Helpers.showError(e.toString());
    } finally {
      _isLoading.value = false;
    }
  }

  /// Navigate based on user role
  void _navigateByRole(UserRole role) {
    switch (role) {
      case UserRole.parent:
        Get.offAllNamed(Routes.parentDashboard);
        break;
      case UserRole.teacher:
        Get.offAllNamed(Routes.teacherDashboard);
        break;
      case UserRole.student:
      case UserRole.admin:
      default:
        Get.offAllNamed(Routes.main);
        break;
    }
  }

  /// Logout
  Future<void> logout() async {
    try {
      await _authRepo.logout();
    } catch (e) {
      // Ignore logout errors
    } finally {
      await _appController.clearUser();
      Get.offAllNamed(Routes.login);
    }
  }

  /// Get validation message for form control
  String? getValidationMessage(String controlName, FormGroup form) {
    final control = form.control(controlName);
    if (control.hasErrors && control.touched) {
      final errors = control.errors;

      if (errors.containsKey('required')) {
        return 'field_required'.trParams({'field': _getFieldLabel(controlName)});
      }
      if (errors.containsKey('email')) {
        return 'invalid_email'.tr;
      }
      if (errors.containsKey('minLength')) {
        final minLength = errors['minLength']['requiredLength'];
        return 'min_length_required'.trParams({'length': '$minLength'});
      }
      if (errors.containsKey('pattern')) {
        if (controlName == 'phone') {
          return 'invalid_phone'.tr;
        }
        if (controlName == 'password') {
          return 'password_requirements'.tr;
        }
      }
      if (errors.containsKey('mustMatch')) {
        return 'passwords_not_match'.tr;
      }
      if (errors.containsKey('requiredTrue')) {
        return 'must_accept_terms'.tr;
      }
    }
    return null;
  }

  String _getFieldLabel(String controlName) {
    switch (controlName) {
      case 'email':
        return 'email'.tr;
      case 'password':
        return 'password'.tr;
      case 'confirm_password':
        return 'confirm_password'.tr;
      case 'full_name':
        return 'full_name'.tr;
      case 'phone':
        return 'phone'.tr;
      case 'otp':
        return 'otp_code'.tr;
      default:
        return controlName;
    }
  }

  @override
  void onClose() {
    loginForm.dispose();
    registerForm.dispose();
    forgotPasswordForm.dispose();
    otpForm.dispose();
    resetPasswordForm.dispose();
    super.onClose();
  }
}

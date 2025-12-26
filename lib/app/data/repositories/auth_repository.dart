import 'package:get/get.dart';

import '../../config/env_config.dart';
import '../../core/network/api_client.dart';
import '../../core/constants/api_constants.dart';
import '../models/user_model.dart';
import '../mock/mock_data.dart';

/// Authentication repository
class AuthRepository {
  final ApiClient _api = Get.find();
  bool get _useMock => EnvConfig.useMockData;

  /// Login with email and password
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    if (_useMock) {
      await Future.delayed(const Duration(seconds: 1));

      // بيانات الدخول للاختبار:
      // طالب: student@example.com / password123
      // ولي أمر: parent@example.com / password123
      // معلم: teacher@example.com / password123

      if (email == 'student@example.com' && password == 'password123') {
        return MockData.currentUser;
      }

      if (email == 'parent@example.com' && password == 'password123') {
        return MockData.currentUser.copyWith(
          id: 'parent_1',
          email: 'parent@example.com',
          fullName: 'أحمد الوالد',
          role: UserRole.parent,
        );
      }

      if (email == 'teacher@example.com' && password == 'password123') {
        return MockData.currentUser.copyWith(
          id: 'teacher_1',
          email: 'teacher@example.com',
          fullName: 'أ. سارة المعلمة',
          role: UserRole.teacher,
        );
      }

      throw Exception('بيانات الدخول غير صحيحة');
    }

    final response = await _api.post(
      ApiConstants.login,
      data: {
        'email': email,
        'password': password,
      },
    );

    return UserModel.fromJson(response.data['user']);
  }

  /// Register new user
  Future<UserModel> register({
    required String fullName,
    required String email,
    required String password,
    required String phone,
    required UserRole role,
    String? parentId,
  }) async {
    if (_useMock) {
      await Future.delayed(const Duration(seconds: 1));
      // Simulate registration
      return MockData.currentUser.copyWith(
        fullName: fullName,
        email: email,
        phone: phone,
        role: role,
      );
    }

    final response = await _api.post(
      ApiConstants.register,
      data: {
        'full_name': fullName,
        'email': email,
        'password': password,
        'phone': phone,
        'role': role.value,
        'parent_id': parentId,
      },
    );

    return UserModel.fromJson(response.data['user']);
  }

  /// Send OTP to phone/email
  Future<void> sendOtp({
    required String identifier,
    required String type, // 'phone' or 'email'
  }) async {
    if (_useMock) {
      await Future.delayed(const Duration(seconds: 1));
      return;
    }

    await _api.post(
      ApiConstants.sendOtp,
      data: {
        'identifier': identifier,
        'type': type,
      },
    );
  }

  /// Verify OTP
  Future<bool> verifyOtp({
    required String identifier,
    required String otp,
  }) async {
    if (_useMock) {
      await Future.delayed(const Duration(seconds: 1));
      // Simulate OTP verification
      return otp == '1234';
    }

    final response = await _api.post(
      ApiConstants.verifyOtp,
      data: {
        'identifier': identifier,
        'otp': otp,
      },
    );

    return response.data['verified'] == true;
  }

  /// Forgot password - send reset link
  Future<void> forgotPassword({required String email}) async {
    if (_useMock) {
      await Future.delayed(const Duration(seconds: 1));
      return;
    }

    await _api.post(
      ApiConstants.forgotPassword,
      data: {'email': email},
    );
  }

  /// Reset password
  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    if (_useMock) {
      await Future.delayed(const Duration(seconds: 1));
      return;
    }

    await _api.post(
      ApiConstants.resetPassword,
      data: {
        'token': token,
        'new_password': newPassword,
      },
    );
  }

  /// Logout
  Future<void> logout() async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 500));
      return;
    }

    await _api.post(ApiConstants.logout);
  }

  /// Refresh token
  Future<String> refreshToken(String refreshToken) async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 500));
      return 'mock_access_token_${DateTime.now().millisecondsSinceEpoch}';
    }

    final response = await _api.post(
      ApiConstants.refreshToken,
      data: {'refresh_token': refreshToken},
    );

    return response.data['access_token'];
  }

  /// Social login
  Future<UserModel> socialLogin({
    required String provider, // 'google', 'apple', 'facebook'
    required String accessToken,
  }) async {
    if (_useMock) {
      await Future.delayed(const Duration(seconds: 1));
      return MockData.currentUser;
    }

    final response = await _api.post(
      '${ApiConstants.socialLogin}/$provider',
      data: {'access_token': accessToken},
    );

    return UserModel.fromJson(response.data['user']);
  }
}

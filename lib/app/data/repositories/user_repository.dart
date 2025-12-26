import 'package:get/get.dart';

import '../../config/env_config.dart';
import '../../core/network/api_client.dart';
import '../../core/constants/api_constants.dart';
import '../models/user_model.dart';
import '../mock/mock_data.dart';

/// User repository
class UserRepository {
  final ApiClient _api = Get.find();
  bool get _useMock => EnvConfig.useMockData;

  /// Get current user profile
  Future<UserModel> getProfile() async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 500));
      return MockData.currentUser;
    }

    final response = await _api.get(ApiConstants.profile);
    return UserModel.fromJson(response.data);
  }

  /// Update user profile
  Future<UserModel> updateProfile({
    String? fullName,
    String? phone,
    String? avatar,
    String? dateOfBirth,
    String? grade,
    List<String>? interests,
  }) async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 500));
      return MockData.currentUser.copyWith(
        fullName: fullName,
        phone: phone,
        avatar: avatar,
      );
    }

    final response = await _api.put(
      ApiConstants.updateProfile,
      data: {
        if (fullName != null) 'full_name': fullName,
        if (phone != null) 'phone': phone,
        if (avatar != null) 'avatar': avatar,
        if (dateOfBirth != null) 'date_of_birth': dateOfBirth,
        if (grade != null) 'grade': grade,
        if (interests != null) 'interests': interests,
      },
    );
    return UserModel.fromJson(response.data);
  }

  /// Change password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 500));
      return;
    }

    await _api.post(
      ApiConstants.changePassword,
      data: {
        'current_password': currentPassword,
        'new_password': newPassword,
      },
    );
  }

  /// Upload avatar
  Future<String> uploadAvatar(String filePath) async {
    if (_useMock) {
      await Future.delayed(const Duration(seconds: 1));
      return 'https://example.com/avatars/mock_avatar.jpg';
    }

    final response = await _api.uploadFile(
      '${ApiConstants.profile}/avatar',
      filePath: filePath,
      fieldName: 'avatar',
    );
    return response.data['avatar_url'];
  }

  /// Get user statistics
  Future<UserStats> getStats() async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 500));
      return MockData.currentUser.stats;
    }

    final response = await _api.get('${ApiConstants.profile}/stats');
    return UserStats.fromJson(response.data);
  }

  /// Get children (for parent users)
  Future<List<UserModel>> getChildren() async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 500));
      // Return mock children
      return [
        UserModel(
          id: 'child_1',
          email: 'child1@example.com',
          fullName: 'أحمد',
          role: UserRole.student,
          createdAt: DateTime.now(),
          parentId: MockData.currentUser.id,
          level: 5,
          points: 2500,
          eduCoins: 150,
          streak: 7,
          stats: const UserStats(
            completedCourses: 3,
            completedLessons: 45,
            totalStudyMinutes: 1200,
            completedQuizzes: 15,
            averageQuizScore: 85.5,
          ),
        ),
        UserModel(
          id: 'child_2',
          email: 'child2@example.com',
          fullName: 'سارة',
          role: UserRole.student,
          createdAt: DateTime.now(),
          parentId: MockData.currentUser.id,
          level: 3,
          points: 1200,
          eduCoins: 80,
          streak: 3,
          stats: const UserStats(
            completedCourses: 1,
            completedLessons: 20,
            totalStudyMinutes: 600,
            completedQuizzes: 8,
            averageQuizScore: 78.0,
          ),
        ),
      ];
    }

    final response = await _api.get('${ApiConstants.profile}/children');
    return (response.data['data'] as List)
        .map((e) => UserModel.fromJson(e))
        .toList();
  }

  /// Link child to parent
  Future<void> linkChild(String childCode) async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 500));
      return;
    }

    await _api.post(
      '${ApiConstants.profile}/link-child',
      data: {'child_code': childCode},
    );
  }

  /// Get notifications
  Future<List<Map<String, dynamic>>> getNotifications({
    int page = 1,
    int limit = 20,
  }) async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 500));
      return [
        {
          'id': 'notif_1',
          'title': 'جلسة جديدة',
          'body': 'تم حجز جلسة جديدة مع أ. سارة',
          'type': 'session',
          'is_read': false,
          'created_at': DateTime.now().subtract(const Duration(hours: 1)),
        },
        {
          'id': 'notif_2',
          'title': 'إنجاز جديد',
          'body': 'مبروك! حصلت على شارة المتعلم النشط',
          'type': 'achievement',
          'is_read': true,
          'created_at': DateTime.now().subtract(const Duration(days: 1)),
        },
      ];
    }

    final response = await _api.get(
      ApiConstants.notifications,
      queryParameters: {
        'page': page,
        'limit': limit,
      },
    );
    return List<Map<String, dynamic>>.from(response.data['data']);
  }

  /// Mark notification as read
  Future<void> markNotificationRead(String notificationId) async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 200));
      return;
    }

    await _api.post('${ApiConstants.notifications}/$notificationId/read');
  }

  /// Mark all notifications as read
  Future<void> markAllNotificationsRead() async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 200));
      return;
    }

    await _api.post('${ApiConstants.notifications}/read-all');
  }

  /// Delete account
  Future<void> deleteAccount({required String password}) async {
    if (_useMock) {
      await Future.delayed(const Duration(seconds: 1));
      return;
    }

    await _api.delete(
      ApiConstants.profile,
      data: {'password': password},
    );
  }
}

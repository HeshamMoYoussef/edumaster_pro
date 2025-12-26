import 'package:get/get.dart';

import '../../config/env_config.dart';
import '../../core/network/api_client.dart';
import '../../core/constants/api_constants.dart';
import '../models/teacher_model.dart';
import '../mock/mock_data.dart';

/// Teacher repository
class TeacherRepository {
  final ApiClient _api = Get.find();
  bool get _useMock => EnvConfig.useMockData;

  /// Get all teachers
  Future<List<TeacherModel>> getTeachers({
    String? subject,
    String? language,
    double? minRating,
    double? maxRate,
    bool? isAvailable,
    String? search,
    int page = 1,
    int limit = 20,
  }) async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 800));
      var teachers = MockData.teachers;

      // Filter by subject
      if (subject != null) {
        teachers = teachers
            .where((t) => t.subjects.contains(subject))
            .toList();
      }

      // Filter by availability
      if (isAvailable == true) {
        teachers = teachers.where((t) => t.isAvailable).toList();
      }

      // Filter by minimum rating
      if (minRating != null) {
        teachers = teachers.where((t) => t.rating >= minRating).toList();
      }

      // Search
      if (search != null && search.isNotEmpty) {
        teachers = teachers
            .where((t) =>
                t.fullName.contains(search) ||
                t.subjects.any((s) => s.contains(search)))
            .toList();
      }

      return teachers;
    }

    final response = await _api.get(
      ApiConstants.teachers,
      queryParameters: {
        if (subject != null) 'subject': subject,
        if (language != null) 'language': language,
        if (minRating != null) 'min_rating': minRating,
        if (maxRate != null) 'max_rate': maxRate,
        if (isAvailable != null) 'is_available': isAvailable,
        if (search != null) 'search': search,
        'page': page,
        'limit': limit,
      },
    );

    return (response.data['data'] as List)
        .map((e) => TeacherModel.fromJson(e))
        .toList();
  }

  /// Get featured teachers
  Future<List<TeacherModel>> getFeaturedTeachers() async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 500));
      return MockData.teachers.where((t) => t.isFeatured).toList();
    }

    final response = await _api.get('${ApiConstants.teachers}/featured');
    return (response.data['data'] as List)
        .map((e) => TeacherModel.fromJson(e))
        .toList();
  }

  /// Get teacher by ID
  Future<TeacherModel> getTeacherById(String id) async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 500));
      final teacher = MockData.teachers.firstWhere(
        (t) => t.id == id,
        orElse: () => throw Exception('المعلم غير موجود'),
      );
      return teacher;
    }

    final response = await _api.get('${ApiConstants.teachers}/$id');
    return TeacherModel.fromJson(response.data);
  }

  /// Get teacher availability
  Future<TeacherAvailability> getTeacherAvailability(String teacherId) async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 500));
      final teacher = MockData.teachers.firstWhere(
        (t) => t.id == teacherId,
        orElse: () => throw Exception('المعلم غير موجود'),
      );
      return teacher.availability;
    }

    final response = await _api.get(
      '${ApiConstants.teachers}/$teacherId/availability',
    );
    return TeacherAvailability.fromJson(response.data);
  }

  /// Get teacher reviews
  Future<List<Map<String, dynamic>>> getTeacherReviews(String teacherId) async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 500));
      return [
        {
          'id': 'rev_1',
          'user_name': 'محمد أحمد',
          'rating': 5.0,
          'comment': 'معلم ممتاز وصبور جداً',
          'created_at': DateTime.now().subtract(const Duration(days: 3)),
        },
        {
          'id': 'rev_2',
          'user_name': 'نورة خالد',
          'rating': 4.5,
          'comment': 'شرح واضح وأسلوب تعليمي رائع',
          'created_at': DateTime.now().subtract(const Duration(days: 7)),
        },
      ];
    }

    final response = await _api.get(
      '${ApiConstants.teachers}/$teacherId/reviews',
    );
    return List<Map<String, dynamic>>.from(response.data['data']);
  }

  /// Add teacher to favorites
  Future<void> addToFavorites(String teacherId) async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      return;
    }

    await _api.post('${ApiConstants.teachers}/$teacherId/favorite');
  }

  /// Remove teacher from favorites
  Future<void> removeFromFavorites(String teacherId) async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      return;
    }

    await _api.delete('${ApiConstants.teachers}/$teacherId/favorite');
  }

  /// Get favorite teachers
  Future<List<TeacherModel>> getFavoriteTeachers() async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 500));
      // Return first 2 as favorites for mock
      return MockData.teachers.take(2).toList();
    }

    final response = await _api.get('${ApiConstants.teachers}/favorites');
    return (response.data['data'] as List)
        .map((e) => TeacherModel.fromJson(e))
        .toList();
  }
}

import 'package:get/get.dart';

import '../../config/env_config.dart';
import '../../core/network/api_client.dart';
import '../../core/constants/api_constants.dart';
import '../models/course_model.dart';
import '../mock/mock_data.dart';

/// Course repository
class CourseRepository {
  final ApiClient _api = Get.find();
  bool get _useMock => EnvConfig.useMockData;

  /// Get all courses
  Future<List<CourseModel>> getCourses({
    String? categoryId,
    String? level,
    String? search,
    String? sortBy,
    int page = 1,
    int limit = 20,
  }) async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 800));
      var courses = MockData.courses;

      // Filter by category
      if (categoryId != null) {
        courses = courses.where((c) => c.categoryId == categoryId).toList();
      }

      // Filter by level
      if (level != null) {
        courses =
            courses.where((c) => c.level.value == level).toList();
      }

      // Search
      if (search != null && search.isNotEmpty) {
        courses = courses
            .where((c) =>
                c.title.contains(search) || c.description.contains(search))
            .toList();
      }

      return courses;
    }

    final response = await _api.get(
      ApiConstants.courses,
      queryParameters: {
        if (categoryId != null) 'category_id': categoryId,
        if (level != null) 'level': level,
        if (search != null) 'search': search,
        if (sortBy != null) 'sort_by': sortBy,
        'page': page,
        'limit': limit,
      },
    );

    return (response.data['data'] as List)
        .map((e) => CourseModel.fromJson(e))
        .toList();
  }

  /// Get featured courses
  Future<List<CourseModel>> getFeaturedCourses() async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 500));
      return MockData.courses.where((c) => c.isFeatured).toList();
    }

    final response = await _api.get('${ApiConstants.courses}/featured');
    return (response.data['data'] as List)
        .map((e) => CourseModel.fromJson(e))
        .toList();
  }

  /// Get course by ID
  Future<CourseModel> getCourseById(String id) async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 500));
      final course = MockData.courses.firstWhere(
        (c) => c.id == id,
        orElse: () => throw Exception('الكورس غير موجود'),
      );
      return course;
    }

    final response = await _api.get('${ApiConstants.courses}/$id');
    return CourseModel.fromJson(response.data);
  }

  /// Get categories
  Future<List<CategoryModel>> getCategories() async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 500));
      return MockData.categories;
    }

    final response = await _api.get(ApiConstants.categories);
    return (response.data['data'] as List)
        .map((e) => CategoryModel.fromJson(e))
        .toList();
  }

  /// Enroll in course
  Future<EnrollmentModel> enrollInCourse(String courseId) async {
    if (_useMock) {
      await Future.delayed(const Duration(seconds: 1));
      return EnrollmentModel(
        id: 'enroll_${DateTime.now().millisecondsSinceEpoch}',
        userId: MockData.currentUser.id,
        courseId: courseId,
        enrolledAt: DateTime.now(),
      );
    }

    final response = await _api.post(
      '${ApiConstants.courses}/$courseId/enroll',
    );
    return EnrollmentModel.fromJson(response.data);
  }

  /// Get user enrollments
  Future<List<EnrollmentModel>> getMyEnrollments() async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 500));
      return MockData.enrollments;
    }

    final response = await _api.get(ApiConstants.myEnrollments);
    return (response.data['data'] as List)
        .map((e) => EnrollmentModel.fromJson(e))
        .toList();
  }

  /// Update lesson progress
  Future<void> updateLessonProgress({
    required String courseId,
    required String lessonId,
    required double progress,
    bool isCompleted = false,
  }) async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      return;
    }

    await _api.post(
      '${ApiConstants.courses}/$courseId/lessons/$lessonId/progress',
      data: {
        'progress': progress,
        'is_completed': isCompleted,
      },
    );
  }

  /// Get course reviews
  Future<List<Map<String, dynamic>>> getCourseReviews(String courseId) async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 500));
      return [
        {
          'id': 'rev_1',
          'user_name': 'أحمد محمد',
          'rating': 5.0,
          'comment': 'كورس ممتاز ومحتوى رائع',
          'created_at': DateTime.now().subtract(const Duration(days: 2)),
        },
        {
          'id': 'rev_2',
          'user_name': 'سارة علي',
          'rating': 4.5,
          'comment': 'استفدت كثيراً من هذا الكورس',
          'created_at': DateTime.now().subtract(const Duration(days: 5)),
        },
      ];
    }

    final response = await _api.get(
      '${ApiConstants.courses}/$courseId/reviews',
    );
    return List<Map<String, dynamic>>.from(response.data['data']);
  }

  /// Add course review
  Future<void> addCourseReview({
    required String courseId,
    required double rating,
    required String comment,
  }) async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 500));
      return;
    }

    await _api.post(
      '${ApiConstants.courses}/$courseId/reviews',
      data: {
        'rating': rating,
        'comment': comment,
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/services/session_reminder_service.dart';
import '../../../data/models/course_model.dart';
import '../../../data/models/teacher_model.dart';
import '../../../data/models/session_model.dart';
import '../../../data/models/achievement_model.dart';
import '../../../data/repositories/course_repository.dart';
import '../../../data/repositories/teacher_repository.dart';
import '../../../data/repositories/session_repository.dart';
import '../../../data/repositories/achievement_repository.dart';
import '../../../global/controllers/app_controller.dart';

/// Home controller
class HomeController extends GetxController {
  final CourseRepository _courseRepo = Get.find();
  final TeacherRepository _teacherRepo = Get.find();
  final SessionRepository _sessionRepo = Get.find();
  final AchievementRepository _achievementRepo = Get.find();
  final AppController _appController = Get.find();

  // Loading state
  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  final _isRefreshing = false.obs;
  bool get isRefreshing => _isRefreshing.value;

  // Data
  final _categories = <CategoryModel>[].obs;
  List<CategoryModel> get categories => _categories;

  final _featuredCourses = <CourseModel>[].obs;
  List<CourseModel> get featuredCourses => _featuredCourses;

  final _featuredTeachers = <TeacherModel>[].obs;
  List<TeacherModel> get featuredTeachers => _featuredTeachers;

  final _upcomingSessions = <SessionModel>[].obs;
  List<SessionModel> get upcomingSessions => _upcomingSessions;

  final _myEnrollments = <EnrollmentModel>[].obs;
  List<EnrollmentModel> get myEnrollments => _myEnrollments;

  final _dailyChallenges = <DailyChallengeModel>[].obs;
  List<DailyChallengeModel> get dailyChallenges => _dailyChallenges;

  final _streak = Rxn<StreakModel>();
  StreakModel? get streak => _streak.value;

  // User greeting
  String get greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'good_morning'.tr;
    if (hour < 17) return 'good_afternoon'.tr;
    return 'good_evening'.tr;
  }

  String get userName => _appController.currentUser?.fullName ?? 'student'.tr;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    _isLoading.value = true;
    try {
      await Future.wait([
        _loadCategories(),
        _loadFeaturedCourses(),
        _loadFeaturedTeachers(),
        _loadUpcomingSessions(),
        _loadMyEnrollments(),
        _loadDailyChallenges(),
        _loadStreak(),
      ]);
    } catch (e) {
      // Handle error
    } finally {
      _isLoading.value = false;
    }
  }

  @override
  Future<void> refresh() async {
    _isRefreshing.value = true;
    try {
      await loadData();
    } finally {
      _isRefreshing.value = false;
    }
  }

  Future<void> _loadCategories() async {
    try {
      _categories.value = await _courseRepo.getCategories();
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _loadFeaturedCourses() async {
    try {
      _featuredCourses.value = await _courseRepo.getFeaturedCourses();
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _loadFeaturedTeachers() async {
    try {
      _featuredTeachers.value = await _teacherRepo.getFeaturedTeachers();
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _loadUpcomingSessions() async {
    try {
      _upcomingSessions.value = await _sessionRepo.getUpcomingSessions();

      // جدولة تذكيرات للجلسات القادمة
      await _scheduleSessionReminders();
    } catch (e) {
      // Handle error
      debugPrint('Error loading sessions: $e');
    }
  }

  /// جدولة تذكيرات لجميع الجلسات القادمة
  Future<void> _scheduleSessionReminders() async {
    try {
      final reminderService = SessionReminderService.to;

      // جدولة تذكيرات لكل جلسة قادمة
      for (final session in _upcomingSessions) {
        if (session.status == SessionStatus.confirmed &&
            session.scheduledAt.isAfter(DateTime.now())) {
          await reminderService.scheduleReminders(session);
        }
      }

      debugPrint('✅ [Home] Scheduled reminders for ${_upcomingSessions.length} sessions');
    } catch (e) {
      debugPrint('❌ [Home] Failed to schedule reminders: $e');
    }
  }

  Future<void> _loadMyEnrollments() async {
    try {
      _myEnrollments.value = await _courseRepo.getMyEnrollments();
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _loadDailyChallenges() async {
    try {
      _dailyChallenges.value = await _achievementRepo.getDailyChallenges();
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _loadStreak() async {
    try {
      _streak.value = await _achievementRepo.getStreak();
    } catch (e) {
      // Handle error
    }
  }

  // Check in for daily streak
  Future<void> checkIn() async {
    try {
      final newStreak = await _achievementRepo.checkIn();
      _streak.value = newStreak;
    } catch (e) {
      // Handle error
    }
  }
}

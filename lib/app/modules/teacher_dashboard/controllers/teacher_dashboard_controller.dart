import 'package:get/get.dart';

import '../../../data/models/session_model.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/session_repository.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../data/mock/mock_data.dart';
import '../../../global/controllers/app_controller.dart';

/// Teacher Dashboard Controller
class TeacherDashboardController extends GetxController {
  final SessionRepository _sessionRepo = Get.find();
  final UserRepository _userRepo = Get.find();
  final AppController _appController = Get.find();

  // Loading state
  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  // Current tab index
  final _currentIndex = 0.obs;
  int get currentIndex => _currentIndex.value;
  set currentIndex(int value) => _currentIndex.value = value;

  // Data
  final _upcomingSessions = <SessionModel>[].obs;
  List<SessionModel> get upcomingSessions => _upcomingSessions;

  final _todaySessions = <SessionModel>[].obs;
  List<SessionModel> get todaySessions => _todaySessions;

  final _completedSessions = <SessionModel>[].obs;
  List<SessionModel> get completedSessions => _completedSessions;

  final _students = <UserModel>[].obs;
  List<UserModel> get students => _students;

  // Stats
  final _totalStudents = 0.obs;
  int get totalStudents => _totalStudents.value;

  final _totalSessions = 0.obs;
  int get totalSessions => _totalSessions.value;

  final _totalEarnings = 0.0.obs;
  double get totalEarnings => _totalEarnings.value;

  final _monthlyEarnings = 0.0.obs;
  double get monthlyEarnings => _monthlyEarnings.value;

  final _rating = 0.0.obs;
  double get rating => _rating.value;

  final _pendingRequests = 0.obs;
  int get pendingRequests => _pendingRequests.value;

  // Teacher info
  String get teacherName => _appController.currentUser?.fullName ?? 'teacher'.tr;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    _isLoading.value = true;
    try {
      await Future.wait([
        _loadSessions(),
        _loadStudents(),
        _loadStats(),
      ]);
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> _loadSessions() async {
    // Mock sessions for teacher
    await Future.delayed(const Duration(milliseconds: 500));

    final allSessions = MockData.sessions;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    _todaySessions.value = allSessions.where((s) {
      final sessionDate = DateTime(
        s.scheduledAt.year,
        s.scheduledAt.month,
        s.scheduledAt.day,
      );
      return sessionDate == today && s.status != SessionStatus.completed;
    }).toList();

    _upcomingSessions.value = allSessions.where((s) {
      return s.scheduledAt.isAfter(now) &&
             s.status == SessionStatus.confirmed;
    }).toList();

    _completedSessions.value = allSessions.where((s) {
      return s.status == SessionStatus.completed;
    }).toList();
  }

  Future<void> _loadStudents() async {
    // Mock students
    await Future.delayed(const Duration(milliseconds: 300));
    _students.value = [
      MockData.currentUser,
      MockData.currentUser.copyWith(
        id: 'student_2',
        fullName: 'Sara Ahmed',
        email: 'sara@example.com',
      ),
      MockData.currentUser.copyWith(
        id: 'student_3',
        fullName: 'Mohammed Khalid',
        email: 'mohammed@example.com',
      ),
      MockData.currentUser.copyWith(
        id: 'student_4',
        fullName: 'Noura Saeed',
        email: 'noura@example.com',
      ),
    ];
  }

  Future<void> _loadStats() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _totalStudents.value = 45;
    _totalSessions.value = 156;
    _totalEarnings.value = 12500.0;
    _monthlyEarnings.value = 3200.0;
    _rating.value = 4.8;
    _pendingRequests.value = 3;
  }

  Future<void> acceptSession(String sessionId) async {
    try {
      // In real app, call API to accept session
      await Future.delayed(const Duration(milliseconds: 500));
      await loadData();
      Get.snackbar('success'.tr, 'session_accepted'.tr);
    } catch (e) {
      Get.snackbar('error'.tr, 'session_accept_failed'.tr);
    }
  }

  Future<void> rejectSession(String sessionId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      await loadData();
      Get.snackbar('success'.tr, 'session_rejected'.tr);
    } catch (e) {
      Get.snackbar('error'.tr, 'session_reject_failed'.tr);
    }
  }

  Future<void> startSession(String sessionId) async {
    Get.toNamed('/session/$sessionId/live');
  }

  void goToSchedule() {
    currentIndex = 1;
  }

  void goToStudents() {
    currentIndex = 2;
  }

  void goToEarnings() {
    currentIndex = 3;
  }
}

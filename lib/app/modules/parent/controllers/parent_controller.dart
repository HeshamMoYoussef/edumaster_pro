import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/user_model.dart';
import '../../../data/models/session_model.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../data/repositories/session_repository.dart';
import '../../../data/mock/mock_data.dart';
import '../../../global/controllers/app_controller.dart';
import '../../../routes/app_routes.dart';

class ParentController extends GetxController {
  final UserRepository _userRepo = Get.find();
  final AppController _appController = Get.find();

  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  // Current tab index
  final _currentIndex = 0.obs;
  int get currentIndex => _currentIndex.value;
  set currentIndex(int value) => _currentIndex.value = value;

  final _children = <UserModel>[].obs;
  List<UserModel> get children => _children;

  final _selectedChild = Rxn<UserModel>();
  UserModel? get selectedChild => _selectedChild.value;

  final _childSessions = <SessionModel>[].obs;
  List<SessionModel> get childSessions => _childSessions;

  // Notifications
  final _notifications = <Map<String, dynamic>>[].obs;
  List<Map<String, dynamic>> get notifications => _notifications;

  String get parentName => _appController.currentUser?.fullName ?? 'ولي الأمر';

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    _isLoading.value = true;
    try {
      await Future.wait([
        loadChildren(),
        loadNotifications(),
      ]);
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> loadChildren() async {
    try {
      _children.value = await _userRepo.getChildren();
      if (_children.isNotEmpty && _selectedChild.value == null) {
        _selectedChild.value = _children.first;
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<void> loadNotifications() async {
    try {
      _notifications.value = await _userRepo.getNotifications();
    } catch (e) {
      // Handle error
    }
  }

  void selectChild(UserModel child) {
    _selectedChild.value = child;
    loadChildSessions(child.id);
  }

  Future<void> loadChildSessions(String childId) async {
    try {
      // In real app, filter by child ID
      _childSessions.value = MockData.sessions;
    } catch (e) {
      // Handle error
    }
  }

  void viewChildProgress(String childId) {
    Get.toNamed(Routes.childProgressPath(childId));
  }

  void linkNewChild() {
    final codeController = TextEditingController();
    Get.dialog(
      AlertDialog(
        title: const Text('ربط طفل جديد'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('أدخل رمز الربط الخاص بالطفل'),
            const SizedBox(height: 16),
            TextField(
              controller: codeController,
              decoration: const InputDecoration(
                hintText: 'رمز الربط',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _userRepo.linkChild(codeController.text);
                await loadChildren();
                Get.back();
                Get.snackbar('نجاح', 'تم ربط الطفل بنجاح');
              } catch (e) {
                Get.snackbar('خطأ', 'فشل ربط الطفل');
              }
            },
            child: const Text('ربط'),
          ),
        ],
      ),
    );
  }

  void setStudyLimit(String childId, int minutes) {
    Get.snackbar('تم', 'تم تحديد وقت الدراسة بـ $minutes دقيقة');
  }

  void viewSessionDetails(String sessionId) {
    Get.toNamed(Routes.sessionDetailsPath(sessionId));
  }

  void logout() {
    _appController.clearUser();
    Get.offAllNamed(Routes.login);
  }
}

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

  String get parentName => _appController.currentUser?.fullName ?? 'parent'.tr;

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
        title: Text('link_new_child'.tr),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('enter_child_link_code'.tr),
            const SizedBox(height: 16),
            TextField(
              controller: codeController,
              decoration: InputDecoration(
                hintText: 'link_code'.tr,
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('cancel'.tr),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _userRepo.linkChild(codeController.text);
                await loadChildren();
                Get.back();
                Get.snackbar('success'.tr, 'child_linked_success'.tr);
              } catch (e) {
                Get.snackbar('error'.tr, 'child_link_failed'.tr);
              }
            },
            child: Text('link'.tr),
          ),
        ],
      ),
    );
  }

  void setStudyLimit(String childId, int minutes) {
    Get.snackbar('done'.tr, 'study_limit_set'.trParams({'minutes': minutes.toString()}));
  }

  void viewSessionDetails(String sessionId) {
    Get.toNamed(Routes.sessionDetailsPath(sessionId));
  }

  void logout() {
    _appController.clearUser();
    Get.offAllNamed(Routes.login);
  }
}

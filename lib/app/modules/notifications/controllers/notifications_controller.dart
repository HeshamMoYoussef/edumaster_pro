import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/repositories/user_repository.dart';
import '../../../routes/app_routes.dart';

class NotificationsController extends GetxController {
  final UserRepository _userRepo = Get.find();

  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  final _notifications = <Map<String, dynamic>>[].obs;
  List<Map<String, dynamic>> get notifications => _notifications;

  int get unreadCount => _notifications.where((n) => n['is_read'] != true).length;

  @override
  void onInit() {
    super.onInit();
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    _isLoading.value = true;
    try {
      _notifications.value = await _userRepo.getNotifications();
    } catch (e) {
      // Handle error
    } finally {
      _isLoading.value = false;
    }
  }

  void onNotificationTap(Map<String, dynamic> notification) {
    // Mark as read
    final id = notification['id'];
    _userRepo.markNotificationRead(id.toString());

    // Update local state
    final index = _notifications.indexWhere((n) => n['id'] == id);
    if (index != -1) {
      _notifications[index] = {...notification, 'is_read': true};
    }

    // Navigate based on type
    final type = notification['type'] as String?;
    final referenceId = notification['reference_id'] as String?;

    switch (type) {
      case 'session':
        if (referenceId != null) {
          Get.toNamed(Routes.sessionDetailsPath(referenceId));
        }
        break;
      case 'course':
        if (referenceId != null) {
          Get.toNamed(Routes.courseDetailsPath(referenceId));
        }
        break;
      case 'achievement':
        Get.toNamed(Routes.achievements);
        break;
      case 'wallet':
        Get.toNamed(Routes.wallet);
        break;
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _userRepo.markAllNotificationsRead();
      _notifications.value = _notifications.map((n) => {...n, 'is_read': true}).toList();
      Get.snackbar('done'.tr, 'all_notifications_marked_read'.tr);
    } catch (e) {
      Get.snackbar('error'.tr, 'failed_update_notifications'.tr);
    }
  }

  void removeNotification(String id) {
    _notifications.removeWhere((n) => n['id'] == id);
  }

  void clearAll() {
    Get.dialog(
      AlertDialog(
        title: Text('clear_all_notifications'.tr),
        content: Text('confirm_clear_notifications'.tr),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('cancel'.tr),
          ),
          TextButton(
            onPressed: () {
              _notifications.clear();
              Get.back();
              Get.snackbar('done'.tr, 'all_notifications_cleared'.tr);
            },
            child: Text('clear'.tr, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

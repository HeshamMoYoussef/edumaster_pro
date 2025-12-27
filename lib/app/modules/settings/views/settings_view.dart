import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/color_constants.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/services/session_reminder_service.dart';
import '../controllers/settings_controller.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('settings'.tr), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.paddingM),
        children: [
          _buildSection('theme'.tr, [
            Obx(() => ListTile(
              leading: Icon(controller.themeController.themeModeIcon),
              title: Text('theme'.tr),
              subtitle: Text(controller.themeController.themeModeName),
              onTap: () => controller.themeController.toggleTheme(),
            )),
          ]),
          _buildSection('language'.tr, [
            Obx(() => ListTile(
              leading: Text(controller.localeController.localeFlag, style: const TextStyle(fontSize: 24)),
              title: Text('language'.tr),
              subtitle: Text(controller.localeController.localeName),
              onTap: () => controller.localeController.toggleLocale(),
            )),
          ]),
          _buildSection('profile'.tr, [
            ListTile(leading: const Icon(Icons.lock), title: Text('reset_password'.tr), onTap: () {}),
            ListTile(
              leading: const Icon(Icons.notifications),
              title: Text('notification_settings'.tr),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showNotificationSettings(context),
            ),
            ListTile(leading: const Icon(Icons.privacy_tip), title: Text('privacy'.tr), onTap: () {}),
          ]),
          _buildSection('about'.tr, [
            ListTile(leading: const Icon(Icons.info), title: Text('about_app'.tr), subtitle: Text('${'version'.tr} 1.0.0')),
            ListTile(leading: const Icon(Icons.article), title: Text('terms_and_conditions'.tr), onTap: () {}),
            ListTile(leading: const Icon(Icons.shield), title: Text('privacy_policy'.tr), onTap: () {}),
          ]),
          // Logout
          Card(
            child: ListTile(
              leading: Icon(Icons.logout, color: AppColors.error),
              title: Text('logout'.tr, style: TextStyle(color: AppColors.error)),
              onTap: controller.logout,
            ),
          ),
          const SizedBox(height: AppConstants.paddingXL),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(AppConstants.paddingM),
          child: Text(title, style: TextStyle(fontSize: 14, color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
        ),
        Card(child: Column(children: children)),
        const SizedBox(height: AppConstants.paddingM),
      ],
    );
  }

  void _showNotificationSettings(BuildContext context) {
    final reminderService = SessionReminderService.to;
    final settings = reminderService.reminderSettings.obs;

    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(AppConstants.paddingL),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'session_reminders'.tr,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              const Divider(),

              // Enable/Disable reminders
              Obx(() => SwitchListTile(
                title: Text('push_notifications'.tr),
                subtitle: Text('session_reminders'.tr),
                value: settings.value.enabled,
                onChanged: (value) {
                  settings.value = settings.value.copyWith(enabled: value);
                  reminderService.saveSettings(settings.value);
                },
                secondary: Icon(
                  settings.value.enabled ? Icons.notifications_active : Icons.notifications_off,
                  color: settings.value.enabled ? AppColors.primary : AppColors.textSecondary,
                ),
              )),

              const SizedBox(height: 8),
              Text('${'select_time'.tr}:', style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),

              // Reminder 24 hours before
              Obx(() => CheckboxListTile(
                title: Text('reminder_24h'.tr),
                value: settings.value.remind24Hours,
                enabled: settings.value.enabled,
                onChanged: settings.value.enabled ? (value) {
                  settings.value = settings.value.copyWith(remind24Hours: value);
                  reminderService.saveSettings(settings.value);
                } : null,
              )),

              // Reminder 1 hour before
              Obx(() => CheckboxListTile(
                title: Text('reminder_1h'.tr),
                value: settings.value.remind1Hour,
                enabled: settings.value.enabled,
                onChanged: settings.value.enabled ? (value) {
                  settings.value = settings.value.copyWith(remind1Hour: value);
                  reminderService.saveSettings(settings.value);
                } : null,
              )),

              // Reminder 15 minutes before
              Obx(() => CheckboxListTile(
                title: Text('reminder_15m'.tr),
                value: settings.value.remind15Minutes,
                enabled: settings.value.enabled,
                onChanged: settings.value.enabled ? (value) {
                  settings.value = settings.value.copyWith(remind15Minutes: value);
                  reminderService.saveSettings(settings.value);
                } : null,
              )),

              // Reminder 5 minutes before
              Obx(() => CheckboxListTile(
                title: Text('reminder_5m'.tr),
                value: settings.value.remind5Minutes,
                enabled: settings.value.enabled,
                onChanged: settings.value.enabled ? (value) {
                  settings.value = settings.value.copyWith(remind5Minutes: value);
                  reminderService.saveSettings(settings.value);
                } : null,
              )),

              // Reminder at session start
              Obx(() => CheckboxListTile(
                title: Text('reminder_start'.tr),
                value: settings.value.remindAtStart,
                enabled: settings.value.enabled,
                onChanged: settings.value.enabled ? (value) {
                  settings.value = settings.value.copyWith(remindAtStart: value);
                  reminderService.saveSettings(settings.value);
                } : null,
              )),

              const Divider(),

              // Check alarm permissions
              FutureBuilder<bool>(
                future: NotificationService.to.canScheduleExactAlarms(),
                builder: (context, snapshot) {
                  final canSchedule = snapshot.data ?? false;
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: canSchedule ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: canSchedule ? Colors.green : Colors.red,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          canSchedule ? Icons.check_circle : Icons.error,
                          color: canSchedule ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                canSchedule ? '${'success'.tr} ✓' : '${'warning'.tr}!',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: canSchedule ? Colors.green : Colors.red,
                                ),
                              ),
                              if (!canSchedule)
                                Text(
                                  'feature_not_available'.tr,
                                  style: const TextStyle(fontSize: 12),
                                ),
                            ],
                          ),
                        ),
                        if (!canSchedule && Platform.isAndroid)
                          TextButton(
                            onPressed: () async {
                              final granted = await NotificationService.to.requestPermissions();
                              if (granted) {
                                Get.snackbar(
                                  'done'.tr,
                                  'success'.tr,
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: Colors.green,
                                  colorText: Colors.white,
                                );
                              } else {
                                Get.snackbar(
                                  'warning'.tr,
                                  'try_again'.tr,
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: Colors.orange,
                                  colorText: Colors.white,
                                );
                              }
                            },
                            child: Text('confirm'.tr),
                          ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              // Test notifications buttons
              Text('${'test_notification'.tr}:', style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),

              // Immediate notification
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.notifications_active),
                  label: Text('test_notification'.tr),
                  onPressed: () async {
                    await NotificationService.to.testImmediateNotification();
                    Get.snackbar(
                      'done'.tr,
                      'success'.tr,
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  },
                ),
              ),

              const SizedBox(height: 8),

              // Scheduled notification (10 seconds)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.schedule),
                  label: Text('test_notification'.tr),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    await NotificationService.to.testQuickScheduledNotification();
                    Get.snackbar(
                      'done'.tr,
                      'success'.tr,
                      snackPosition: SnackPosition.BOTTOM,
                      duration: const Duration(seconds: 10),
                      backgroundColor: Colors.orange,
                      colorText: Colors.white,
                    );
                  },
                ),
              ),

              const SizedBox(height: 8),

              // Scheduled notification (30 seconds)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.schedule),
                  label: Text('test_notification'.tr),
                  onPressed: () async {
                    await NotificationService.to.testScheduledNotification();
                    Get.snackbar(
                      'done'.tr,
                      'success'.tr,
                      snackPosition: SnackPosition.BOTTOM,
                      duration: const Duration(seconds: 5),
                    );
                  },
                ),
              ),

              const SizedBox(height: 8),

              // Show pending notifications
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.list),
                  label: Text('notifications'.tr),
                  onPressed: () async {
                    final pending = await NotificationService.to.getPendingNotifications();
                    Get.snackbar(
                      'notifications'.tr,
                      '${pending.length}',
                      snackPosition: SnackPosition.BOTTOM,
                      duration: const Duration(seconds: 5),
                    );
                    for (final n in pending) {
                      debugPrint('📋 Pending: ID=${n.id}, Title=${n.title}');
                    }
                  },
                ),
              ),

              const SizedBox(height: AppConstants.paddingL),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }
}

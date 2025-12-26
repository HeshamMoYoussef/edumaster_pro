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
      appBar: AppBar(title: const Text('الإعدادات'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.paddingM),
        children: [
          _buildSection('المظهر', [
            Obx(() => ListTile(
              leading: Icon(controller.themeController.themeModeIcon),
              title: const Text('الوضع'),
              subtitle: Text(controller.themeController.themeModeName),
              onTap: () => controller.themeController.toggleTheme(),
            )),
          ]),
          _buildSection('اللغة', [
            Obx(() => ListTile(
              leading: Text(controller.localeController.localeFlag, style: const TextStyle(fontSize: 24)),
              title: const Text('اللغة'),
              subtitle: Text(controller.localeController.localeName),
              onTap: () => controller.localeController.toggleLocale(),
            )),
          ]),
          _buildSection('الحساب', [
            ListTile(leading: const Icon(Icons.lock), title: const Text('تغيير كلمة المرور'), onTap: () {}),
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('إعدادات الإشعارات'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showNotificationSettings(context),
            ),
            ListTile(leading: const Icon(Icons.privacy_tip), title: const Text('الخصوصية'), onTap: () {}),
          ]),
          _buildSection('حول', [
            ListTile(leading: const Icon(Icons.info), title: const Text('عن التطبيق'), subtitle: const Text('الإصدار 1.0.0')),
            ListTile(leading: const Icon(Icons.article), title: const Text('الشروط والأحكام'), onTap: () {}),
            ListTile(leading: const Icon(Icons.shield), title: const Text('سياسة الخصوصية'), onTap: () {}),
          ]),
          // تسجيل الخروج
          Card(
            child: ListTile(
              leading: Icon(Icons.logout, color: AppColors.error),
              title: Text('تسجيل الخروج', style: TextStyle(color: AppColors.error)),
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
                  const Text(
                    'إعدادات تذكيرات الجلسات',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              const Divider(),

              // تفعيل/تعطيل التذكيرات
              Obx(() => SwitchListTile(
                title: const Text('تفعيل التذكيرات'),
                subtitle: const Text('استلام إشعارات قبل موعد الجلسة'),
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
              const Text('أوقات التذكير:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),

              // تذكير قبل 24 ساعة
              Obx(() => CheckboxListTile(
                title: const Text('قبل 24 ساعة'),
                value: settings.value.remind24Hours,
                enabled: settings.value.enabled,
                onChanged: settings.value.enabled ? (value) {
                  settings.value = settings.value.copyWith(remind24Hours: value);
                  reminderService.saveSettings(settings.value);
                } : null,
              )),

              // تذكير قبل ساعة
              Obx(() => CheckboxListTile(
                title: const Text('قبل ساعة'),
                value: settings.value.remind1Hour,
                enabled: settings.value.enabled,
                onChanged: settings.value.enabled ? (value) {
                  settings.value = settings.value.copyWith(remind1Hour: value);
                  reminderService.saveSettings(settings.value);
                } : null,
              )),

              // تذكير قبل 15 دقيقة
              Obx(() => CheckboxListTile(
                title: const Text('قبل 15 دقيقة'),
                value: settings.value.remind15Minutes,
                enabled: settings.value.enabled,
                onChanged: settings.value.enabled ? (value) {
                  settings.value = settings.value.copyWith(remind15Minutes: value);
                  reminderService.saveSettings(settings.value);
                } : null,
              )),

              // تذكير قبل 5 دقائق
              Obx(() => CheckboxListTile(
                title: const Text('قبل 5 دقائق'),
                value: settings.value.remind5Minutes,
                enabled: settings.value.enabled,
                onChanged: settings.value.enabled ? (value) {
                  settings.value = settings.value.copyWith(remind5Minutes: value);
                  reminderService.saveSettings(settings.value);
                } : null,
              )),

              // تذكير عند بدء الجلسة
              Obx(() => CheckboxListTile(
                title: const Text('عند بدء الجلسة'),
                value: settings.value.remindAtStart,
                enabled: settings.value.enabled,
                onChanged: settings.value.enabled ? (value) {
                  settings.value = settings.value.copyWith(remindAtStart: value);
                  reminderService.saveSettings(settings.value);
                } : null,
              )),

              const Divider(),

              // التحقق من صلاحية الإنذارات
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
                                canSchedule ? 'صلاحية الإنذارات مفعّلة ✓' : 'صلاحية الإنذارات غير مفعّلة!',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: canSchedule ? Colors.green : Colors.red,
                                ),
                              ),
                              if (!canSchedule)
                                const Text(
                                  'يجب تفعيلها من إعدادات الجهاز للإشعارات المجدولة',
                                  style: TextStyle(fontSize: 12),
                                ),
                            ],
                          ),
                        ),
                        if (!canSchedule && Platform.isAndroid)
                          TextButton(
                            onPressed: () async {
                              // طلب الصلاحية مباشرة
                              final granted = await NotificationService.to.requestPermissions();
                              if (granted) {
                                Get.snackbar(
                                  'تم',
                                  'تم تفعيل صلاحية الإنذارات',
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: Colors.green,
                                  colorText: Colors.white,
                                );
                              } else {
                                Get.snackbar(
                                  'تنبيه',
                                  'يرجى تفعيل صلاحية الإنذارات من إعدادات الجهاز',
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: Colors.orange,
                                  colorText: Colors.white,
                                );
                              }
                            },
                            child: const Text('تفعيل الصلاحية'),
                          ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              // أزرار اختبار الإشعارات
              const Text('اختبار الإشعارات:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),

              // إشعار فوري
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.notifications_active),
                  label: const Text('إشعار فوري'),
                  onPressed: () async {
                    await NotificationService.to.testImmediateNotification();
                    Get.snackbar(
                      'تم',
                      'تم إرسال إشعار فوري',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  },
                ),
              ),

              const SizedBox(height: 8),

              // إشعار مجدول بعد 10 ثواني
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.schedule),
                  label: const Text('إشعار مجدول (10 ثواني)'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    await NotificationService.to.testQuickScheduledNotification();
                    Get.snackbar(
                      'تم الجدولة',
                      'سيظهر الإشعار بعد 10 ثواني - انتظر!',
                      snackPosition: SnackPosition.BOTTOM,
                      duration: const Duration(seconds: 10),
                      backgroundColor: Colors.orange,
                      colorText: Colors.white,
                    );
                  },
                ),
              ),

              const SizedBox(height: 8),

              // إشعار مجدول بعد 30 ثانية
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.schedule),
                  label: const Text('إشعار مجدول (30 ثانية)'),
                  onPressed: () async {
                    await NotificationService.to.testScheduledNotification();
                    Get.snackbar(
                      'تم الجدولة',
                      'سيظهر الإشعار بعد 30 ثانية',
                      snackPosition: SnackPosition.BOTTOM,
                      duration: const Duration(seconds: 5),
                    );
                  },
                ),
              ),

              const SizedBox(height: 8),

              // عرض الإشعارات المعلقة
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.list),
                  label: const Text('عرض الإشعارات المعلقة'),
                  onPressed: () async {
                    final pending = await NotificationService.to.getPendingNotifications();
                    Get.snackbar(
                      'الإشعارات المعلقة',
                      'عدد الإشعارات المجدولة: ${pending.length}',
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

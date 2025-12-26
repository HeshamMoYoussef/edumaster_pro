import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../data/models/session_model.dart';
import 'notification_service.dart';

/// خدمة تذكيرات الجلسات
/// تقوم بجدولة تذكيرات قبل موعد الجلسة
class SessionReminderService extends GetxService {
  static SessionReminderService get to => Get.find();

  final _storage = GetStorage();

  /// مفاتيح التخزين
  static const String _reminderSettingsKey = 'session_reminder_settings';
  static const String _scheduledRemindersKey = 'scheduled_reminders';

  /// إعدادات التذكيرات الافتراضية
  final _reminderSettings = SessionReminderSettings().obs;
  SessionReminderSettings get reminderSettings => _reminderSettings.value;

  /// تهيئة الخدمة
  Future<SessionReminderService> init() async {
    _loadSettings();
    debugPrint('✅ [SessionReminder] Service initialized');
    return this;
  }

  /// تحميل الإعدادات المحفوظة
  void _loadSettings() {
    final savedSettings = _storage.read(_reminderSettingsKey);
    if (savedSettings != null) {
      _reminderSettings.value = SessionReminderSettings.fromJson(savedSettings);
    }
  }

  /// حفظ الإعدادات
  Future<void> saveSettings(SessionReminderSettings settings) async {
    _reminderSettings.value = settings;
    await _storage.write(_reminderSettingsKey, settings.toJson());
    debugPrint('💾 [SessionReminder] Settings saved');
  }

  /// جدولة تذكيرات لجلسة جديدة
  Future<void> scheduleReminders(SessionModel session) async {
    if (!_reminderSettings.value.enabled) {
      debugPrint('⚠️ [SessionReminder] Reminders disabled');
      return;
    }

    final notifications = NotificationService.to;
    final sessionTime = session.scheduledAt;
    final sessionId = session.id;
    final teacherName = session.teacher?.fullName ?? 'المعلم';
    final subject = session.subject ?? 'جلسة تعليمية';

    // إلغاء أي تذكيرات سابقة لهذه الجلسة
    await cancelReminders(sessionId);

    final scheduledIds = <int>[];

    // تذكير قبل 24 ساعة
    if (_reminderSettings.value.remind24Hours) {
      final time24h = sessionTime.subtract(const Duration(hours: 24));
      if (time24h.isAfter(DateTime.now())) {
        final id = _generateNotificationId(sessionId, 24);
        await notifications.scheduleNotification(
          id: id,
          title: '📅 تذكير بجلسة غداً',
          body: 'لديك جلسة "$subject" مع $teacherName غداً في الساعة ${_formatTime(sessionTime)}',
          scheduledTime: time24h,
          payload: 'session:$sessionId',
        );
        scheduledIds.add(id);
      }
    }

    // تذكير قبل ساعة
    if (_reminderSettings.value.remind1Hour) {
      final time1h = sessionTime.subtract(const Duration(hours: 1));
      if (time1h.isAfter(DateTime.now())) {
        final id = _generateNotificationId(sessionId, 60);
        await notifications.scheduleNotification(
          id: id,
          title: '⏰ جلستك بعد ساعة',
          body: 'جلسة "$subject" مع $teacherName ستبدأ بعد ساعة واحدة',
          scheduledTime: time1h,
          payload: 'session:$sessionId',
        );
        scheduledIds.add(id);
      }
    }

    // تذكير قبل 15 دقيقة
    if (_reminderSettings.value.remind15Minutes) {
      final time15m = sessionTime.subtract(const Duration(minutes: 15));
      if (time15m.isAfter(DateTime.now())) {
        final id = _generateNotificationId(sessionId, 15);
        await notifications.scheduleNotification(
          id: id,
          title: '🔔 جلستك بعد 15 دقيقة',
          body: 'استعد! جلسة "$subject" مع $teacherName ستبدأ قريباً',
          scheduledTime: time15m,
          payload: 'session:$sessionId',
        );
        scheduledIds.add(id);
      }
    }

    // تذكير قبل 5 دقائق
    if (_reminderSettings.value.remind5Minutes) {
      final time5m = sessionTime.subtract(const Duration(minutes: 5));
      if (time5m.isAfter(DateTime.now())) {
        final id = _generateNotificationId(sessionId, 5);
        await notifications.scheduleNotification(
          id: id,
          title: '🚀 حان وقت الانضمام!',
          body: 'جلسة "$subject" مع $teacherName على وشك البدء. انضم الآن!',
          scheduledTime: time5m,
          payload: 'session:$sessionId',
        );
        scheduledIds.add(id);
      }
    }

    // إشعار عند بدء الجلسة
    if (_reminderSettings.value.remindAtStart) {
      if (sessionTime.isAfter(DateTime.now())) {
        final id = _generateNotificationId(sessionId, 0);
        await notifications.scheduleNotification(
          id: id,
          title: '🎓 الجلسة بدأت!',
          body: 'جلسة "$subject" مع $teacherName بدأت الآن. انضم فوراً!',
          scheduledTime: sessionTime,
          payload: 'session:$sessionId',
        );
        scheduledIds.add(id);
      }
    }

    // حفظ معرفات التذكيرات المجدولة
    await _saveScheduledReminders(sessionId, scheduledIds);

    debugPrint('✅ [SessionReminder] Scheduled ${scheduledIds.length} reminders for session $sessionId');
  }

  /// إلغاء تذكيرات جلسة معينة
  Future<void> cancelReminders(String sessionId) async {
    final scheduledReminders = _getScheduledReminders();
    final ids = scheduledReminders[sessionId] as List<dynamic>?;

    if (ids != null) {
      for (final id in ids) {
        await NotificationService.to.cancelNotification(id as int);
      }
      scheduledReminders.remove(sessionId);
      await _storage.write(_scheduledRemindersKey, scheduledReminders);
      debugPrint('❌ [SessionReminder] Cancelled reminders for session $sessionId');
    }
  }

  /// إلغاء جميع التذكيرات
  Future<void> cancelAllReminders() async {
    await NotificationService.to.cancelAllNotifications();
    await _storage.remove(_scheduledRemindersKey);
    debugPrint('❌ [SessionReminder] Cancelled all reminders');
  }

  /// إعادة جدولة تذكيرات لجلسة (بعد تغيير الموعد)
  Future<void> rescheduleReminders(SessionModel session) async {
    await cancelReminders(session.id);
    await scheduleReminders(session);
    debugPrint('🔄 [SessionReminder] Rescheduled reminders for session ${session.id}');
  }

  /// جدولة تذكيرات لعدة جلسات
  Future<void> scheduleRemindersForSessions(List<SessionModel> sessions) async {
    for (final session in sessions) {
      if (session.status == SessionStatus.confirmed &&
          session.scheduledAt.isAfter(DateTime.now())) {
        await scheduleReminders(session);
      }
    }
  }

  /// عرض إشعار اختباري
  Future<void> showTestNotification() async {
    await NotificationService.to.showNotification(
      id: 999999,
      title: '🔔 إشعار تجريبي',
      body: 'هذا إشعار تجريبي للتحقق من عمل الإشعارات بشكل صحيح',
      isSessionReminder: true,
    );
  }

  /// توليد معرف إشعار فريد
  int _generateNotificationId(String sessionId, int minutesBefore) {
    // استخدام hash من معرف الجلسة + الوقت
    return (sessionId.hashCode + minutesBefore).abs() % 2147483647;
  }

  /// تنسيق الوقت
  String _formatTime(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : time.hour;
    final period = time.hour >= 12 ? 'م' : 'ص';
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }

  /// الحصول على التذكيرات المجدولة
  Map<String, dynamic> _getScheduledReminders() {
    return _storage.read<Map<String, dynamic>>(_scheduledRemindersKey) ?? {};
  }

  /// حفظ التذكيرات المجدولة
  Future<void> _saveScheduledReminders(String sessionId, List<int> ids) async {
    final scheduledReminders = _getScheduledReminders();
    scheduledReminders[sessionId] = ids;
    await _storage.write(_scheduledRemindersKey, scheduledReminders);
  }
}

/// إعدادات تذكيرات الجلسات
class SessionReminderSettings {
  final bool enabled;
  final bool remind24Hours;
  final bool remind1Hour;
  final bool remind15Minutes;
  final bool remind5Minutes;
  final bool remindAtStart;
  final bool soundEnabled;
  final bool vibrationEnabled;

  const SessionReminderSettings({
    this.enabled = true,
    this.remind24Hours = false,
    this.remind1Hour = true,
    this.remind15Minutes = true,
    this.remind5Minutes = true,
    this.remindAtStart = true,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
  });

  SessionReminderSettings copyWith({
    bool? enabled,
    bool? remind24Hours,
    bool? remind1Hour,
    bool? remind15Minutes,
    bool? remind5Minutes,
    bool? remindAtStart,
    bool? soundEnabled,
    bool? vibrationEnabled,
  }) {
    return SessionReminderSettings(
      enabled: enabled ?? this.enabled,
      remind24Hours: remind24Hours ?? this.remind24Hours,
      remind1Hour: remind1Hour ?? this.remind1Hour,
      remind15Minutes: remind15Minutes ?? this.remind15Minutes,
      remind5Minutes: remind5Minutes ?? this.remind5Minutes,
      remindAtStart: remindAtStart ?? this.remindAtStart,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'remind24Hours': remind24Hours,
      'remind1Hour': remind1Hour,
      'remind15Minutes': remind15Minutes,
      'remind5Minutes': remind5Minutes,
      'remindAtStart': remindAtStart,
      'soundEnabled': soundEnabled,
      'vibrationEnabled': vibrationEnabled,
    };
  }

  factory SessionReminderSettings.fromJson(Map<String, dynamic> json) {
    return SessionReminderSettings(
      enabled: json['enabled'] ?? true,
      remind24Hours: json['remind24Hours'] ?? false,
      remind1Hour: json['remind1Hour'] ?? true,
      remind15Minutes: json['remind15Minutes'] ?? true,
      remind5Minutes: json['remind5Minutes'] ?? true,
      remindAtStart: json['remindAtStart'] ?? true,
      soundEnabled: json['soundEnabled'] ?? true,
      vibrationEnabled: json['vibrationEnabled'] ?? true,
    );
  }
}

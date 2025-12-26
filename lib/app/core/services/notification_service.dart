import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../../routes/app_routes.dart';

/// خدمة الإشعارات المحلية
class NotificationService extends GetxService {
  static NotificationService get to => Get.find();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  /// هل تم تهيئة الخدمة
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  /// قناة الإشعارات للجلسات
  static const String sessionChannelId = 'session_reminders';
  static const String sessionChannelName = 'تذكيرات الجلسات';
  static const String sessionChannelDesc = 'إشعارات تذكير بمواعيد الجلسات';

  /// قناة الإشعارات العامة
  static const String generalChannelId = 'general';
  static const String generalChannelName = 'إشعارات عامة';
  static const String generalChannelDesc = 'الإشعارات العامة للتطبيق';

  /// الحصول على المنطقة الزمنية من الجهاز باستخدام intl
  String _getDeviceTimezone() {
    final now = DateTime.now();
    final timeZoneName = now.timeZoneName; // مثل: EET, AST, GST
    final offsetHours = now.timeZoneOffset.inHours;
    final offsetMinutes = now.timeZoneOffset.inMinutes % 60;

    debugPrint('📍 [Notifications] Device timezone name: $timeZoneName');
    debugPrint('📍 [Notifications] Device offset: ${offsetHours}h ${offsetMinutes}m');
    debugPrint('📍 [Notifications] System locale: ${Intl.systemLocale}');
    debugPrint('📍 [Notifications] Default locale: ${Intl.defaultLocale}');

    // تحديد المنطقة الزمنية بناءً على الاختصار و offset
    // EET = Eastern European Time (مصر)
    // AST = Arabia Standard Time (السعودية)
    // GST = Gulf Standard Time (الإمارات)

    if (timeZoneName == 'EET' || timeZoneName == 'EEST') {
      return 'Africa/Cairo';
    } else if (timeZoneName == 'AST' || timeZoneName == '+03') {
      return 'Asia/Riyadh';
    } else if (timeZoneName == 'GST' || timeZoneName == '+04') {
      return 'Asia/Dubai';
    }

    // استخدام offset كبديل
    switch (offsetHours) {
      case 2:
        return 'Africa/Cairo';
      case 3:
        return 'Asia/Riyadh';
      case 4:
        return 'Asia/Dubai';
      case 5:
        return 'Asia/Karachi';
      case 1:
        return 'Europe/Paris';
      case 0:
        return 'UTC';
      case -5:
        return 'America/New_York';
      case -8:
        return 'America/Los_Angeles';
      default:
        // إنشاء منطقة زمنية مخصصة بناءً على offset
        debugPrint('📍 [Notifications] Using UTC offset: $offsetHours');
        return 'UTC';
    }
  }

  /// تهيئة الخدمة
  Future<NotificationService> init() async {
    if (_isInitialized) return this;

    // تهيئة المناطق الزمنية
    tz.initializeTimeZones();

    // تحديد المنطقة الزمنية المحلية من الجهاز
    try {
      final String timezoneName = _getDeviceTimezone();
      debugPrint('📍 [Notifications] Selected timezone: $timezoneName');
      tz.setLocalLocation(tz.getLocation(timezoneName));
      debugPrint('✅ [Notifications] Timezone set to: ${tz.local.name}');
    } catch (e) {
      // استخدام UTC كبديل
      debugPrint('⚠️ [Notifications] Error setting timezone: $e');
      debugPrint('⚠️ [Notifications] Using UTC timezone as fallback');
      tz.setLocalLocation(tz.UTC);
    }

    // إعدادات Android
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // إعدادات iOS
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // تهيئة الإشعارات
    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // إنشاء قنوات Android
    if (Platform.isAndroid) {
      await _createNotificationChannels();
    }

    _isInitialized = true;
    debugPrint('✅ [Notifications] Service initialized');

    // طباعة معلومات الجهاز
    printDeviceInfo();

    return this;
  }

  /// إنشاء قنوات الإشعارات لـ Android
  Future<void> _createNotificationChannels() async {
    final androidPlugin =
        _notifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      // قناة تذكيرات الجلسات (أولوية عالية)
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          sessionChannelId,
          sessionChannelName,
          description: sessionChannelDesc,
          importance: Importance.high,
          playSound: true,
          enableVibration: true,
          enableLights: true,
          ledColor: Colors.blue,
        ),
      );

      // قناة الإشعارات العامة
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          generalChannelId,
          generalChannelName,
          description: generalChannelDesc,
          importance: Importance.defaultImportance,
        ),
      );
    }
  }

  /// طلب صلاحيات الإشعارات
  Future<bool> requestPermissions() async {
    if (Platform.isAndroid) {
      final androidPlugin =
          _notifications.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidPlugin == null) return false;

      // طلب صلاحية الإشعارات
      final notificationGranted =
          await androidPlugin.requestNotificationsPermission();
      debugPrint('🔔 [Notifications] Notification permission: $notificationGranted');

      // التحقق من صلاحية الإنذارات الدقيقة
      final canScheduleExact = await androidPlugin.canScheduleExactNotifications();
      debugPrint('🔔 [Notifications] Can schedule exact alarms: $canScheduleExact');

      if (canScheduleExact != true) {
        // طلب صلاحية الإنذارات الدقيقة
        final exactAlarmGranted = await androidPlugin.requestExactAlarmsPermission();
        debugPrint('🔔 [Notifications] Exact alarm permission requested: $exactAlarmGranted');
      }

      // التحقق مرة أخرى
      final finalCheck = await androidPlugin.canScheduleExactNotifications();
      debugPrint('🔔 [Notifications] Final exact alarm check: $finalCheck');

      return (notificationGranted ?? false) && (finalCheck ?? false);
    } else if (Platform.isIOS) {
      final iosPlugin =
          _notifications.resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();
      final granted = await iosPlugin?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }
    return false;
  }

  /// التحقق من إمكانية جدولة الإشعارات
  Future<bool> canScheduleExactAlarms() async {
    if (Platform.isAndroid) {
      final androidPlugin =
          _notifications.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      return await androidPlugin?.canScheduleExactNotifications() ?? false;
    }
    return true;
  }

  /// التعامل مع الضغط على الإشعار
  void _onNotificationTap(NotificationResponse response) {
    final payload = response.payload;
    debugPrint('🔔 [Notifications] Tapped: $payload');

    if (payload != null && payload.startsWith('session:')) {
      final sessionId = payload.replaceFirst('session:', '');
      Get.toNamed(Routes.liveSessionPath(sessionId));
    }
  }

  /// عرض إشعار فوري
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    bool isSessionReminder = false,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      isSessionReminder ? sessionChannelId : generalChannelId,
      isSessionReminder ? sessionChannelName : generalChannelName,
      channelDescription:
          isSessionReminder ? sessionChannelDesc : generalChannelDesc,
      importance: isSessionReminder ? Importance.high : Importance.defaultImportance,
      priority: isSessionReminder ? Priority.high : Priority.defaultPriority,
      icon: '@mipmap/ic_launcher',
      largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      styleInformation: BigTextStyleInformation(body),
      category: isSessionReminder ? AndroidNotificationCategory.reminder : null,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(id, title, body, details, payload: payload);
    debugPrint('🔔 [Notifications] Shown: $title');
  }

  /// جدولة إشعار في وقت محدد
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
    bool isSessionReminder = true,
  }) async {
    final now = DateTime.now();

    // تحقق أن الوقت في المستقبل
    if (scheduledTime.isBefore(now)) {
      debugPrint('⚠️ [Notifications] Cannot schedule in the past: $scheduledTime (now: $now)');
      return;
    }

    // حساب الفرق
    final difference = scheduledTime.difference(now);
    debugPrint('📅 [Notifications] Scheduling notification in ${difference.inSeconds} seconds');

    final androidDetails = AndroidNotificationDetails(
      isSessionReminder ? sessionChannelId : generalChannelId,
      isSessionReminder ? sessionChannelName : generalChannelName,
      channelDescription:
          isSessionReminder ? sessionChannelDesc : generalChannelDesc,
      importance: Importance.max,
      priority: Priority.max,
      icon: '@mipmap/ic_launcher',
      largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      styleInformation: BigTextStyleInformation(body),
      category: AndroidNotificationCategory.reminder,
      fullScreenIntent: true,
      playSound: true,
      enableVibration: true,
      visibility: NotificationVisibility.public,
      autoCancel: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // استخدام TZDateTime.now().add() لضمان التوافق الصحيح
    final tzNow = tz.TZDateTime.now(tz.local);
    final tzScheduledTime = tzNow.add(difference);

    debugPrint('🕐 [Notifications] Now (TZ): $tzNow');
    debugPrint('🕐 [Notifications] Scheduled (TZ): $tzScheduledTime');
    debugPrint('🕐 [Notifications] Local timezone: ${tz.local.name}');

    try {
      await _notifications.zonedSchedule(
        id,
        title,
        body,
        tzScheduledTime,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: payload,
      );

      debugPrint('✅ [Notifications] Scheduled successfully: $title (ID: $id)');

      // التحقق من الإشعارات المعلقة
      final pending = await _notifications.pendingNotificationRequests();
      debugPrint('📋 [Notifications] Pending notifications count: ${pending.length}');
      for (final p in pending) {
        debugPrint('   📌 ID: ${p.id}, Title: ${p.title}');
      }
    } catch (e, stack) {
      debugPrint('❌ [Notifications] Failed to schedule: $e');
      debugPrint('❌ [Notifications] Stack: $stack');
    }
  }

  /// إلغاء إشعار محدد
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
    debugPrint('❌ [Notifications] Cancelled: $id');
  }

  /// إلغاء جميع الإشعارات
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
    debugPrint('❌ [Notifications] Cancelled all');
  }

  /// الحصول على الإشعارات المعلقة
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  /// اختبار الإشعار الفوري
  Future<void> testImmediateNotification() async {
    debugPrint('🧪 [Notifications] Testing immediate notification...');
    await showNotification(
      id: 88888,
      title: '🔔 اختبار إشعار فوري',
      body: 'هذا إشعار فوري للتحقق من عمل النظام',
      isSessionReminder: true,
    );
  }

  /// اختبار الإشعار المجدول (بعد 30 ثانية)
  Future<void> testScheduledNotification() async {
    final scheduledTime = DateTime.now().add(const Duration(seconds: 30));
    debugPrint('🧪 [Notifications] Testing scheduled notification for: $scheduledTime');

    await scheduleNotification(
      id: 99999,
      title: '⏰ اختبار إشعار مجدول',
      body: 'هذا إشعار مجدول بعد 30 ثانية للتحقق من عمل الجدولة',
      scheduledTime: scheduledTime,
      isSessionReminder: true,
    );

    debugPrint('🧪 [Notifications] Scheduled test notification. Wait 30 seconds...');
  }

  /// اختبار إشعار مجدول بعد 10 ثواني فقط (للاختبار السريع)
  Future<void> testQuickScheduledNotification() async {
    // إلغاء أي إشعار سابق بنفس ID
    await cancelNotification(77777);

    final now = DateTime.now();
    debugPrint('🧪 [Notifications] Current time: $now');

    // جدولة بعد 10 ثواني
    final tzNow = tz.TZDateTime.now(tz.local);
    final tzScheduled = tzNow.add(const Duration(seconds: 10));

    debugPrint('🧪 [Notifications] TZ Now: $tzNow');
    debugPrint('🧪 [Notifications] TZ Scheduled: $tzScheduled');

    final androidDetails = const AndroidNotificationDetails(
      sessionChannelId,
      sessionChannelName,
      channelDescription: sessionChannelDesc,
      importance: Importance.max,
      priority: Priority.max,
      icon: '@mipmap/ic_launcher',
      playSound: true,
      enableVibration: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    try {
      await _notifications.zonedSchedule(
        77777,
        '🔔 إشعار مجدول - 10 ثواني',
        'هذا إشعار اختباري تم جدولته بعد 10 ثواني',
        tzScheduled,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
      debugPrint('✅ [Notifications] Quick test scheduled successfully!');

      final pending = await _notifications.pendingNotificationRequests();
      debugPrint('📋 [Notifications] Total pending: ${pending.length}');
    } catch (e, stack) {
      debugPrint('❌ [Notifications] Quick test failed: $e');
      debugPrint('Stack: $stack');
    }
  }

  /// الحصول على معلومات الجهاز الكاملة (الموقع والوقت واللغة)
  Map<String, dynamic> getDeviceInfo() {
    final now = DateTime.now();
    final locale = Intl.getCurrentLocale();

    return {
      'timezone': now.timeZoneName,
      'timezoneOffset': '${now.timeZoneOffset.inHours}:${(now.timeZoneOffset.inMinutes % 60).abs().toString().padLeft(2, '0')}',
      'ianaTimezone': tz.local.name,
      'locale': locale,
      'systemLocale': Intl.systemLocale,
      'defaultLocale': Intl.defaultLocale,
      'currentDate': DateFormat.yMMMMd(locale).format(now),
      'currentTime': DateFormat.jms(locale).format(now),
      'dayOfWeek': DateFormat.EEEE(locale).format(now),
      'platform': Platform.operatingSystem,
      'platformVersion': Platform.operatingSystemVersion,
    };
  }

  /// طباعة معلومات الجهاز للتصحيح
  void printDeviceInfo() {
    final info = getDeviceInfo();
    debugPrint('═══════════════════════════════════════');
    debugPrint('📱 معلومات الجهاز:');
    debugPrint('   المنطقة الزمنية: ${info['timezone']}');
    debugPrint('   IANA Timezone: ${info['ianaTimezone']}');
    debugPrint('   Offset: ${info['timezoneOffset']}');
    debugPrint('   اللغة: ${info['locale']}');
    debugPrint('   التاريخ: ${info['currentDate']}');
    debugPrint('   الوقت: ${info['currentTime']}');
    debugPrint('   اليوم: ${info['dayOfWeek']}');
    debugPrint('   النظام: ${info['platform']} ${info['platformVersion']}');
    debugPrint('═══════════════════════════════════════');
  }
}

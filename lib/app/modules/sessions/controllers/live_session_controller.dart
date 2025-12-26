/// ============================================================================
/// متحكم الجلسة المباشرة (Live Session Controller)
/// ============================================================================
///
/// يدير جميع جوانب الجلسة المباشرة بما في ذلك:
/// - الاتصال بـ WebRTC للفيديو المضمن داخل التطبيق
/// - التحكم في الكاميرا والميكروفون
/// - مشاركة الشاشة
/// - السبورة التفاعلية
/// - الدردشة النصية
/// - إدارة المشاركين
///
/// TODO: للإنتاج:
/// - إضافة Signaling Server للاتصال بين المشاركين
/// - إضافة التسجيل السحابي
/// - إضافة الترجمة التلقائية
/// - إضافة رفع اليد للطلاب
/// - إضافة غرف جانبية (Breakout Rooms)
///
/// ============================================================================

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get/get.dart';

import '../../../core/services/webrtc_service.dart';
import '../../../data/models/session_model.dart';
import '../../../data/repositories/session_repository.dart';
import '../views/live_session_view.dart';

/// أدوات الرسم المتاحة على السبورة
enum DrawingTool {
  pen,        // قلم عادي
  brush,      // فرشاة
  highlighter,// هايلايت
  eraser,     // ممحاة
  rectangle,  // مربع
  circle,     // دائرة
  line,       // خط
  arrow,      // سهم
  text,       // نص
}

/// متحكم الجلسة المباشرة - يستخدم GetX للتحكم في الحالة
class LiveSessionController extends GetxController {
  // ========================================
  // المستودعات والخدمات
  // ========================================
  final SessionRepository _sessionRepo = Get.find();
  final WebRTCService _webrtcService = WebRTCService();

  /// للوصول إلى Local Video Renderer من الـ View
  RTCVideoRenderer get localRenderer => _webrtcService.localRenderer;

  /// للوصول إلى Remote Video Renderer من الـ View
  RTCVideoRenderer get remoteRenderer => _webrtcService.remoteRenderer;

  /// هل الكاميرا الحقيقية جاهزة؟
  final _isCameraReady = false.obs;
  bool get isCameraReady => _isCameraReady.value;

  // ========================================
  // معلومات الجلسة
  // ========================================

  /// معرف الجلسة الفريد
  final _sessionId = ''.obs;
  String get sessionId => _sessionId.value;

  /// عنوان الجلسة
  final _sessionTitle = 'جلسة تعليمية'.obs;
  String get sessionTitle => _sessionTitle.value;

  /// اسم المشارك الآخر (المعلم أو الطالب)
  final _remoteName = 'المشارك'.obs;
  String get remoteName => _remoteName.value;

  // ========================================
  // حالة الاتصال
  // ========================================

  /// هل يتم الاتصال حالياً؟
  final _isConnecting = true.obs;
  bool get isConnecting => _isConnecting.value;

  /// هل الاتصال ناجح؟
  final _isConnected = false.obs;
  bool get isConnected => _isConnected.value;

  /// رسالة حالة الاتصال للعرض
  final _connectionStatus = 'جاري الاتصال...'.obs;
  String get connectionStatus => _connectionStatus.value;

  // ========================================
  // مدة الجلسة
  // ========================================

  /// مدة الجلسة بالصيغة المقروءة (00:00)
  final _duration = '00:00'.obs;
  String get duration => _duration.value;

  /// مؤقت لتحديث المدة كل ثانية
  Timer? _durationTimer;

  /// عدد الثواني منذ بدء الجلسة
  int _seconds = 0;

  // ========================================
  // التحكم في الوسائط المحلية
  // ========================================

  /// هل الكاميرا المحلية مفعلة؟
  final _isLocalVideoEnabled = true.obs;
  bool get isLocalVideoEnabled => _isLocalVideoEnabled.value;

  /// هل الميكروفون المحلي مفعل؟
  final _isLocalAudioEnabled = true.obs;
  bool get isLocalAudioEnabled => _isLocalAudioEnabled.value;

  // ========================================
  // التحكم في الوسائط البعيدة
  // ========================================

  /// هل كاميرا المشارك الآخر مفعلة؟
  final _isRemoteVideoEnabled = true.obs;
  bool get isRemoteVideoEnabled => _isRemoteVideoEnabled.value;

  /// هل ميكروفون المشارك الآخر مفعل؟
  final _isRemoteAudioEnabled = true.obs;
  bool get isRemoteAudioEnabled => _isRemoteAudioEnabled.value;

  // ========================================
  // ميزات إضافية
  // ========================================

  /// هل يتم مشاركة الشاشة؟
  final _isScreenSharing = false.obs;
  bool get isScreenSharing => _isScreenSharing.value;

  /// هل يتم التسجيل؟
  /// TODO: للإنتاج - ربطها بخادم التسجيل
  final _isRecording = false.obs;
  bool get isRecording => _isRecording.value;

  /// هل السبورة ظاهرة؟
  final _isWhiteboardVisible = false.obs;
  bool get isWhiteboardVisible => _isWhiteboardVisible.value;

  /// هل نافذة الدردشة ظاهرة؟
  final _isChatVisible = false.obs;
  bool get isChatVisible => _isChatVisible.value;

  /// هل قائمة المشاركين ظاهرة؟
  final _isParticipantsVisible = false.obs;
  bool get isParticipantsVisible => _isParticipantsVisible.value;

  // ========================================
  // الدردشة
  // ========================================

  /// قائمة رسائل الدردشة
  final _chatMessages = <ChatMessage>[].obs;
  List<ChatMessage> get chatMessages => _chatMessages;

  /// متحكم حقل إدخال الرسالة
  final chatInputController = TextEditingController();

  /// عدد الرسائل غير المقروءة
  final _unreadMessages = 0.obs;
  int get unreadMessages => _unreadMessages.value;

  // ========================================
  // السبورة التفاعلية
  // ========================================

  /// خطوط الرسم على السبورة
  final _drawingStrokes = <DrawingStroke>[].obs;
  List<DrawingStroke> get drawingStrokes => _drawingStrokes;

  /// لون الرسم الحالي
  final _currentDrawingColor = Colors.black.obs;
  Color get currentDrawingColor => _currentDrawingColor.value;

  /// أداة الرسم الحالية
  final _currentDrawingTool = DrawingTool.pen.obs;
  DrawingTool get currentDrawingTool => _currentDrawingTool.value;

  /// سمك الخط الحالي
  final _currentStrokeWidth = 4.0.obs;
  double get currentStrokeWidth => _currentStrokeWidth.value;

  /// نقاط الرسم الحالية (قبل إنهاء الخط)
  List<Offset> _currentPoints = [];

  // ========================================
  // دورة حياة المتحكم
  // ========================================

  @override
  void onInit() {
    super.onInit();
    // الحصول على معرف الجلسة من المعلمات
    _sessionId.value = Get.parameters['id'] ?? '';
    _initSessionWithWebRTC(); // الكاميرا الحقيقية داخل التطبيق
  }

  /// تهيئة الجلسة (وضع المحاكاة للتطوير)
  Future<void> _initSession() async {
    // وضع المحاكاة للتطوير السريع
    _connectionStatus.value = 'جاري تحميل بيانات الجلسة...';
    await Future.delayed(const Duration(milliseconds: 500));

    _connectionStatus.value = 'جاري الاتصال بالخادم...';
    await Future.delayed(const Duration(milliseconds: 500));

    _connectionStatus.value = 'جاري الانضمام للغرفة...';
    await Future.delayed(const Duration(milliseconds: 500));

    _isConnecting.value = false;
    _isConnected.value = true;
    _sessionTitle.value = 'جلسة رياضيات - التفاضل والتكامل';
    _remoteName.value = 'أ. سارة أحمد';

    _startDurationTimer();

    _chatMessages.add(ChatMessage(
      senderName: 'النظام',
      text: 'مرحباً بك في الجلسة! 🎉',
      time: DateTime.now(),
      isMe: false,
    ));
  }

  /// تهيئة الجلسة مع WebRTC (الكاميرا الحقيقية داخل التطبيق)
  Future<void> _initSessionWithWebRTC() async {
    _connectionStatus.value = 'جاري تهيئة الكاميرا...';

    // تهيئة WebRTC callbacks
    _webrtcService.onLocalStreamReady = () {
      _isCameraReady.value = true;
      debugPrint('✅ [LiveSession] الكاميرا جاهزة');
    };

    _webrtcService.onError = (error) {
      Get.snackbar(
        'خطأ',
        error,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    };

    // تهيئة الـ renderers
    await _webrtcService.initialize();

    _connectionStatus.value = 'جاري تشغيل الكاميرا...';

    // بدء الكاميرا المحلية
    final success = await _webrtcService.startLocalCamera(
      enableVideo: true,
      enableAudio: true,
    );

    if (success) {
      _isConnecting.value = false;
      _isConnected.value = true;
      _sessionTitle.value = 'جلسة رياضيات - التفاضل والتكامل';
      _remoteName.value = 'أ. سارة أحمد';
      _isCameraReady.value = true;

      _startDurationTimer();

      _chatMessages.add(ChatMessage(
        senderName: 'النظام',
        text: 'مرحباً بك في الجلسة! الكاميرا تعمل الآن 📹',
        time: DateTime.now(),
        isMe: false,
      ));
    } else {
      // في حالة فشل الكاميرا، نكمل بدون فيديو
      _isConnecting.value = false;
      _isConnected.value = true;
      _sessionTitle.value = 'جلسة رياضيات - التفاضل والتكامل';
      _remoteName.value = 'أ. سارة أحمد';
      _isLocalVideoEnabled.value = false;

      _startDurationTimer();

      _chatMessages.add(ChatMessage(
        senderName: 'النظام',
        text: 'مرحباً بك! (الكاميرا غير متوفرة)',
        time: DateTime.now(),
        isMe: false,
      ));
    }
  }

  /// بدء مؤقت مدة الجلسة
  void _startDurationTimer() {
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _seconds++;
      final minutes = _seconds ~/ 60;
      final secs = _seconds % 60;
      _duration.value = '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    });
  }

  // ========================================
  // التحكم في الوسائط
  // ========================================

  /// تبديل حالة الميكروفون (كتم/تشغيل)
  void toggleMicrophone() {
    _webrtcService.toggleMicrophone();
    _isLocalAudioEnabled.value = _webrtcService.isMicEnabled;
  }

  /// تبديل حالة الكاميرا (إيقاف/تشغيل)
  void toggleCamera() {
    _webrtcService.toggleCamera();
    _isLocalVideoEnabled.value = _webrtcService.isCameraEnabled;
  }

  /// تبديل الكاميرا الأمامية/الخلفية
  Future<void> flipCamera() async {
    await _webrtcService.switchCamera();
    Get.snackbar(
      'تم',
      'تم تبديل الكاميرا',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.black54,
      colorText: Colors.white,
      duration: const Duration(seconds: 1),
    );
  }

  /// تبديل مشاركة الشاشة
  void toggleScreenShare() {
    _isScreenSharing.value = !_isScreenSharing.value;

    if (_isScreenSharing.value) {
      Get.snackbar(
        'مشاركة الشاشة',
        'تم بدء مشاركة الشاشة',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.black54,
        colorText: Colors.white,
      );

      // إعلام المشاركين
      _chatMessages.add(ChatMessage(
        senderName: 'النظام',
        text: '📱 بدأ مشاركة الشاشة',
        time: DateTime.now(),
        isMe: false,
      ));
    } else {
      _chatMessages.add(ChatMessage(
        senderName: 'النظام',
        text: '📱 انتهت مشاركة الشاشة',
        time: DateTime.now(),
        isMe: false,
      ));
    }
  }

  // ========================================
  // السبورة التفاعلية
  // ========================================

  /// إظهار/إخفاء السبورة
  void toggleWhiteboard() {
    _isWhiteboardVisible.value = !_isWhiteboardVisible.value;

    // إخفاء النوافذ الأخرى
    if (_isWhiteboardVisible.value) {
      _isChatVisible.value = false;
      _isParticipantsVisible.value = false;
    }
  }

  /// إضافة نقطة رسم جديدة
  ///
  /// [point] موقع النقطة على السبورة
  void addDrawingPoint(Offset point) {
    _currentPoints.add(point);

    // حساب السُمك حسب الأداة
    double strokeWidth = _currentStrokeWidth.value;
    Color strokeColor = _currentDrawingColor.value;

    // تعديلات حسب نوع الأداة
    switch (_currentDrawingTool.value) {
      case DrawingTool.brush:
        strokeWidth = _currentStrokeWidth.value * 2; // فرشاة أعرض
        break;
      case DrawingTool.highlighter:
        strokeWidth = _currentStrokeWidth.value * 3; // هايلايت عريض
        strokeColor = strokeColor.withValues(alpha: 0.4); // شفاف
        break;
      case DrawingTool.eraser:
        strokeColor = Colors.white;
        strokeWidth = 25; // ممحاة كبيرة
        break;
      default:
        break;
    }

    if (_drawingStrokes.isNotEmpty && _currentPoints.length > 1) {
      // تحديث آخر خط
      _drawingStrokes.last = DrawingStroke(
        points: List.from(_currentPoints),
        color: strokeColor,
        width: strokeWidth,
        tool: _currentDrawingTool.value,
      );
    } else {
      // إضافة خط جديد
      _drawingStrokes.add(DrawingStroke(
        points: List.from(_currentPoints),
        color: strokeColor,
        width: strokeWidth,
        tool: _currentDrawingTool.value,
      ));
    }
  }

  /// إنهاء خط الرسم الحالي
  void endDrawingStroke() {
    _currentPoints = [];
  }

  /// تغيير لون الرسم
  void setDrawingColor(Color color) {
    _currentDrawingColor.value = color;
  }

  /// تغيير أداة الرسم
  void setDrawingTool(DrawingTool tool) {
    _currentDrawingTool.value = tool;

    // إذا اختار الممحاة، غير اللون للأبيض
    if (tool == DrawingTool.eraser) {
      _currentDrawingColor.value = Colors.white;
      _currentStrokeWidth.value = 20; // ممحاة كبيرة
    }
  }

  /// تغيير سمك الخط
  void setStrokeWidth(double width) {
    _currentStrokeWidth.value = width;
  }

  /// التراجع عن آخر رسم
  void undoDrawing() {
    if (_drawingStrokes.isNotEmpty) {
      _drawingStrokes.removeLast();
    }
  }

  /// مسح السبورة بالكامل
  void clearWhiteboard() {
    _drawingStrokes.clear();
  }

  // ========================================
  // الدردشة
  // ========================================

  /// إظهار/إخفاء نافذة الدردشة
  void toggleChat() {
    _isChatVisible.value = !_isChatVisible.value;

    if (_isChatVisible.value) {
      // إعادة تعيين عداد الرسائل غير المقروءة
      _unreadMessages.value = 0;

      // إخفاء النوافذ الأخرى
      _isParticipantsVisible.value = false;
      _isWhiteboardVisible.value = false;
    }
  }

  /// إظهار/إخفاء قائمة المشاركين
  void toggleParticipants() {
    _isParticipantsVisible.value = !_isParticipantsVisible.value;

    if (_isParticipantsVisible.value) {
      _isChatVisible.value = false;
      _isWhiteboardVisible.value = false;
    }
  }

  /// إرسال رسالة في الدردشة
  ///
  /// TODO: للإنتاج - إرسال الرسالة عبر WebSocket/Firebase
  void sendMessage() {
    final text = chatInputController.text.trim();
    if (text.isEmpty) return;

    // إضافة رسالة المستخدم
    _chatMessages.add(ChatMessage(
      senderName: 'أنت',
      text: text,
      time: DateTime.now(),
      isMe: true,
    ));

    chatInputController.clear();

    // ========================================
    // محاكاة رد من المشارك الآخر
    // في الإنتاج: الردود تأتي من الخادم
    // ========================================
    Future.delayed(const Duration(seconds: 2), () {
      _chatMessages.add(ChatMessage(
        senderName: remoteName,
        text: 'تم استلام رسالتك! ✓',
        time: DateTime.now(),
        isMe: false,
      ));

      // زيادة عداد الرسائل غير المقروءة إذا كانت الدردشة مغلقة
      if (!_isChatVisible.value) {
        _unreadMessages.value++;
      }
    });
  }

  // ========================================
  // إنهاء الجلسة
  // ========================================

  /// إنهاء الجلسة ومغادرة الغرفة
  Future<void> endSession() async {
    // إيقاف المؤقت
    _durationTimer?.cancel();

    try {
      // إيقاف الكاميرا المحلية
      await _webrtcService.stopLocalCamera();

      // تحديث حالة الجلسة
      await _sessionRepo.endSession(_sessionId.value);
    } catch (e) {
      debugPrint('❌ خطأ في إنهاء الجلسة: $e');
    }

    // العودة للصفحة السابقة
    Get.back();

    // عرض نافذة التقييم بعد قليل
    await Future.delayed(const Duration(milliseconds: 500));
    _showRatingDialog();
  }

  /// عرض نافذة تقييم الجلسة
  void _showRatingDialog() {
    final rating = 0.0.obs;
    final comment = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('تقييم الجلسة'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('كيف كانت تجربتك في الجلسة؟'),
            const SizedBox(height: 16),

            // ========================================
            // نجوم التقييم
            // ========================================
            Obx(() => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < rating.value ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 36,
                  ),
                  onPressed: () => rating.value = index + 1.0,
                );
              }),
            )),

            const SizedBox(height: 16),

            // ========================================
            // حقل التعليق
            // ========================================
            TextField(
              controller: comment,
              decoration: const InputDecoration(
                hintText: 'أضف تعليقاً (اختياري)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('لاحقاً'),
          ),
          ElevatedButton(
            onPressed: () {
              if (rating.value > 0) {
                // حفظ التقييم
                _sessionRepo.rateSession(
                  sessionId: _sessionId.value,
                  rating: rating.value,
                  comment: comment.text.isEmpty ? null : comment.text,
                );
                Get.back();
                Get.snackbar('شكراً', 'تم حفظ تقييمك بنجاح ⭐');
              } else {
                Get.snackbar('تنبيه', 'الرجاء اختيار تقييم');
              }
            },
            child: const Text('إرسال'),
          ),
        ],
      ),
    );
  }

  @override
  void onClose() {
    _durationTimer?.cancel();
    chatInputController.dispose();
    // تنظيف موارد WebRTC
    _webrtcService.dispose();
    super.onClose();
  }
}

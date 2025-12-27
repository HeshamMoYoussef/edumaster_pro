/// ============================================================================
/// Live Session Controller
/// ============================================================================
///
/// Manages all aspects of live sessions including:
/// - WebRTC connection for in-app video
/// - Camera and microphone controls
/// - Screen sharing
/// - Interactive whiteboard
/// - Text chat
/// - Participant management
///
/// TODO: For production:
/// - Add Signaling Server for participant communication
/// - Add cloud recording
/// - Add automatic translation
/// - Add hand raising for students
/// - Add Breakout Rooms
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

/// Available whiteboard drawing tools
enum DrawingTool {
  pen,        // Regular pen
  brush,      // Brush
  highlighter,// Highlighter
  eraser,     // Eraser
  rectangle,  // Rectangle
  circle,     // Circle
  line,       // Line
  arrow,      // Arrow
  text,       // Text
}

/// Live Session Controller - Uses GetX for state management
class LiveSessionController extends GetxController {
  // ========================================
  // Repositories and Services
  // ========================================
  final SessionRepository _sessionRepo = Get.find();
  final WebRTCService _webrtcService = WebRTCService();

  /// Access Local Video Renderer from View
  RTCVideoRenderer get localRenderer => _webrtcService.localRenderer;

  /// Access Remote Video Renderer from View
  RTCVideoRenderer get remoteRenderer => _webrtcService.remoteRenderer;

  /// Is the real camera ready?
  final _isCameraReady = false.obs;
  bool get isCameraReady => _isCameraReady.value;

  // ========================================
  // Session Information
  // ========================================

  /// Unique session ID
  final _sessionId = ''.obs;
  String get sessionId => _sessionId.value;

  /// Session title
  final _sessionTitle = ''.obs;
  String get sessionTitle => _sessionTitle.value.isEmpty ? 'educational_session'.tr : _sessionTitle.value;

  /// Other participant name (teacher or student)
  final _remoteName = ''.obs;
  String get remoteName => _remoteName.value.isEmpty ? 'participant'.tr : _remoteName.value;

  // ========================================
  // Connection State
  // ========================================

  /// Is currently connecting?
  final _isConnecting = true.obs;
  bool get isConnecting => _isConnecting.value;

  /// Is connection successful?
  final _isConnected = false.obs;
  bool get isConnected => _isConnected.value;

  /// Connection status message for display
  final _connectionStatus = ''.obs;
  String get connectionStatus => _connectionStatus.value.isEmpty ? 'connecting'.tr : _connectionStatus.value;

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

  /// Initialize session (mock mode for development)
  Future<void> _initSession() async {
    // Mock mode for rapid development
    _connectionStatus.value = 'loading_session'.tr;
    await Future.delayed(const Duration(milliseconds: 500));

    _connectionStatus.value = 'connecting_server'.tr;
    await Future.delayed(const Duration(milliseconds: 500));

    _connectionStatus.value = 'joining_room'.tr;
    await Future.delayed(const Duration(milliseconds: 500));

    _isConnecting.value = false;
    _isConnected.value = true;
    _sessionTitle.value = 'session_math'.tr;
    _remoteName.value = 'Sarah Ahmed';

    _startDurationTimer();

    _chatMessages.add(ChatMessage(
      senderName: 'system'.tr,
      text: 'welcome_session'.tr,
      time: DateTime.now(),
      isMe: false,
    ));
  }

  /// Initialize session with WebRTC (real camera in-app)
  Future<void> _initSessionWithWebRTC() async {
    _connectionStatus.value = 'initializing_camera'.tr;

    // Initialize WebRTC callbacks
    _webrtcService.onLocalStreamReady = () {
      _isCameraReady.value = true;
      debugPrint('✅ [LiveSession] Camera ready');
    };

    _webrtcService.onError = (error) {
      Get.snackbar(
        'error'.tr,
        error,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    };

    // Initialize renderers
    await _webrtcService.initialize();

    _connectionStatus.value = 'starting_camera'.tr;

    // Start local camera
    final success = await _webrtcService.startLocalCamera(
      enableVideo: true,
      enableAudio: true,
    );

    if (success) {
      _isConnecting.value = false;
      _isConnected.value = true;
      _sessionTitle.value = 'session_math'.tr;
      _remoteName.value = 'Sarah Ahmed';
      _isCameraReady.value = true;

      _startDurationTimer();

      _chatMessages.add(ChatMessage(
        senderName: 'system'.tr,
        text: 'welcome_camera_ready'.tr,
        time: DateTime.now(),
        isMe: false,
      ));
    } else {
      // If camera fails, continue without video
      _isConnecting.value = false;
      _isConnected.value = true;
      _sessionTitle.value = 'session_math'.tr;
      _remoteName.value = 'Sarah Ahmed';
      _isLocalVideoEnabled.value = false;

      _startDurationTimer();

      _chatMessages.add(ChatMessage(
        senderName: 'system'.tr,
        text: 'welcome_no_camera'.tr,
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

  /// Switch front/back camera
  Future<void> flipCamera() async {
    await _webrtcService.switchCamera();
    Get.snackbar(
      'done'.tr,
      'camera_switched'.tr,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.black54,
      colorText: Colors.white,
      duration: const Duration(seconds: 1),
    );
  }

  /// Toggle screen sharing
  void toggleScreenShare() {
    _isScreenSharing.value = !_isScreenSharing.value;

    if (_isScreenSharing.value) {
      Get.snackbar(
        'screen_sharing'.tr,
        'screen_share_on'.tr,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.black54,
        colorText: Colors.white,
      );

      // Notify participants
      _chatMessages.add(ChatMessage(
        senderName: 'system'.tr,
        text: 'screen_share_started'.tr,
        time: DateTime.now(),
        isMe: false,
      ));
    } else {
      _chatMessages.add(ChatMessage(
        senderName: 'system'.tr,
        text: 'screen_share_ended'.tr,
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

  /// Send chat message
  ///
  /// TODO: For production - send message via WebSocket/Firebase
  void sendMessage() {
    final text = chatInputController.text.trim();
    if (text.isEmpty) return;

    // Add user message
    _chatMessages.add(ChatMessage(
      senderName: 'you'.tr,
      text: text,
      time: DateTime.now(),
      isMe: true,
    ));

    chatInputController.clear();

    // ========================================
    // Mock response from other participant
    // In production: responses come from server
    // ========================================
    Future.delayed(const Duration(seconds: 2), () {
      _chatMessages.add(ChatMessage(
        senderName: remoteName,
        text: 'message_received'.tr,
        time: DateTime.now(),
        isMe: false,
      ));

      // Increment unread counter if chat is closed
      if (!_isChatVisible.value) {
        _unreadMessages.value++;
      }
    });
  }

  // ========================================
  // End Session
  // ========================================

  /// End session and leave room
  Future<void> endSession() async {
    // Stop timer
    _durationTimer?.cancel();

    try {
      // Stop local camera
      await _webrtcService.stopLocalCamera();

      // Update session status
      await _sessionRepo.endSession(_sessionId.value);
    } catch (e) {
      debugPrint('❌ Error ending session: $e');
    }

    // Go back to previous page
    Get.back();

    // Show rating dialog after a moment
    await Future.delayed(const Duration(milliseconds: 500));
    _showRatingDialog();
  }

  /// Show session rating dialog
  void _showRatingDialog() {
    final rating = 0.0.obs;
    final comment = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: Text('rate_session'.tr),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('session_experience'.tr),
            const SizedBox(height: 16),

            // ========================================
            // Rating stars
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
            // Comment field
            // ========================================
            TextField(
              controller: comment,
              decoration: InputDecoration(
                hintText: 'add_comment'.tr,
                border: const OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('later'.tr),
          ),
          ElevatedButton(
            onPressed: () {
              if (rating.value > 0) {
                // Save rating
                _sessionRepo.rateSession(
                  sessionId: _sessionId.value,
                  rating: rating.value,
                  comment: comment.text.isEmpty ? null : comment.text,
                );
                Get.back();
                Get.snackbar('thank_you'.tr, 'rating_saved'.tr);
              } else {
                Get.snackbar('warning'.tr, 'select_rating'.tr);
              }
            },
            child: Text('send'.tr),
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

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:permission_handler/permission_handler.dart';

/// خدمة WebRTC للفيديو المضمن داخل التطبيق
class WebRTCService {
  /// Local video renderer - يتم إنشاءه عند التهيئة
  late RTCVideoRenderer localRenderer;

  /// Remote video renderer - يتم إنشاءه عند التهيئة
  late RTCVideoRenderer remoteRenderer;

  /// Local media stream
  MediaStream? _localStream;

  /// هل الكاميرا مفعلة
  bool _isCameraEnabled = true;
  bool get isCameraEnabled => _isCameraEnabled;

  /// هل الميكروفون مفعل
  bool _isMicEnabled = true;
  bool get isMicEnabled => _isMicEnabled;

  /// هل الكاميرا الأمامية
  bool _isFrontCamera = true;
  bool get isFrontCamera => _isFrontCamera;

  /// هل تم التهيئة
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  /// Callbacks
  Function()? onLocalStreamReady;
  Function(String error)? onError;

  /// تهيئة الـ Renderers
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // إنشاء renderers جديدة
      localRenderer = RTCVideoRenderer();
      remoteRenderer = RTCVideoRenderer();

      await localRenderer.initialize();
      await remoteRenderer.initialize();
      _isInitialized = true;
      debugPrint('✅ [WebRTC] Renderers initialized');
    } catch (e) {
      debugPrint('❌ [WebRTC] Failed to initialize renderers: $e');
      onError?.call('فشل في تهيئة الفيديو');
    }
  }

  /// طلب صلاحيات الكاميرا والميكروفون
  Future<bool> requestPermissions() async {
    try {
      final cameraStatus = await Permission.camera.request();
      final micStatus = await Permission.microphone.request();

      if (cameraStatus.isGranted && micStatus.isGranted) {
        debugPrint('✅ [WebRTC] Permissions granted');
        return true;
      } else {
        debugPrint('❌ [WebRTC] Permissions denied');
        onError?.call('يرجى منح صلاحيات الكاميرا والميكروفون');
        return false;
      }
    } catch (e) {
      debugPrint('❌ [WebRTC] Permission error: $e');
      return false;
    }
  }

  /// بدء الكاميرا المحلية
  Future<bool> startLocalCamera({
    bool enableVideo = true,
    bool enableAudio = true,
  }) async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      // طلب الصلاحيات
      final hasPermissions = await requestPermissions();
      if (!hasPermissions) return false;

      // إعدادات الوسائط
      final Map<String, dynamic> mediaConstraints = {
        'audio': enableAudio,
        'video': enableVideo
            ? {
                'facingMode': _isFrontCamera ? 'user' : 'environment',
                'width': {'ideal': 1280},
                'height': {'ideal': 720},
              }
            : false,
      };

      // الحصول على media stream
      _localStream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
      localRenderer.srcObject = _localStream;

      _isCameraEnabled = enableVideo;
      _isMicEnabled = enableAudio;

      debugPrint('✅ [WebRTC] Local camera started');
      onLocalStreamReady?.call();
      return true;
    } catch (e) {
      debugPrint('❌ [WebRTC] Failed to start camera: $e');
      onError?.call('فشل في تشغيل الكاميرا');
      return false;
    }
  }

  /// تبديل الكاميرا (أمامية/خلفية)
  Future<void> switchCamera() async {
    if (_localStream == null) return;

    try {
      final videoTrack = _localStream!.getVideoTracks().firstOrNull;
      if (videoTrack != null) {
        await Helper.switchCamera(videoTrack);
        _isFrontCamera = !_isFrontCamera;
        debugPrint('🔄 [WebRTC] Camera switched to ${_isFrontCamera ? "front" : "back"}');
      }
    } catch (e) {
      debugPrint('❌ [WebRTC] Failed to switch camera: $e');
    }
  }

  /// تفعيل/تعطيل الكاميرا
  void toggleCamera() {
    if (_localStream == null) return;

    final videoTrack = _localStream!.getVideoTracks().firstOrNull;
    if (videoTrack != null) {
      _isCameraEnabled = !_isCameraEnabled;
      videoTrack.enabled = _isCameraEnabled;
      debugPrint('📹 [WebRTC] Camera ${_isCameraEnabled ? "enabled" : "disabled"}');
    }
  }

  /// تفعيل/تعطيل الميكروفون
  void toggleMicrophone() {
    if (_localStream == null) return;

    final audioTrack = _localStream!.getAudioTracks().firstOrNull;
    if (audioTrack != null) {
      _isMicEnabled = !_isMicEnabled;
      audioTrack.enabled = _isMicEnabled;
      debugPrint('🎤 [WebRTC] Microphone ${_isMicEnabled ? "enabled" : "disabled"}');
    }
  }

  /// إيقاف الكاميرا
  Future<void> stopLocalCamera() async {
    if (_localStream != null) {
      for (var track in _localStream!.getTracks()) {
        await track.stop();
      }
      await _localStream!.dispose();
      _localStream = null;
      localRenderer.srcObject = null;
      debugPrint('⏹️ [WebRTC] Local camera stopped');
    }
  }

  /// تنظيف الموارد
  Future<void> dispose() async {
    await stopLocalCamera();
    if (_isInitialized) {
      await localRenderer.dispose();
      await remoteRenderer.dispose();
      _isInitialized = false;
    }
    debugPrint('🧹 [WebRTC] Disposed');
  }
}

/// Widget لعرض الفيديو المحلي
class LocalVideoWidget extends StatelessWidget {
  final RTCVideoRenderer renderer;
  final bool mirror;
  final BoxFit objectFit;

  const LocalVideoWidget({
    super.key,
    required this.renderer,
    this.mirror = true,
    this.objectFit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    return RTCVideoView(
      renderer,
      mirror: mirror,
      objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
    );
  }
}

/// Widget لعرض الفيديو البعيد
class RemoteVideoWidget extends StatelessWidget {
  final RTCVideoRenderer renderer;
  final BoxFit objectFit;

  const RemoteVideoWidget({
    super.key,
    required this.renderer,
    this.objectFit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    return RTCVideoView(
      renderer,
      objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
    );
  }
}

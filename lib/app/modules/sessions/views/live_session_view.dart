import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get/get.dart';

import '../../../core/constants/color_constants.dart';
import '../controllers/live_session_controller.dart';

/// Live Session View - Video call interface
class LiveSessionView extends GetView<LiveSessionController> {
  const LiveSessionView({super.key});

  @override
  Widget build(BuildContext context) {
    // Lock to landscape for better video experience (optional)
    // SystemChrome.setPreferredOrientations([
    //   DeviceOrientation.landscapeLeft,
    //   DeviceOrientation.landscapeRight,
    // ]);

    return WillPopScope(
      onWillPop: () async {
        return await _showExitDialog(context);
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Obx(() {
          if (controller.isConnecting) {
            return _buildConnectingScreen();
          }

          return Stack(
            children: [
              // Main video (remote user)
              _buildMainVideo(),

              // Local video (self)
              _buildLocalVideo(),

              // Top controls
              _buildTopControls(),

              // Bottom controls
              _buildBottomControls(),

              // Chat panel (if visible)
              if (controller.isChatVisible) _buildChatPanel(),

              // Participants panel (if visible)
              if (controller.isParticipantsVisible) _buildParticipantsPanel(),

              // Whiteboard (if visible)
              if (controller.isWhiteboardVisible) _buildWhiteboard(),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildConnectingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: Colors.white),
          const SizedBox(height: 24),
          Text(
            'connecting'.tr,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Obx(() => Text(
            controller.connectionStatus,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildMainVideo() {
    return Obx(() {
      // عرض الفيديو المحلي في الخلفية الرئيسية (لأنه لا يوجد مشارك بعيد في الوضع التجريبي)
      if (controller.isCameraReady && controller.isLocalVideoEnabled) {
        return RTCVideoView(
          controller.localRenderer,
          objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
          mirror: true,
        );
      }

      // في حالة عدم تفعيل الكاميرا أو عدم جاهزيتها
      return Container(
        color: Colors.grey[900],
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: AppColors.primary,
                child: Text(
                  controller.remoteName.isNotEmpty ? controller.remoteName[0] : 'participant'.tr.substring(0, 1),
                  style: const TextStyle(
                    fontSize: 40,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                controller.remoteName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                controller.isCameraReady
                    ? 'camera_off'.tr
                    : 'camera_starting'.tr,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildLocalVideo() {
    return Positioned(
      top: 100,
      right: 16,
      child: GestureDetector(
        onPanUpdate: (details) {
          // Allow dragging the local video
        },
        child: Obx(() => Container(
          width: 120,
          height: 160,
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white24, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black45,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: controller.isCameraReady && controller.isLocalVideoEnabled
                ? RTCVideoView(
                    controller.localRenderer,
                    objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                    mirror: true,
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          controller.isCameraReady ? Icons.videocam_off : Icons.hourglass_empty,
                          size: 30,
                          color: Colors.white54,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          controller.isCameraReady ? 'camera_off'.tr : 'loading'.tr,
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
          ),
        )),
      ),
    );
  }

  Widget _buildTopControls() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.fromLTRB(16, MediaQuery.of(Get.context!).padding.top + 8, 16, 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black54,
              Colors.transparent,
            ],
          ),
        ),
        child: Row(
          children: [
            // Session info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Obx(() => Text(
                    controller.sessionTitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  )),
                  const SizedBox(height: 4),
                  Obx(() => Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: controller.isConnected ? AppColors.success : AppColors.error,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        controller.duration,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  )),
                ],
              ),
            ),

            // Recording indicator
            Obx(() => controller.isRecording
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'recording'.tr,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink()),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(Get.context!).padding.bottom + 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Colors.black54,
              Colors.transparent,
            ],
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Microphone
            Obx(() => _ControlButton(
              icon: controller.isLocalAudioEnabled ? Icons.mic : Icons.mic_off,
              label: 'microphone'.tr,
              isActive: controller.isLocalAudioEnabled,
              onTap: controller.toggleMicrophone,
            )),

            // Camera
            Obx(() => _ControlButton(
              icon: controller.isLocalVideoEnabled ? Icons.videocam : Icons.videocam_off,
              label: 'camera'.tr,
              isActive: controller.isLocalVideoEnabled,
              onTap: controller.toggleCamera,
            )),

            // Flip camera
            _ControlButton(
              icon: Icons.flip_camera_ios,
              label: 'flip_camera'.tr,
              onTap: controller.flipCamera,
            ),

            // Screen share
            Obx(() => _ControlButton(
              icon: Icons.screen_share,
              label: 'share_screen'.tr,
              isActive: controller.isScreenSharing,
              onTap: controller.toggleScreenShare,
            )),

            // Whiteboard
            _ControlButton(
              icon: Icons.draw,
              label: 'whiteboard'.tr,
              onTap: controller.toggleWhiteboard,
            ),

            // Chat
            _ControlButton(
              icon: Icons.chat,
              label: 'chat'.tr,
              onTap: controller.toggleChat,
              badge: controller.unreadMessages,
            ),

            // End call
            _ControlButton(
              icon: Icons.call_end,
              label: 'end_call'.tr,
              isDestructive: true,
              onTap: () => _showExitDialog(Get.context!),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatPanel() {
    return Positioned(
      right: 0,
      top: 100,
      bottom: 100,
      width: 300,
      child: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[900]!.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'chat'.tr,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: controller.toggleChat,
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white24),

            // Messages
            Expanded(
              child: Obx(() => ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.chatMessages.length,
                itemBuilder: (context, index) {
                  final msg = controller.chatMessages[index];
                  return _ChatBubble(message: msg);
                },
              )),
            ),

            // Input
            Container(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller.chatInputController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'type_message'.tr,
                        hintStyle: TextStyle(color: Colors.white54),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white12,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: controller.sendMessage,
                    icon: const Icon(Icons.send, color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParticipantsPanel() {
    return Positioned(
      left: 0,
      top: 100,
      bottom: 100,
      width: 250,
      child: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[900]!.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'participants'.tr,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: controller.toggleParticipants,
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white24),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _ParticipantTile(
                    name: controller.remoteName,
                    isHost: true,
                    isMuted: !controller.isRemoteAudioEnabled,
                    hasVideo: controller.isRemoteVideoEnabled,
                  ),
                  _ParticipantTile(
                    name: 'you'.tr,
                    isHost: false,
                    isMuted: !controller.isLocalAudioEnabled,
                    hasVideo: controller.isLocalVideoEnabled,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWhiteboard() {
    return Positioned.fill(
      child: Container(
        color: Colors.white,
        child: Stack(
          children: [
            // Whiteboard canvas with grid background
            Positioned.fill(
              child: CustomPaint(
                painter: _GridPainter(),
              ),
            ),

            // Drawing canvas
            GestureDetector(
              onPanStart: (details) {
                controller.addDrawingPoint(details.localPosition);
              },
              onPanUpdate: (details) {
                controller.addDrawingPoint(details.localPosition);
              },
              onPanEnd: (_) {
                controller.endDrawingStroke();
              },
              child: Obx(() {
                // نستخدم length لتحفيز إعادة البناء عند تغير عدد الخطوط
                final _ = controller.drawingStrokes.length;
                return CustomPaint(
                  painter: _WhiteboardPainter(
                    strokes: controller.drawingStrokes,
                  ),
                  size: Size.infinite,
                );
              }),
            ),

            // Top toolbar - الشريط العلوي
            Positioned(
              top: MediaQuery.of(Get.context!).padding.top + 8,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // زر الإغلاق
                    _WhiteboardToolButton(
                      icon: Icons.close,
                      tooltip: 'close_whiteboard'.tr,
                      color: Colors.red,
                      onTap: controller.toggleWhiteboard,
                    ),
                    const SizedBox(width: 8),

                    // فاصل
                    Container(width: 1, height: 30, color: Colors.white24),
                    const SizedBox(width: 8),

                    // عنوان السبورة
                    Expanded(
                      child: Text(
                        'interactive_whiteboard'.tr,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(width: 8),
                    Container(width: 1, height: 30, color: Colors.white24),
                    const SizedBox(width: 8),

                    // أزرار التحكم
                    _WhiteboardToolButton(
                      icon: Icons.undo,
                      tooltip: 'undo'.tr,
                      color: Colors.orange,
                      onTap: controller.undoDrawing,
                    ),
                    const SizedBox(width: 4),
                    _WhiteboardToolButton(
                      icon: Icons.redo,
                      tooltip: 'redo'.tr,
                      color: Colors.orange,
                      onTap: () {}, // TODO: implement redo
                    ),
                    const SizedBox(width: 4),
                    _WhiteboardToolButton(
                      icon: Icons.delete_outline,
                      tooltip: 'clear_all'.tr,
                      color: Colors.red,
                      onTap: () => _showClearConfirmDialog(),
                    ),
                  ],
                ),
              ),
            ),

            // Left toolbar - شريط الأدوات الجانبي
            Positioned(
              left: 16,
              top: MediaQuery.of(Get.context!).padding.top + 80,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Obx(() => Column(
                  children: [
                    // أدوات الرسم
                    _WhiteboardToolButton(
                      icon: Icons.edit,
                      tooltip: 'pen'.tr,
                      color: Colors.blue,
                      isSelected: controller.currentDrawingTool == DrawingTool.pen,
                      onTap: () => controller.setDrawingTool(DrawingTool.pen),
                    ),
                    const SizedBox(height: 8),
                    _WhiteboardToolButton(
                      icon: Icons.brush,
                      tooltip: 'brush'.tr,
                      color: Colors.purple,
                      isSelected: controller.currentDrawingTool == DrawingTool.brush,
                      onTap: () => controller.setDrawingTool(DrawingTool.brush),
                    ),
                    const SizedBox(height: 8),
                    _WhiteboardToolButton(
                      icon: Icons.highlight,
                      tooltip: 'highlighter'.tr,
                      color: Colors.yellow,
                      isSelected: controller.currentDrawingTool == DrawingTool.highlighter,
                      onTap: () => controller.setDrawingTool(DrawingTool.highlighter),
                    ),
                    const SizedBox(height: 8),
                    _WhiteboardToolButton(
                      icon: Icons.auto_fix_high,
                      tooltip: 'eraser'.tr,
                      color: Colors.grey,
                      isSelected: controller.currentDrawingTool == DrawingTool.eraser,
                      onTap: () => controller.setDrawingTool(DrawingTool.eraser),
                    ),

                    const SizedBox(height: 16),
                    Container(height: 1, width: 30, color: Colors.white24),
                    const SizedBox(height: 16),

                    // الأشكال
                    _WhiteboardToolButton(
                      icon: Icons.crop_square,
                      tooltip: 'rectangle'.tr,
                      color: Colors.teal,
                      isSelected: controller.currentDrawingTool == DrawingTool.rectangle,
                      onTap: () => controller.setDrawingTool(DrawingTool.rectangle),
                    ),
                    const SizedBox(height: 8),
                    _WhiteboardToolButton(
                      icon: Icons.circle_outlined,
                      tooltip: 'circle'.tr,
                      color: Colors.teal,
                      isSelected: controller.currentDrawingTool == DrawingTool.circle,
                      onTap: () => controller.setDrawingTool(DrawingTool.circle),
                    ),
                    const SizedBox(height: 8),
                    _WhiteboardToolButton(
                      icon: Icons.horizontal_rule,
                      tooltip: 'line'.tr,
                      color: Colors.teal,
                      isSelected: controller.currentDrawingTool == DrawingTool.line,
                      onTap: () => controller.setDrawingTool(DrawingTool.line),
                    ),
                    const SizedBox(height: 8),
                    _WhiteboardToolButton(
                      icon: Icons.arrow_forward,
                      tooltip: 'arrow'.tr,
                      color: Colors.teal,
                      isSelected: controller.currentDrawingTool == DrawingTool.arrow,
                      onTap: () => controller.setDrawingTool(DrawingTool.arrow),
                    ),

                    const SizedBox(height: 16),
                    Container(height: 1, width: 30, color: Colors.white24),
                    const SizedBox(height: 16),

                    // نص
                    _WhiteboardToolButton(
                      icon: Icons.text_fields,
                      tooltip: 'text'.tr,
                      color: Colors.indigo,
                      isSelected: controller.currentDrawingTool == DrawingTool.text,
                      onTap: () => controller.setDrawingTool(DrawingTool.text),
                    ),
                  ],
                )),
              ),
            ),

            // Bottom toolbar - شريط الألوان والسُمك
            Positioned(
              bottom: MediaQuery.of(Get.context!).padding.bottom + 16,
              left: 80,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // اختيار اللون
                      Text(
                        '${'color'.tr}:',
                        style: const TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                      const SizedBox(width: 8),
                      Obx(() => Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _ColorButton(
                            color: Colors.black,
                            isSelected: controller.currentDrawingColor == Colors.black,
                            onTap: () => controller.setDrawingColor(Colors.black),
                          ),
                          _ColorButton(
                            color: Colors.red,
                            isSelected: controller.currentDrawingColor == Colors.red,
                            onTap: () => controller.setDrawingColor(Colors.red),
                          ),
                          _ColorButton(
                            color: Colors.blue,
                            isSelected: controller.currentDrawingColor == Colors.blue,
                            onTap: () => controller.setDrawingColor(Colors.blue),
                          ),
                          _ColorButton(
                            color: Colors.green,
                            isSelected: controller.currentDrawingColor == Colors.green,
                            onTap: () => controller.setDrawingColor(Colors.green),
                          ),
                          _ColorButton(
                            color: Colors.orange,
                            isSelected: controller.currentDrawingColor == Colors.orange,
                            onTap: () => controller.setDrawingColor(Colors.orange),
                          ),
                          _ColorButton(
                            color: Colors.purple,
                            isSelected: controller.currentDrawingColor == Colors.purple,
                            onTap: () => controller.setDrawingColor(Colors.purple),
                          ),
                        ],
                      )),

                      const SizedBox(width: 16),
                      Container(width: 1, height: 28, color: Colors.white24),
                      const SizedBox(width: 16),

                      // اختيار السُمك
                      Text(
                        '${'stroke_width'.tr}:',
                        style: const TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                      const SizedBox(width: 8),
                      Obx(() => Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _StrokeWidthButton(
                            width: 2,
                            isSelected: controller.currentStrokeWidth == 2,
                            onTap: () => controller.setStrokeWidth(2),
                          ),
                          _StrokeWidthButton(
                            width: 4,
                            isSelected: controller.currentStrokeWidth == 4,
                            onTap: () => controller.setStrokeWidth(4),
                          ),
                          _StrokeWidthButton(
                            width: 6,
                            isSelected: controller.currentStrokeWidth == 6,
                            onTap: () => controller.setStrokeWidth(6),
                          ),
                          _StrokeWidthButton(
                            width: 10,
                            isSelected: controller.currentStrokeWidth == 10,
                            onTap: () => controller.setStrokeWidth(10),
                          ),
                        ],
                      )),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showClearConfirmDialog() {
    Get.dialog(
      AlertDialog(
        title: Text('clear_whiteboard'.tr),
        content: Text('clear_whiteboard_confirm'.tr),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('cancel'.tr),
          ),
          ElevatedButton(
            onPressed: () {
              controller.clearWhiteboard();
              Get.back();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('clear'.tr),
          ),
        ],
      ),
    );
  }

  Future<bool> _showExitDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('end_session'.tr),
        content: Text('end_session_confirm'.tr),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('cancel'.tr),
          ),
          ElevatedButton(
            onPressed: () {
              controller.endSession();
              Navigator.of(context).pop(true);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: Text('end'.tr),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final bool isDestructive;
  final VoidCallback onTap;
  final int badge;

  const _ControlButton({
    required this.icon,
    required this.label,
    this.isActive = true,
    this.isDestructive = false,
    required this.onTap,
    this.badge = 0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDestructive
                      ? AppColors.error
                      : (isActive ? Colors.white24 : Colors.red.withValues(alpha: 0.3)),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              if (badge > 0)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$badge',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isMe = message.isMe;
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isMe ? AppColors.primary : Colors.white24,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isMe)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  message.senderName,
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            Text(
              message.text,
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 4),
            Text(
              '${message.time.hour}:${message.time.minute.toString().padLeft(2, '0')}',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ParticipantTile extends StatelessWidget {
  final String name;
  final bool isHost;
  final bool isMuted;
  final bool hasVideo;

  const _ParticipantTile({
    required this.name,
    required this.isHost,
    required this.isMuted,
    required this.hasVideo,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppColors.primary,
        child: Text(
          name[0],
          style: const TextStyle(color: Colors.white),
        ),
      ),
      title: Text(
        name,
        style: const TextStyle(color: Colors.white),
      ),
      subtitle: isHost
          ? Text(
              'host'.tr,
              style: TextStyle(color: AppColors.primary, fontSize: 12),
            )
          : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isMuted ? Icons.mic_off : Icons.mic,
            color: isMuted ? Colors.red : Colors.green,
            size: 20,
          ),
          const SizedBox(width: 8),
          Icon(
            hasVideo ? Icons.videocam : Icons.videocam_off,
            color: hasVideo ? Colors.green : Colors.red,
            size: 20,
          ),
        ],
      ),
    );
  }
}

class _WhiteboardPainter extends CustomPainter {
  final List<DrawingStroke> strokes;

  _WhiteboardPainter({required this.strokes});

  @override
  void paint(Canvas canvas, Size size) {
    for (final stroke in strokes) {
      final paint = Paint()
        ..color = stroke.color
        ..strokeWidth = stroke.width
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      // رسم حسب نوع الأداة
      switch (stroke.tool) {
        case DrawingTool.rectangle:
          _drawRectangle(canvas, stroke, paint);
          break;
        case DrawingTool.circle:
          _drawCircle(canvas, stroke, paint);
          break;
        case DrawingTool.line:
          _drawStraightLine(canvas, stroke, paint);
          break;
        case DrawingTool.arrow:
          _drawArrow(canvas, stroke, paint);
          break;
        case DrawingTool.highlighter:
          paint.strokeCap = StrokeCap.square;
          _drawFreehand(canvas, stroke, paint);
          break;
        default:
          // قلم، فرشاة، ممحاة - رسم حر
          _drawFreehand(canvas, stroke, paint);
      }
    }
  }

  /// رسم خط حر (قلم، فرشاة، ممحاة)
  void _drawFreehand(Canvas canvas, DrawingStroke stroke, Paint paint) {
    for (int i = 0; i < stroke.points.length - 1; i++) {
      canvas.drawLine(stroke.points[i], stroke.points[i + 1], paint);
    }
  }

  /// رسم مستطيل
  void _drawRectangle(Canvas canvas, DrawingStroke stroke, Paint paint) {
    if (stroke.points.length >= 2) {
      final start = stroke.points.first;
      final end = stroke.points.last;
      final rect = Rect.fromPoints(start, end);
      canvas.drawRect(rect, paint);
    }
  }

  /// رسم دائرة
  void _drawCircle(Canvas canvas, DrawingStroke stroke, Paint paint) {
    if (stroke.points.length >= 2) {
      final start = stroke.points.first;
      final end = stroke.points.last;
      final center = Offset(
        (start.dx + end.dx) / 2,
        (start.dy + end.dy) / 2,
      );
      final radius = (end - start).distance / 2;
      canvas.drawCircle(center, radius, paint);
    }
  }

  /// رسم خط مستقيم
  void _drawStraightLine(Canvas canvas, DrawingStroke stroke, Paint paint) {
    if (stroke.points.length >= 2) {
      canvas.drawLine(stroke.points.first, stroke.points.last, paint);
    }
  }

  /// رسم سهم
  void _drawArrow(Canvas canvas, DrawingStroke stroke, Paint paint) {
    if (stroke.points.length >= 2) {
      final start = stroke.points.first;
      final end = stroke.points.last;

      // رسم الخط الرئيسي
      canvas.drawLine(start, end, paint);

      // رسم رأس السهم
      final angle = (end - start).direction;
      const arrowSize = 20.0;
      const arrowAngle = 0.5; // زاوية الرأس

      final p1 = Offset(
        end.dx - arrowSize * cos(angle - arrowAngle),
        end.dy - arrowSize * sin(angle - arrowAngle),
      );
      final p2 = Offset(
        end.dx - arrowSize * cos(angle + arrowAngle),
        end.dy - arrowSize * sin(angle + arrowAngle),
      );

      canvas.drawLine(end, p1, paint);
      canvas.drawLine(end, p2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _WhiteboardPainter oldDelegate) {
    return true;
  }
}

/// رسام الشبكة الخلفية للسبورة
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.2)
      ..strokeWidth = 0.5;

    const gridSize = 30.0;

    // خطوط أفقية
    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // خطوط رأسية
    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// زر أداة السبورة
class _WhiteboardToolButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _WhiteboardToolButton({
    required this.icon,
    required this.tooltip,
    required this.color,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: 0.3) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: isSelected
                ? Border.all(color: color, width: 2)
                : null,
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
      ),
    );
  }
}

/// زر اختيار اللون
class _ColorButton extends StatelessWidget {
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _ColorButton({
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.white : Colors.grey,
            width: isSelected ? 3 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.5),
                    blurRadius: 8,
                    spreadRadius: 1,
                  )
                ]
              : null,
        ),
      ),
    );
  }
}

/// زر اختيار سمك الخط
class _StrokeWidthButton extends StatelessWidget {
  final double width;
  final bool isSelected;
  final VoidCallback onTap;

  const _StrokeWidthButton({
    required this.width,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.withValues(alpha: 0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Center(
          child: Container(
            width: width * 2,
            height: width * 2,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}

// Models
class ChatMessage {
  final String senderName;
  final String text;
  final DateTime time;
  final bool isMe;

  ChatMessage({
    required this.senderName,
    required this.text,
    required this.time,
    required this.isMe,
  });
}

class DrawingStroke {
  final List<Offset> points;
  final Color color;
  final double width;
  final DrawingTool tool;

  DrawingStroke({
    required this.points,
    required this.color,
    this.width = 3.0,
    this.tool = DrawingTool.pen,
  });
}

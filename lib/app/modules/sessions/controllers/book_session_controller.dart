import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/services/session_reminder_service.dart';
import '../../../data/models/session_model.dart';
import '../../../data/models/teacher_model.dart';
import '../../../data/repositories/session_repository.dart';
import '../../../data/repositories/teacher_repository.dart';
import '../../../routes/app_routes.dart';

/// Book Session Controller
class BookSessionController extends GetxController {
  final SessionRepository _sessionRepo = Get.find();
  final TeacherRepository _teacherRepo = Get.find();

  // Loading state
  final _isLoading = true.obs;
  bool get isLoading => _isLoading.value;

  final _isBooking = false.obs;
  bool get isBooking => _isBooking.value;

  // Teacher
  final _teacher = Rxn<TeacherModel>();
  TeacherModel? get teacher => _teacher.value;

  // Selection
  final sessionType = 'one_on_one'.obs;
  final selectedSubject = ''.obs;
  final selectedDate = Rxn<DateTime>();
  final selectedTime = ''.obs;
  final duration = 60.obs;

  // Available slots
  final _availableSlots = <String>[].obs;
  List<String> get availableSlots => _availableSlots;

  // Notes
  final notesController = TextEditingController();

  // Price
  double get hourlyRate => teacher?.hourlyRate ?? 100.0;
  double get totalPrice => (hourlyRate * duration.value) / 60;

  @override
  void onInit() {
    super.onInit();
    _loadTeacher();
  }

  Future<void> _loadTeacher() async {
    final teacherId = Get.parameters['id'];
    if (teacherId == null) {
      Get.back();
      return;
    }

    try {
      _teacher.value = await _teacherRepo.getTeacherById(teacherId);
      if (_teacher.value != null && _teacher.value!.subjects.isNotEmpty) {
        selectedSubject.value = _teacher.value!.subjects.first;
      }
    } catch (e) {
      Get.snackbar('error'.tr, 'failed_load_teacher'.tr);
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> selectDate(DateTime date) async {
    selectedDate.value = date;
    selectedTime.value = '';
    await _loadAvailableSlots(date);
  }

  Future<void> _loadAvailableSlots(DateTime date) async {
    if (teacher == null) return;

    try {
      final slots = await _sessionRepo.getAvailableSlots(
        teacherId: teacher!.id,
        date: date,
      );
      _availableSlots.value = slots;
    } catch (e) {
      _availableSlots.value = [];
    }
  }

  Future<void> bookSession() async {
    // Validation
    if (selectedDate.value == null) {
      Get.snackbar('error'.tr, 'please_select_date'.tr);
      return;
    }

    if (selectedTime.value.isEmpty) {
      Get.snackbar('error'.tr, 'please_select_time'.tr);
      return;
    }

    if (selectedSubject.value.isEmpty) {
      Get.snackbar('error'.tr, 'please_select_subject'.tr);
      return;
    }

    _isBooking.value = true;

    try {
      // Parse time
      final timeParts = selectedTime.value.split(':');
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);

      final scheduledAt = DateTime(
        selectedDate.value!.year,
        selectedDate.value!.month,
        selectedDate.value!.day,
        hour,
        minute,
      );

      final request = SessionBookingRequest(
        teacherId: teacher!.id,
        scheduledAt: scheduledAt,
        durationMinutes: duration.value,
        price: totalPrice,
        subject: selectedSubject.value,
        notes: notesController.text.isEmpty ? null : notesController.text,
        type: SessionType.fromString(sessionType.value),
      );

      final session = await _sessionRepo.bookSession(request);

      // جدولة تذكيرات الجلسة
      await SessionReminderService.to.scheduleReminders(session);

      Get.back();
      Get.snackbar(
        'booking_success'.tr,
        'session_booked_reminder'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Show confirmation dialog
      _showConfirmationDialog(session);
    } catch (e) {
      Get.snackbar('error'.tr, '${'booking_failed'.tr}: $e');
    } finally {
      _isBooking.value = false;
    }
  }

  void _showConfirmationDialog(SessionModel session) {
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            const SizedBox(width: 8),
            Text('booking_success'.tr),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _InfoRow('teacher'.tr, teacher?.fullName ?? ''),
            _InfoRow('subject'.tr, session.subject ?? ''),
            _InfoRow('date'.tr, '${session.scheduledAt.day}/${session.scheduledAt.month}/${session.scheduledAt.year}'),
            _InfoRow('time'.tr, '${session.scheduledAt.hour}:${session.scheduledAt.minute.toString().padLeft(2, '0')}'),
            _InfoRow('duration'.tr, '${session.durationMinutes} ${'minute'.tr}'),
            _InfoRow('price'.tr, '${session.price.toInt()} ${'sar'.tr}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('close'.tr),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.toNamed(Routes.sessionDetailsPath(session.id));
            },
            child: Text('view_details'.tr),
          ),
        ],
      ),
    );
  }

  @override
  void onClose() {
    notesController.dispose();
    super.onClose();
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

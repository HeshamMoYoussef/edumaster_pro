import 'package:get/get.dart';

import '../../config/env_config.dart';
import '../../core/network/api_client.dart';
import '../../core/constants/api_constants.dart';
import '../models/session_model.dart';
import '../mock/mock_data.dart';

/// Session repository
class SessionRepository {
  final ApiClient _api = Get.find();
  bool get _useMock => EnvConfig.useMockData;

  /// Get user sessions
  Future<List<SessionModel>> getMySessions({
    SessionStatus? status,
    DateTime? fromDate,
    DateTime? toDate,
    int page = 1,
    int limit = 20,
  }) async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 800));
      var sessions = MockData.sessions;

      // Filter by status
      if (status != null) {
        sessions = sessions.where((s) => s.status == status).toList();
      }

      return sessions;
    }

    final response = await _api.get(
      ApiConstants.sessions,
      queryParameters: {
        if (status != null) 'status': status.value,
        if (fromDate != null) 'from_date': fromDate.toIso8601String(),
        if (toDate != null) 'to_date': toDate.toIso8601String(),
        'page': page,
        'limit': limit,
      },
    );

    return (response.data['data'] as List)
        .map((e) => SessionModel.fromJson(e))
        .toList();
  }

  /// Get upcoming sessions
  Future<List<SessionModel>> getUpcomingSessions() async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 500));
      return MockData.sessions
          .where((s) =>
              (s.status == SessionStatus.scheduled ||
                  s.status == SessionStatus.confirmed) &&
              s.scheduledAt.isAfter(DateTime.now()))
          .toList();
    }

    final response = await _api.get('${ApiConstants.sessions}/upcoming');
    return (response.data['data'] as List)
        .map((e) => SessionModel.fromJson(e))
        .toList();
  }

  /// Get session by ID
  Future<SessionModel> getSessionById(String id) async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 500));
      final session = MockData.sessions.firstWhere(
        (s) => s.id == id,
        orElse: () => throw Exception('الجلسة غير موجودة'),
      );
      return session;
    }

    final response = await _api.get('${ApiConstants.sessions}/$id');
    return SessionModel.fromJson(response.data);
  }

  /// Book a session
  Future<SessionModel> bookSession(SessionBookingRequest request) async {
    if (_useMock) {
      await Future.delayed(const Duration(seconds: 1));

      // البحث عن المعلم
      final teacher = MockData.teachers.firstWhere(
        (t) => t.id == request.teacherId,
        orElse: () => MockData.teachers.first,
      );

      final newSession = SessionModel(
        id: 'session_${DateTime.now().millisecondsSinceEpoch}',
        teacherId: request.teacherId,
        teacher: teacher,
        studentId: MockData.currentUser.id,
        subject: request.subject,
        type: request.type,
        status: SessionStatus.confirmed, // تأكيد تلقائي في وضع المحاكاة
        scheduledAt: request.scheduledAt,
        durationMinutes: request.durationMinutes,
        price: request.price,
        notes: request.notes,
        createdAt: DateTime.now(),
      );

      // إضافة الجلسة للقائمة حتى يمكن الوصول إليها لاحقاً
      MockData.sessions.add(newSession);

      return newSession;
    }

    final response = await _api.post(
      ApiConstants.bookSession,
      data: request.toJson(),
    );
    return SessionModel.fromJson(response.data);
  }

  /// Cancel session
  Future<void> cancelSession(String sessionId, {String? reason}) async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 500));
      return;
    }

    await _api.post(
      '${ApiConstants.sessions}/$sessionId/cancel',
      data: {'reason': reason},
    );
  }

  /// Reschedule session
  Future<SessionModel> rescheduleSession({
    required String sessionId,
    required DateTime newDateTime,
  }) async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 500));
      final session = MockData.sessions.firstWhere((s) => s.id == sessionId);
      return session.copyWith(scheduledAt: newDateTime);
    }

    final response = await _api.post(
      '${ApiConstants.sessions}/$sessionId/reschedule',
      data: {'new_date_time': newDateTime.toIso8601String()},
    );
    return SessionModel.fromJson(response.data);
  }

  /// Join live session
  Future<Map<String, dynamic>> joinSession(String sessionId) async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 500));
      return {
        'room_id': 'room_$sessionId',
        'token': 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
        'type': 'jitsi', // or 'agora', 'zoom'
      };
    }

    final response = await _api.post(
      '${ApiConstants.sessions}/$sessionId/join',
    );
    return Map<String, dynamic>.from(response.data);
  }

  /// End session
  Future<void> endSession(String sessionId) async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      return;
    }

    await _api.post('${ApiConstants.sessions}/$sessionId/end');
  }

  /// Rate session
  Future<void> rateSession({
    required String sessionId,
    required double rating,
    String? comment,
  }) async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 500));
      return;
    }

    await _api.post(
      '${ApiConstants.sessions}/$sessionId/rate',
      data: {
        'rating': rating,
        'comment': comment,
      },
    );
  }

  /// Get available slots for a teacher on a specific date
  Future<List<String>> getAvailableSlots({
    required String teacherId,
    required DateTime date,
  }) async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 500));
      // Return mock available slots
      return [
        '09:00',
        '10:00',
        '11:00',
        '14:00',
        '15:00',
        '16:00',
        '19:00',
        '20:00',
      ];
    }

    final response = await _api.get(
      '${ApiConstants.teachers}/$teacherId/slots',
      queryParameters: {'date': date.toIso8601String()},
    );
    return List<String>.from(response.data['slots']);
  }
}

extension SessionModelCopyWith on SessionModel {
  SessionModel copyWith({DateTime? scheduledAt}) {
    return SessionModel(
      id: id,
      teacherId: teacherId,
      teacher: teacher,
      studentId: studentId,
      student: student,
      subject: subject,
      type: type,
      status: status,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      durationMinutes: durationMinutes,
      price: price,
      meetingUrl: meetingUrl,
      notes: notes,
      recordingUrl: recordingUrl,
      rating: rating,
      review: review,
      createdAt: createdAt,
      startedAt: startedAt,
      endedAt: endedAt,
      cancelledAt: cancelledAt,
      cancellationReason: cancellationReason,
    );
  }
}

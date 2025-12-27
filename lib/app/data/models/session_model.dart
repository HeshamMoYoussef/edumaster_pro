import 'package:get/get.dart';
import 'teacher_model.dart';
import 'user_model.dart';

/// Session model for live tutoring sessions
class SessionModel {
  final String id;
  final String teacherId;
  final TeacherModel? teacher;
  final String studentId;
  final UserModel? student;
  final String? subject;
  final String? topic;
  final SessionType type;
  final SessionStatus status;
  final DateTime scheduledAt;
  final int durationMinutes;
  final double price;
  final String? meetingUrl;
  final String? notes;
  final String? recordingUrl;
  final double? rating;
  final String? review;
  final DateTime createdAt;
  final DateTime? startedAt;
  final DateTime? endedAt;
  final DateTime? cancelledAt;
  final String? cancellationReason;

  const SessionModel({
    required this.id,
    required this.teacherId,
    this.teacher,
    required this.studentId,
    this.student,
    this.subject,
    this.topic,
    this.type = SessionType.oneOnOne,
    this.status = SessionStatus.pending,
    required this.scheduledAt,
    this.durationMinutes = 60,
    required this.price,
    this.meetingUrl,
    this.notes,
    this.recordingUrl,
    this.rating,
    this.review,
    required this.createdAt,
    this.startedAt,
    this.endedAt,
    this.cancelledAt,
    this.cancellationReason,
  });

  factory SessionModel.fromJson(Map<String, dynamic> json) {
    return SessionModel(
      id: json['id'] as String,
      teacherId: json['teacher_id'] as String,
      teacher: json['teacher'] != null
          ? TeacherModel.fromJson(json['teacher'] as Map<String, dynamic>)
          : null,
      studentId: json['student_id'] as String,
      student: json['student'] != null
          ? UserModel.fromJson(json['student'] as Map<String, dynamic>)
          : null,
      subject: json['subject'] as String?,
      topic: json['topic'] as String?,
      type: SessionType.fromString(json['type'] as String? ?? 'one_on_one'),
      status:
          SessionStatus.fromString(json['status'] as String? ?? 'pending'),
      scheduledAt: DateTime.parse(json['scheduled_at'] as String),
      durationMinutes: json['duration_minutes'] as int? ?? 60,
      price: (json['price'] as num).toDouble(),
      meetingUrl: json['meeting_url'] as String?,
      notes: json['notes'] as String?,
      recordingUrl: json['recording_url'] as String?,
      rating: (json['rating'] as num?)?.toDouble(),
      review: json['review'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      startedAt: json['started_at'] != null
          ? DateTime.parse(json['started_at'] as String)
          : null,
      endedAt: json['ended_at'] != null
          ? DateTime.parse(json['ended_at'] as String)
          : null,
      cancelledAt: json['cancelled_at'] != null
          ? DateTime.parse(json['cancelled_at'] as String)
          : null,
      cancellationReason: json['cancellation_reason'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'teacher_id': teacherId,
      'teacher': teacher?.toJson(),
      'student_id': studentId,
      'student': student?.toJson(),
      'subject': subject,
      'topic': topic,
      'type': type.value,
      'status': status.value,
      'scheduled_at': scheduledAt.toIso8601String(),
      'duration_minutes': durationMinutes,
      'price': price,
      'meeting_url': meetingUrl,
      'notes': notes,
      'recording_url': recordingUrl,
      'rating': rating,
      'review': review,
      'created_at': createdAt.toIso8601String(),
      'started_at': startedAt?.toIso8601String(),
      'ended_at': endedAt?.toIso8601String(),
      'cancelled_at': cancelledAt?.toIso8601String(),
      'cancellation_reason': cancellationReason,
    };
  }

  SessionModel copyWith({
    String? id,
    String? teacherId,
    TeacherModel? teacher,
    String? studentId,
    UserModel? student,
    String? subject,
    String? topic,
    SessionType? type,
    SessionStatus? status,
    DateTime? scheduledAt,
    int? durationMinutes,
    double? price,
    String? meetingUrl,
    String? notes,
    String? recordingUrl,
    double? rating,
    String? review,
    DateTime? createdAt,
    DateTime? startedAt,
    DateTime? endedAt,
    DateTime? cancelledAt,
    String? cancellationReason,
  }) {
    return SessionModel(
      id: id ?? this.id,
      teacherId: teacherId ?? this.teacherId,
      teacher: teacher ?? this.teacher,
      studentId: studentId ?? this.studentId,
      student: student ?? this.student,
      subject: subject ?? this.subject,
      topic: topic ?? this.topic,
      type: type ?? this.type,
      status: status ?? this.status,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      price: price ?? this.price,
      meetingUrl: meetingUrl ?? this.meetingUrl,
      notes: notes ?? this.notes,
      recordingUrl: recordingUrl ?? this.recordingUrl,
      rating: rating ?? this.rating,
      review: review ?? this.review,
      createdAt: createdAt ?? this.createdAt,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      cancellationReason: cancellationReason ?? this.cancellationReason,
    );
  }

  /// Get formatted duration
  String get formattedDuration {
    if (durationMinutes < 60) {
      return '$durationMinutes ${'minute'.tr}';
    }
    final hours = durationMinutes ~/ 60;
    final minutes = durationMinutes % 60;
    if (minutes == 0) {
      return '$hours ${hours == 1 ? 'hour'.tr : 'hours'.tr}';
    }
    return '$hours ${'hour'.tr} ${'and'.tr} $minutes ${'minute'.tr}';
  }

  /// Check if session can be joined
  bool get canJoin {
    if (status != SessionStatus.confirmed) return false;
    final now = DateTime.now();
    final startBuffer = scheduledAt.subtract(const Duration(minutes: 5));
    final endTime = scheduledAt.add(Duration(minutes: durationMinutes));
    return now.isAfter(startBuffer) && now.isBefore(endTime);
  }

  /// Check if session can be cancelled
  bool get canCancel {
    if (status != SessionStatus.pending && status != SessionStatus.confirmed) {
      return false;
    }
    // Can cancel up to 2 hours before
    return DateTime.now()
        .isBefore(scheduledAt.subtract(const Duration(hours: 2)));
  }

  /// Check if session can be rescheduled
  bool get canReschedule {
    if (status != SessionStatus.pending && status != SessionStatus.confirmed) {
      return false;
    }
    // Can reschedule up to 24 hours before
    return DateTime.now()
        .isBefore(scheduledAt.subtract(const Duration(hours: 24)));
  }

  /// Check if session is upcoming
  bool get isUpcoming {
    return status == SessionStatus.confirmed &&
        scheduledAt.isAfter(DateTime.now());
  }

  /// Check if session is past
  bool get isPast {
    return status == SessionStatus.completed ||
        (status == SessionStatus.confirmed &&
            scheduledAt
                .add(Duration(minutes: durationMinutes))
                .isBefore(DateTime.now()));
  }

  /// Get end time
  DateTime get endTime => scheduledAt.add(Duration(minutes: durationMinutes));
}

/// Session type enum
enum SessionType {
  oneOnOne('one_on_one', 'session_type_one_on_one'),
  group('group', 'session_type_group'),
  workshop('workshop', 'session_type_workshop'),
  mentorship('mentorship', 'session_type_mentorship'),
  instantHelp('instant_help', 'session_type_instant_help'),
  instant('instant', 'session_type_instant'),
  trial('trial', 'session_type_trial');

  final String value;
  final String labelKey;
  const SessionType(this.value, this.labelKey);

  String get label => labelKey.tr;

  static SessionType fromString(String value) {
    return SessionType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => SessionType.oneOnOne,
    );
  }
}

/// Session status enum
enum SessionStatus {
  pending('pending', 'status_pending'),
  scheduled('scheduled', 'status_scheduled'),
  confirmed('confirmed', 'status_confirmed'),
  rescheduled('rescheduled', 'status_rescheduled'),
  inProgress('in_progress', 'status_in_progress'),
  completed('completed', 'status_completed'),
  cancelled('cancelled', 'status_cancelled'),
  noShow('no_show', 'status_no_show');

  final String value;
  final String labelKey;
  const SessionStatus(this.value, this.labelKey);

  String get label => labelKey.tr;

  static SessionStatus fromString(String value) {
    return SessionStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => SessionStatus.pending,
    );
  }
}

/// Session booking request model
class SessionBookingRequest {
  final String teacherId;
  final DateTime scheduledAt;
  final int durationMinutes;
  final double price;
  final String? subject;
  final String? topic;
  final String? notes;
  final SessionType type;

  const SessionBookingRequest({
    required this.teacherId,
    required this.scheduledAt,
    this.durationMinutes = 60,
    this.price = 0.0,
    this.subject,
    this.topic,
    this.notes,
    this.type = SessionType.oneOnOne,
  });

  Map<String, dynamic> toJson() {
    return {
      'teacher_id': teacherId,
      'scheduled_at': scheduledAt.toIso8601String(),
      'duration_minutes': durationMinutes,
      'price': price,
      'subject': subject,
      'topic': topic,
      'notes': notes,
      'type': type.value,
    };
  }
}

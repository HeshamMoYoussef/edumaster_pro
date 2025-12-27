import 'package:get/get.dart';

/// Teacher model
class TeacherModel {
  final String id;
  final String email;
  final String fullName;
  final String? phone;
  final String? avatar;
  final String? bio;
  final List<String> subjects;
  final List<String> languages;
  final String? education;
  final int experienceYears;
  final double rating;
  final int totalReviews;
  final int totalStudents;
  final int totalSessions;
  final int totalCourses;
  final double hourlyRate;
  final bool isVerified;
  final bool isFeatured;
  final bool isAvailable;
  final TeacherAvailability availability;
  final List<TeacherCertificate> certificates;
  final DateTime createdAt;

  const TeacherModel({
    required this.id,
    required this.email,
    required this.fullName,
    this.phone,
    this.avatar,
    this.bio,
    this.subjects = const [],
    this.languages = const ['العربية'],
    this.education,
    this.experienceYears = 0,
    this.rating = 0.0,
    this.totalReviews = 0,
    this.totalStudents = 0,
    this.totalSessions = 0,
    this.totalCourses = 0,
    this.hourlyRate = 0.0,
    this.isVerified = false,
    this.isFeatured = false,
    this.isAvailable = true,
    this.availability = const TeacherAvailability(),
    this.certificates = const [],
    required this.createdAt,
  });

  factory TeacherModel.fromJson(Map<String, dynamic> json) {
    return TeacherModel(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String,
      phone: json['phone'] as String?,
      avatar: json['avatar'] as String?,
      bio: json['bio'] as String?,
      subjects: (json['subjects'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      languages: (json['languages'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          ['العربية'],
      education: json['education'] as String?,
      experienceYears: json['experience_years'] as int? ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      totalReviews: json['total_reviews'] as int? ?? 0,
      totalStudents: json['total_students'] as int? ?? 0,
      totalSessions: json['total_sessions'] as int? ?? 0,
      totalCourses: json['total_courses'] as int? ?? 0,
      hourlyRate: (json['hourly_rate'] as num?)?.toDouble() ?? 0.0,
      isVerified: json['is_verified'] as bool? ?? false,
      isFeatured: json['is_featured'] as bool? ?? false,
      isAvailable: json['is_available'] as bool? ?? true,
      availability: json['availability'] != null
          ? TeacherAvailability.fromJson(
              json['availability'] as Map<String, dynamic>,
            )
          : const TeacherAvailability(),
      certificates: (json['certificates'] as List<dynamic>?)
              ?.map(
                (e) => TeacherCertificate.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'phone': phone,
      'avatar': avatar,
      'bio': bio,
      'subjects': subjects,
      'languages': languages,
      'education': education,
      'experience_years': experienceYears,
      'rating': rating,
      'total_reviews': totalReviews,
      'total_students': totalStudents,
      'total_sessions': totalSessions,
      'total_courses': totalCourses,
      'hourly_rate': hourlyRate,
      'is_verified': isVerified,
      'is_featured': isFeatured,
      'is_available': isAvailable,
      'availability': availability.toJson(),
      'certificates': certificates.map((e) => e.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  TeacherModel copyWith({
    String? id,
    String? email,
    String? fullName,
    String? phone,
    String? avatar,
    String? bio,
    List<String>? subjects,
    List<String>? languages,
    String? education,
    int? experienceYears,
    double? rating,
    int? totalReviews,
    int? totalStudents,
    int? totalSessions,
    int? totalCourses,
    double? hourlyRate,
    bool? isVerified,
    bool? isFeatured,
    bool? isAvailable,
    TeacherAvailability? availability,
    List<TeacherCertificate>? certificates,
    DateTime? createdAt,
  }) {
    return TeacherModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      avatar: avatar ?? this.avatar,
      bio: bio ?? this.bio,
      subjects: subjects ?? this.subjects,
      languages: languages ?? this.languages,
      education: education ?? this.education,
      experienceYears: experienceYears ?? this.experienceYears,
      rating: rating ?? this.rating,
      totalReviews: totalReviews ?? this.totalReviews,
      totalStudents: totalStudents ?? this.totalStudents,
      totalSessions: totalSessions ?? this.totalSessions,
      totalCourses: totalCourses ?? this.totalCourses,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      isVerified: isVerified ?? this.isVerified,
      isFeatured: isFeatured ?? this.isFeatured,
      isAvailable: isAvailable ?? this.isAvailable,
      availability: availability ?? this.availability,
      certificates: certificates ?? this.certificates,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Get formatted rating
  String get formattedRating => rating.toStringAsFixed(1);

  /// Get experience text
  String get experienceText {
    if (experienceYears == 0) return 'experience_new'.tr;
    if (experienceYears == 1) return 'experience_one_year'.tr;
    if (experienceYears == 2) return 'experience_two_years'.tr;
    if (experienceYears <= 10) return 'experience_years_count'.trParams({'count': experienceYears.toString()});
    return '$experienceYears ${'experience_year'.tr}';
  }
}

/// Teacher availability model
class TeacherAvailability {
  final List<DayAvailability> days;
  final String timezone;

  const TeacherAvailability({
    this.days = const [],
    this.timezone = 'Asia/Riyadh',
  });

  factory TeacherAvailability.fromJson(Map<String, dynamic> json) {
    return TeacherAvailability(
      days: (json['days'] as List<dynamic>?)
              ?.map((e) => DayAvailability.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      timezone: json['timezone'] as String? ?? 'Asia/Riyadh',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'days': days.map((e) => e.toJson()).toList(),
      'timezone': timezone,
    };
  }
}

/// Day availability model
class DayAvailability {
  final int day; // 1 = Monday, 7 = Sunday
  final List<TimeSlot> slots;
  final bool isAvailable;

  const DayAvailability({
    required this.day,
    this.slots = const [],
    this.isAvailable = true,
  });

  factory DayAvailability.fromJson(Map<String, dynamic> json) {
    return DayAvailability(
      day: json['day'] as int,
      slots: (json['slots'] as List<dynamic>?)
              ?.map((e) => TimeSlot.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      isAvailable: json['is_available'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'slots': slots.map((e) => e.toJson()).toList(),
      'is_available': isAvailable,
    };
  }

  String get dayName {
    switch (day) {
      case 1:
        return 'weekday_monday'.tr;
      case 2:
        return 'weekday_tuesday'.tr;
      case 3:
        return 'weekday_wednesday'.tr;
      case 4:
        return 'weekday_thursday'.tr;
      case 5:
        return 'weekday_friday'.tr;
      case 6:
        return 'weekday_saturday'.tr;
      case 7:
        return 'weekday_sunday'.tr;
      default:
        return '';
    }
  }
}

/// Time slot model
class TimeSlot {
  final String start; // HH:mm format
  final String end; // HH:mm format
  final bool isBooked;

  const TimeSlot({
    required this.start,
    required this.end,
    this.isBooked = false,
  });

  factory TimeSlot.fromJson(Map<String, dynamic> json) {
    return TimeSlot(
      start: json['start'] as String,
      end: json['end'] as String,
      isBooked: json['is_booked'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'start': start,
      'end': end,
      'is_booked': isBooked,
    };
  }

  String get formatted => '$start - $end';
}

/// Teacher certificate model
class TeacherCertificate {
  final String id;
  final String name;
  final String issuer;
  final DateTime issuedDate;
  final String? image;
  final bool isVerified;

  const TeacherCertificate({
    required this.id,
    required this.name,
    required this.issuer,
    required this.issuedDate,
    this.image,
    this.isVerified = false,
  });

  factory TeacherCertificate.fromJson(Map<String, dynamic> json) {
    return TeacherCertificate(
      id: json['id'] as String,
      name: json['name'] as String,
      issuer: json['issuer'] as String,
      issuedDate: DateTime.parse(json['issued_date'] as String),
      image: json['image'] as String?,
      isVerified: json['is_verified'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'issuer': issuer,
      'issued_date': issuedDate.toIso8601String(),
      'image': image,
      'is_verified': isVerified,
    };
  }
}

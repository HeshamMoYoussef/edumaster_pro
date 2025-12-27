import 'package:get/get.dart';

/// User model representing a student or parent
class UserModel {
  final String id;
  final String email;
  final String fullName;
  final String? phone;
  final String? avatar;
  final UserRole role;
  final int level;
  final int points;
  final int eduCoins;
  final int streak;
  final DateTime? dateOfBirth;
  final String? bio;
  final List<String> interests;
  final UserStats stats;
  final DateTime createdAt;
  final DateTime? lastActiveAt;
  final bool isVerified;
  final bool isPremium;
  final String? parentId;

  const UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    this.phone,
    this.avatar,
    this.role = UserRole.student,
    this.level = 1,
    this.points = 0,
    this.eduCoins = 0,
    this.streak = 0,
    int? currentStreak,
    this.dateOfBirth,
    this.bio,
    this.interests = const [],
    this.stats = const UserStats(),
    required this.createdAt,
    this.lastActiveAt,
    this.isVerified = false,
    this.isPremium = false,
    this.parentId,
  }) : assert(currentStreak == null || currentStreak == streak, 'Use streak parameter');

  /// Alias for streak
  int get currentStreak => streak;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String,
      phone: json['phone'] as String?,
      avatar: json['avatar'] as String?,
      role: UserRole.fromString(json['role'] as String? ?? 'student'),
      level: json['level'] as int? ?? 1,
      points: json['points'] as int? ?? 0,
      eduCoins: json['edu_coins'] as int? ?? 0,
      streak: json['streak'] as int? ?? 0,
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.parse(json['date_of_birth'] as String)
          : null,
      bio: json['bio'] as String?,
      interests: (json['interests'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      stats: json['stats'] != null
          ? UserStats.fromJson(json['stats'] as Map<String, dynamic>)
          : const UserStats(),
      createdAt: DateTime.parse(json['created_at'] as String),
      lastActiveAt: json['last_active_at'] != null
          ? DateTime.parse(json['last_active_at'] as String)
          : null,
      isVerified: json['is_verified'] as bool? ?? false,
      isPremium: json['is_premium'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'phone': phone,
      'avatar': avatar,
      'role': role.value,
      'level': level,
      'points': points,
      'edu_coins': eduCoins,
      'streak': streak,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'bio': bio,
      'interests': interests,
      'stats': stats.toJson(),
      'created_at': createdAt.toIso8601String(),
      'last_active_at': lastActiveAt?.toIso8601String(),
      'is_verified': isVerified,
      'is_premium': isPremium,
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? fullName,
    String? phone,
    String? avatar,
    UserRole? role,
    int? level,
    int? points,
    int? eduCoins,
    int? streak,
    DateTime? dateOfBirth,
    String? bio,
    List<String>? interests,
    UserStats? stats,
    DateTime? createdAt,
    DateTime? lastActiveAt,
    bool? isVerified,
    bool? isPremium,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      avatar: avatar ?? this.avatar,
      role: role ?? this.role,
      level: level ?? this.level,
      points: points ?? this.points,
      eduCoins: eduCoins ?? this.eduCoins,
      streak: streak ?? this.streak,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      bio: bio ?? this.bio,
      interests: interests ?? this.interests,
      stats: stats ?? this.stats,
      createdAt: createdAt ?? this.createdAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      isVerified: isVerified ?? this.isVerified,
      isPremium: isPremium ?? this.isPremium,
    );
  }

  /// Get level title based on current level
  String get levelTitle {
    if (level <= 10) return 'level_curious_learner'.tr;
    if (level <= 20) return 'level_knowledge_seeker'.tr;
    if (level <= 30) return 'level_rising_star'.tr;
    if (level <= 40) return 'level_dedicated_scholar'.tr;
    if (level <= 50) return 'level_expert_learner'.tr;
    if (level <= 60) return 'level_master_mind'.tr;
    if (level <= 70) return 'level_academic_champion'.tr;
    if (level <= 80) return 'level_knowledge_hero'.tr;
    if (level <= 90) return 'level_legendary_scholar'.tr;
    return 'level_grand_master'.tr;
  }

  /// Progress to next level (0.0 to 1.0)
  double get levelProgress {
    const pointsPerLevel = 1000;
    return (points % pointsPerLevel) / pointsPerLevel;
  }

  /// Points needed for next level
  int get pointsToNextLevel {
    const pointsPerLevel = 1000;
    return pointsPerLevel - (points % pointsPerLevel);
  }
}

/// User role enum
enum UserRole {
  student('student'),
  parent('parent'),
  teacher('teacher'),
  admin('admin');

  final String value;
  const UserRole(this.value);

  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (e) => e.value == value,
      orElse: () => UserRole.student,
    );
  }
}

/// User statistics
class UserStats {
  final int completedCourses;
  final int completedLessons;
  final int completedQuizzes;
  final int totalStudyMinutes;
  final int sessionsAttended;
  final int certificatesEarned;
  final int badgesEarned;
  final double averageQuizScore;

  const UserStats({
    this.completedCourses = 0,
    this.completedLessons = 0,
    this.completedQuizzes = 0,
    this.totalStudyMinutes = 0,
    this.sessionsAttended = 0,
    this.certificatesEarned = 0,
    this.badgesEarned = 0,
    this.averageQuizScore = 0.0,
    int? totalCoursesCompleted,
    int? totalLessonsCompleted,
    int? totalStudyTimeMinutes,
    int? totalQuizzesTaken,
  });

  /// Aliases for compatibility
  int get totalCoursesCompleted => completedCourses;
  int get totalLessonsCompleted => completedLessons;
  int get totalStudyTimeMinutes => totalStudyMinutes;
  int get totalQuizzesTaken => completedQuizzes;

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      completedCourses: json['completed_courses'] as int? ?? 0,
      completedLessons: json['completed_lessons'] as int? ?? 0,
      completedQuizzes: json['completed_quizzes'] as int? ?? 0,
      totalStudyMinutes: json['total_study_minutes'] as int? ?? 0,
      sessionsAttended: json['sessions_attended'] as int? ?? 0,
      certificatesEarned: json['certificates_earned'] as int? ?? 0,
      badgesEarned: json['badges_earned'] as int? ?? 0,
      averageQuizScore: (json['average_quiz_score'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'completed_courses': completedCourses,
      'completed_lessons': completedLessons,
      'completed_quizzes': completedQuizzes,
      'total_study_minutes': totalStudyMinutes,
      'sessions_attended': sessionsAttended,
      'certificates_earned': certificatesEarned,
      'badges_earned': badgesEarned,
      'average_quiz_score': averageQuizScore,
    };
  }

  /// Get total study hours
  double get totalStudyHours => totalStudyMinutes / 60;
}

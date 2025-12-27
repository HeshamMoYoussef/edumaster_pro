import 'package:get/get.dart';

/// Achievement/Badge model
class AchievementModel {
  final String id;
  final String name;
  final String? title; // Alias for name
  final String description;
  final String icon;
  final AchievementType type;
  final AchievementRarity rarity;
  final int points;
  final int? requirement;
  final int? maxProgress; // Alias for requirement
  final String? requirementType;
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final double progress;

  const AchievementModel({
    required this.id,
    required this.name,
    this.title,
    required this.description,
    required this.icon,
    this.type = AchievementType.badge,
    this.rarity = AchievementRarity.common,
    this.points = 0,
    this.requirement,
    this.maxProgress,
    this.requirementType,
    this.isUnlocked = false,
    this.unlockedAt,
    this.progress = 0.0,
  });

  factory AchievementModel.fromJson(Map<String, dynamic> json) {
    return AchievementModel(
      id: json['id'] as String,
      name: json['name'] as String,
      title: json['title'] as String? ?? json['name'] as String,
      description: json['description'] as String,
      icon: json['icon'] as String,
      type: AchievementType.fromString(json['type'] as String? ?? 'badge'),
      rarity:
          AchievementRarity.fromString(json['rarity'] as String? ?? 'common'),
      points: json['points'] as int? ?? 0,
      requirement: json['requirement'] as int?,
      maxProgress: json['max_progress'] as int? ?? json['requirement'] as int?,
      requirementType: json['requirement_type'] as String?,
      isUnlocked: json['is_unlocked'] as bool? ?? false,
      unlockedAt: json['unlocked_at'] != null
          ? DateTime.parse(json['unlocked_at'] as String)
          : null,
      progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'type': type.value,
      'rarity': rarity.value,
      'points': points,
      'requirement': requirement,
      'requirement_type': requirementType,
      'is_unlocked': isUnlocked,
      'unlocked_at': unlockedAt?.toIso8601String(),
      'progress': progress,
    };
  }

  /// Get progress percentage (0-100)
  int get progressPercentage => (progress * 100).round().clamp(0, 100);

  /// Check if close to unlocking
  bool get isCloseToUnlock => progress >= 0.8 && !isUnlocked;
}

/// Achievement type enum
enum AchievementType {
  badge('badge', 'achievement_badge'),
  milestone('milestone', 'achievement_milestone'),
  streak('streak', 'achievement_streak'),
  challenge('challenge', 'achievement_challenge'),
  special('special', 'achievement_special'),
  skill('skill', 'achievement_skill');

  final String value;
  final String labelKey;
  const AchievementType(this.value, this.labelKey);

  String get label => labelKey.tr;

  static AchievementType fromString(String value) {
    return AchievementType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => AchievementType.badge,
    );
  }
}

/// Achievement rarity enum
enum AchievementRarity {
  common('common', 'rarity_common'),
  uncommon('uncommon', 'rarity_uncommon'),
  rare('rare', 'rarity_rare'),
  epic('epic', 'rarity_epic'),
  legendary('legendary', 'rarity_legendary');

  final String value;
  final String labelKey;
  const AchievementRarity(this.value, this.labelKey);

  String get label => labelKey.tr;

  static AchievementRarity fromString(String value) {
    return AchievementRarity.values.firstWhere(
      (e) => e.value == value,
      orElse: () => AchievementRarity.common,
    );
  }

  /// Get color hex for rarity
  int get colorValue {
    switch (this) {
      case AchievementRarity.common:
        return 0xFF94A3B8; // Gray
      case AchievementRarity.uncommon:
        return 0xFF10B981; // Green
      case AchievementRarity.rare:
        return 0xFF3B82F6; // Blue
      case AchievementRarity.epic:
        return 0xFF8B5CF6; // Purple
      case AchievementRarity.legendary:
        return 0xFFF59E0B; // Gold
    }
  }
}

/// Leaderboard entry model
class LeaderboardEntry {
  final int rank;
  final String odUserId;
  final String userName;
  final String? userAvatar;
  final int points;
  final int level;
  final bool isCurrentUser;

  const LeaderboardEntry({
    required this.rank,
    required this.odUserId,
    required this.userName,
    this.userAvatar,
    required this.points,
    required this.level,
    this.isCurrentUser = false,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      rank: json['rank'] as int,
      odUserId: json['user_id'] as String,
      userName: json['user_name'] as String,
      userAvatar: json['user_avatar'] as String?,
      points: json['points'] as int,
      level: json['level'] as int,
      isCurrentUser: json['is_current_user'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rank': rank,
      'user_id': odUserId,
      'user_name': userName,
      'user_avatar': userAvatar,
      'points': points,
      'level': level,
      'is_current_user': isCurrentUser,
    };
  }

  /// Check if user is in top 3
  bool get isTopThree => rank <= 3;
}

/// Daily challenge model
class DailyChallengeModel {
  final String id;
  final String title;
  final String description;
  final ChallengeType type;
  final int target;
  final int current;
  final int rewardCoins;
  final int rewardPoints;
  final DateTime expiresAt;
  final bool isCompleted;
  final bool isClaimed;

  const DailyChallengeModel({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.target,
    this.current = 0,
    this.rewardCoins = 0,
    this.rewardPoints = 0,
    required this.expiresAt,
    this.isCompleted = false,
    this.isClaimed = false,
  });

  factory DailyChallengeModel.fromJson(Map<String, dynamic> json) {
    return DailyChallengeModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      type: ChallengeType.fromString(json['type'] as String),
      target: json['target'] as int,
      current: json['current'] as int? ?? 0,
      rewardCoins: json['reward_coins'] as int? ?? 0,
      rewardPoints: json['reward_points'] as int? ?? 0,
      expiresAt: DateTime.parse(json['expires_at'] as String),
      isCompleted: json['is_completed'] as bool? ?? false,
      isClaimed: json['is_claimed'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.value,
      'target': target,
      'current': current,
      'reward_coins': rewardCoins,
      'reward_points': rewardPoints,
      'expires_at': expiresAt.toIso8601String(),
      'is_completed': isCompleted,
      'is_claimed': isClaimed,
    };
  }

  /// Get progress (0.0 to 1.0)
  double get progress => (current / target).clamp(0.0, 1.0);

  /// Get progress percentage
  int get progressPercentage => (progress * 100).round();

  /// Check if challenge is expired
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  /// Check if reward can be claimed
  bool get canClaim => isCompleted && !isClaimed && !isExpired;
}

/// Challenge type enum
enum ChallengeType {
  watchLessons('watch_lessons', 'challenge_watch_lessons'),
  completeQuizzes('complete_quizzes', 'challenge_complete_quizzes'),
  earnPoints('earn_points', 'challenge_earn_points'),
  studyMinutes('study_minutes', 'challenge_study_minutes'),
  helpOthers('help_others', 'challenge_help_others'),
  dailyLogin('daily_login', 'challenge_daily_login');

  final String value;
  final String labelKey;
  const ChallengeType(this.value, this.labelKey);

  String get label => labelKey.tr;

  static ChallengeType fromString(String value) {
    return ChallengeType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ChallengeType.watchLessons,
    );
  }
}

/// Streak model
class StreakModel {
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastActiveDate;
  final DateTime? lastCheckIn;
  final int totalCheckIns;
  final List<DateTime> activeDays;

  const StreakModel({
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastActiveDate,
    this.lastCheckIn,
    this.totalCheckIns = 0,
    this.activeDays = const [],
  });

  factory StreakModel.fromJson(Map<String, dynamic> json) {
    return StreakModel(
      currentStreak: json['current_streak'] as int? ?? 0,
      longestStreak: json['longest_streak'] as int? ?? 0,
      lastActiveDate: json['last_active_date'] != null
          ? DateTime.parse(json['last_active_date'] as String)
          : null,
      lastCheckIn: json['last_check_in'] != null
          ? DateTime.parse(json['last_check_in'] as String)
          : null,
      totalCheckIns: json['total_check_ins'] as int? ?? 0,
      activeDays: (json['active_days'] as List<dynamic>?)
              ?.map((e) => DateTime.parse(e as String))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current_streak': currentStreak,
      'longest_streak': longestStreak,
      'last_active_date': lastActiveDate?.toIso8601String(),
      'active_days': activeDays.map((e) => e.toIso8601String()).toList(),
    };
  }

  /// Check if streak is active today
  bool get isActiveToday {
    if (lastActiveDate == null) return false;
    final now = DateTime.now();
    return lastActiveDate!.year == now.year &&
        lastActiveDate!.month == now.month &&
        lastActiveDate!.day == now.day;
  }

  /// Check if streak is at risk (not active today but was yesterday)
  bool get isAtRisk {
    if (lastActiveDate == null || currentStreak == 0) return false;
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return lastActiveDate!.year == yesterday.year &&
        lastActiveDate!.month == yesterday.month &&
        lastActiveDate!.day == yesterday.day;
  }
}

import 'package:get/get.dart';

import '../../config/env_config.dart';
import '../../core/network/api_client.dart';
import '../../core/constants/api_constants.dart';
import '../models/achievement_model.dart';
import '../mock/mock_data.dart';

/// Achievement repository
class AchievementRepository {
  final ApiClient _api = Get.find();
  bool get _useMock => EnvConfig.useMockData;

  /// Get user achievements
  Future<List<AchievementModel>> getMyAchievements() async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 500));
      return MockData.achievements;
    }

    final response = await _api.get(ApiConstants.achievements);
    return (response.data['data'] as List)
        .map((e) => AchievementModel.fromJson(e))
        .toList();
  }

  /// Get all available achievements
  Future<List<AchievementModel>> getAllAchievements() async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 500));
      // Return more achievements including locked ones
      return [
        ...MockData.achievements,
        const AchievementModel(
          id: 'ach_locked_1',
          name: 'متعلم محترف',
          description: 'أكمل 50 كورس',
          icon: 'professional',
          type: AchievementType.milestone,
          rarity: AchievementRarity.legendary,
          points: 5000,
          isUnlocked: false,
          progress: 0.24,
          requirement: 50,
        ),
        const AchievementModel(
          id: 'ach_locked_2',
          name: 'ملك الاختبارات',
          description: 'احصل على 100% في 20 اختبار',
          icon: 'quiz_king',
          type: AchievementType.skill,
          rarity: AchievementRarity.epic,
          points: 3000,
          isUnlocked: false,
          progress: 0.25,
          requirement: 20,
        ),
      ];
    }

    final response = await _api.get('${ApiConstants.achievements}/all');
    return (response.data['data'] as List)
        .map((e) => AchievementModel.fromJson(e))
        .toList();
  }

  /// Get leaderboard
  Future<List<LeaderboardEntry>> getLeaderboard({
    String period = 'weekly', // 'daily', 'weekly', 'monthly', 'all_time'
    int limit = 100,
  }) async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 500));
      return MockData.leaderboard;
    }

    final response = await _api.get(
      ApiConstants.leaderboard,
      queryParameters: {
        'period': period,
        'limit': limit,
      },
    );

    return (response.data['data'] as List)
        .map((e) => LeaderboardEntry.fromJson(e))
        .toList();
  }

  /// Get user rank
  Future<int> getMyRank({String period = 'weekly'}) async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      return 15; // Mock rank
    }

    final response = await _api.get(
      '${ApiConstants.leaderboard}/my-rank',
      queryParameters: {'period': period},
    );

    return response.data['rank'];
  }

  /// Get daily challenges
  Future<List<DailyChallengeModel>> getDailyChallenges() async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 500));
      return MockData.dailyChallenges;
    }

    final response = await _api.get(ApiConstants.dailyChallenges);
    return (response.data['data'] as List)
        .map((e) => DailyChallengeModel.fromJson(e))
        .toList();
  }

  /// Complete daily challenge
  Future<AchievementModel?> completeDailyChallenge(String challengeId) async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 500));
      // Return achievement if challenge completion unlocks one
      return null;
    }

    final response = await _api.post(
      '${ApiConstants.dailyChallenges}/$challengeId/complete',
    );

    if (response.data['achievement'] != null) {
      return AchievementModel.fromJson(response.data['achievement']);
    }
    return null;
  }

  /// Get user streak
  Future<StreakModel> getStreak() async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      return MockData.streak;
    }

    final response = await _api.get('${ApiConstants.achievements}/streak');
    return StreakModel.fromJson(response.data);
  }

  /// Check in for streak
  Future<StreakModel> checkIn() async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 500));
      return StreakModel(
        currentStreak: MockData.streak.currentStreak + 1,
        longestStreak: MockData.streak.longestStreak,
        lastCheckIn: DateTime.now(),
        totalCheckIns: MockData.streak.totalCheckIns + 1,
      );
    }

    final response = await _api.post('${ApiConstants.achievements}/check-in');
    return StreakModel.fromJson(response.data);
  }

  /// Claim achievement reward
  Future<void> claimReward(String achievementId) async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 500));
      return;
    }

    await _api.post('${ApiConstants.achievements}/$achievementId/claim');
  }
}

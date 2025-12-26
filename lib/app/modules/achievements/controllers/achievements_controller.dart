import 'package:get/get.dart';
import '../../../data/models/achievement_model.dart';
import '../../../data/repositories/achievement_repository.dart';

class AchievementsController extends GetxController {
  final AchievementRepository _achievementRepo = Get.find();

  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  final _achievements = <AchievementModel>[].obs;
  List<AchievementModel> get achievements => _achievements;

  final _leaderboard = <LeaderboardEntry>[].obs;
  List<LeaderboardEntry> get leaderboard => _leaderboard;

  @override
  void onInit() {
    super.onInit();
    loadAchievements();
    loadLeaderboard();
  }

  Future<void> loadAchievements() async {
    _isLoading.value = true;
    try {
      _achievements.value = await _achievementRepo.getAllAchievements();
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> loadLeaderboard() async {
    try {
      _leaderboard.value = await _achievementRepo.getLeaderboard();
    } catch (e) {
      // Handle error
    }
  }
}

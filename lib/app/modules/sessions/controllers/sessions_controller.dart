import 'package:get/get.dart';
import '../../../data/models/session_model.dart';
import '../../../data/repositories/session_repository.dart';

class SessionsController extends GetxController {
  final SessionRepository _sessionRepo = Get.find();

  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  final _sessions = <SessionModel>[].obs;
  List<SessionModel> get sessions => _sessions;

  final _selectedSession = Rxn<SessionModel>();
  SessionModel? get selectedSession => _selectedSession.value;

  @override
  void onInit() {
    super.onInit();
    loadSessions();
  }

  Future<void> loadSessions() async {
    _isLoading.value = true;
    try {
      _sessions.value = await _sessionRepo.getMySessions();
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> loadSessionDetails(String id) async {
    _isLoading.value = true;
    try {
      _selectedSession.value = await _sessionRepo.getSessionById(id);
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> cancelSession(String id) async {
    try {
      await _sessionRepo.cancelSession(id);
      loadSessions();
    } catch (e) {
      // Handle error
    }
  }
}

import 'package:get/get.dart';

import '../../../data/models/teacher_model.dart';
import '../../../data/repositories/teacher_repository.dart';

/// Teachers controller
class TeachersController extends GetxController {
  final TeacherRepository _teacherRepo = Get.find();

  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  final _teachers = <TeacherModel>[].obs;
  List<TeacherModel> get teachers => _teachers;

  final _selectedTeacher = Rxn<TeacherModel>();
  TeacherModel? get selectedTeacher => _selectedTeacher.value;

  final _searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadTeachers();
  }

  Future<void> loadTeachers() async {
    _isLoading.value = true;
    try {
      _teachers.value = await _teacherRepo.getTeachers(
        search: _searchQuery.value.isEmpty ? null : _searchQuery.value,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  void search(String query) {
    _searchQuery.value = query;
    loadTeachers();
  }

  Future<void> loadTeacherProfile(String teacherId) async {
    _isLoading.value = true;
    try {
      _selectedTeacher.value = await _teacherRepo.getTeacherById(teacherId);
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> toggleFavorite(String teacherId) async {
    try {
      // Toggle logic here
      await _teacherRepo.addToFavorites(teacherId);
    } catch (e) {
      // Handle error
    }
  }
}

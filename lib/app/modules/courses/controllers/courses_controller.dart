import 'package:get/get.dart';

import '../../../data/models/course_model.dart';
import '../../../data/repositories/course_repository.dart';

/// Courses controller
class CoursesController extends GetxController {
  final CourseRepository _courseRepo = Get.find();

  // Loading state
  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  // Data
  final _courses = <CourseModel>[].obs;
  List<CourseModel> get courses => _courses;

  final _categories = <CategoryModel>[].obs;
  List<CategoryModel> get categories => _categories;

  final _selectedCourse = Rxn<CourseModel>();
  CourseModel? get selectedCourse => _selectedCourse.value;

  // Filters
  final _selectedCategoryId = Rxn<String>();
  String? get selectedCategoryId => _selectedCategoryId.value;

  final _selectedLevel = Rxn<String>();
  String? get selectedLevel => _selectedLevel.value;

  final _searchQuery = ''.obs;
  String get searchQuery => _searchQuery.value;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    _isLoading.value = true;
    try {
      await Future.wait([
        _loadCategories(),
        _loadCourses(),
      ]);
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> _loadCategories() async {
    try {
      _categories.value = await _courseRepo.getCategories();
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _loadCourses() async {
    try {
      _courses.value = await _courseRepo.getCourses(
        categoryId: _selectedCategoryId.value,
        level: _selectedLevel.value,
        search: _searchQuery.value.isEmpty ? null : _searchQuery.value,
      );
    } catch (e) {
      // Handle error
    }
  }

  void setCategory(String? categoryId) {
    _selectedCategoryId.value = categoryId;
    _loadCourses();
  }

  void setLevel(String? level) {
    _selectedLevel.value = level;
    _loadCourses();
  }

  void search(String query) {
    _searchQuery.value = query;
    _loadCourses();
  }

  Future<void> loadCourseDetails(String courseId) async {
    _isLoading.value = true;
    try {
      _selectedCourse.value = await _courseRepo.getCourseById(courseId);
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> enrollInCourse(String courseId) async {
    try {
      await _courseRepo.enrollInCourse(courseId);
      // Refresh course details
      await loadCourseDetails(courseId);
    } catch (e) {
      // Handle error
    }
  }
}

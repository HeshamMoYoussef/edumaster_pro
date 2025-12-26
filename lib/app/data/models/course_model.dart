import 'teacher_model.dart';

/// Course model
class CourseModel {
  final String id;
  final String title;
  final String description;
  final String? thumbnail;
  final String? previewVideo;
  final String teacherId;
  final TeacherModel? teacher;
  final String categoryId;
  final CategoryModel? category;
  final CourseLevel level;
  final double price;
  final double? discountPrice;
  final int durationMinutes;
  final int totalLessons;
  final int totalQuizzes;
  final double rating;
  final int totalReviews;
  final int totalStudents;
  final List<String> tags;
  final List<String> requirements;
  final List<String> whatYouWillLearn;
  final List<LessonModel> lessons;
  final bool isFeatured;
  final bool isPublished;
  final bool hasCertificate;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const CourseModel({
    required this.id,
    required this.title,
    required this.description,
    this.thumbnail,
    this.previewVideo,
    required this.teacherId,
    this.teacher,
    required this.categoryId,
    this.category,
    this.level = CourseLevel.beginner,
    required this.price,
    this.discountPrice,
    this.durationMinutes = 0,
    this.totalLessons = 0,
    this.totalQuizzes = 0,
    this.rating = 0.0,
    this.totalReviews = 0,
    this.totalStudents = 0,
    this.tags = const [],
    this.requirements = const [],
    this.whatYouWillLearn = const [],
    this.lessons = const [],
    this.isFeatured = false,
    this.isPublished = true,
    this.hasCertificate = true,
    required this.createdAt,
    this.updatedAt,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      thumbnail: json['thumbnail'] as String?,
      previewVideo: json['preview_video'] as String?,
      teacherId: json['teacher_id'] as String,
      teacher: json['teacher'] != null
          ? TeacherModel.fromJson(json['teacher'] as Map<String, dynamic>)
          : null,
      categoryId: json['category_id'] as String,
      category: json['category'] != null
          ? CategoryModel.fromJson(json['category'] as Map<String, dynamic>)
          : null,
      level: CourseLevel.fromString(json['level'] as String? ?? 'beginner'),
      price: (json['price'] as num).toDouble(),
      discountPrice: (json['discount_price'] as num?)?.toDouble(),
      durationMinutes: json['duration_minutes'] as int? ?? 0,
      totalLessons: json['total_lessons'] as int? ?? 0,
      totalQuizzes: json['total_quizzes'] as int? ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      totalReviews: json['total_reviews'] as int? ?? 0,
      totalStudents: json['total_students'] as int? ?? 0,
      tags: (json['tags'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      requirements: (json['requirements'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      whatYouWillLearn: (json['what_you_will_learn'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      lessons: (json['lessons'] as List<dynamic>?)
              ?.map((e) => LessonModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      isFeatured: json['is_featured'] as bool? ?? false,
      isPublished: json['is_published'] as bool? ?? true,
      hasCertificate: json['has_certificate'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'thumbnail': thumbnail,
      'preview_video': previewVideo,
      'teacher_id': teacherId,
      'teacher': teacher?.toJson(),
      'category_id': categoryId,
      'category': category?.toJson(),
      'level': level.value,
      'price': price,
      'discount_price': discountPrice,
      'duration_minutes': durationMinutes,
      'total_lessons': totalLessons,
      'total_quizzes': totalQuizzes,
      'rating': rating,
      'total_reviews': totalReviews,
      'total_students': totalStudents,
      'tags': tags,
      'requirements': requirements,
      'what_you_will_learn': whatYouWillLearn,
      'lessons': lessons.map((e) => e.toJson()).toList(),
      'is_featured': isFeatured,
      'is_published': isPublished,
      'has_certificate': hasCertificate,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Check if course has discount
  bool get hasDiscount => discountPrice != null && discountPrice! < price;

  /// Get discount percentage
  int get discountPercentage {
    if (!hasDiscount) return 0;
    return ((1 - discountPrice! / price) * 100).round();
  }

  /// Get effective price
  double get effectivePrice => discountPrice ?? price;

  /// Get formatted duration
  String get formattedDuration {
    if (durationMinutes < 60) {
      return '$durationMinutes دقيقة';
    }
    final hours = durationMinutes ~/ 60;
    final minutes = durationMinutes % 60;
    if (minutes == 0) {
      return '$hours ${hours == 1 ? 'ساعة' : 'ساعات'}';
    }
    return '$hours:${minutes.toString().padLeft(2, '0')} ساعة';
  }

  /// Get formatted rating
  String get formattedRating => rating.toStringAsFixed(1);

  /// Check if course is free
  bool get isFree => price == 0;
}

/// Course level enum
enum CourseLevel {
  beginner('beginner', 'مبتدئ'),
  intermediate('intermediate', 'متوسط'),
  advanced('advanced', 'متقدم'),
  expert('expert', 'خبير');

  final String value;
  final String label;
  const CourseLevel(this.value, this.label);

  static CourseLevel fromString(String value) {
    return CourseLevel.values.firstWhere(
      (e) => e.value == value,
      orElse: () => CourseLevel.beginner,
    );
  }
}

/// Lesson model
class LessonModel {
  final String id;
  final String courseId;
  final String title;
  final String? description;
  final LessonType type;
  final int order;
  final int durationMinutes;
  final String? videoUrl;
  final String? content;
  final List<LessonResource> resources;
  final bool isFree;
  final bool isPublished;

  const LessonModel({
    required this.id,
    required this.courseId,
    required this.title,
    this.description,
    this.type = LessonType.video,
    required this.order,
    this.durationMinutes = 0,
    this.videoUrl,
    this.content,
    this.resources = const [],
    this.isFree = false,
    this.isPublished = true,
  });

  factory LessonModel.fromJson(Map<String, dynamic> json) {
    return LessonModel(
      id: json['id'] as String,
      courseId: json['course_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      type: LessonType.fromString(json['type'] as String? ?? 'video'),
      order: json['order'] as int,
      durationMinutes: json['duration_minutes'] as int? ?? 0,
      videoUrl: json['video_url'] as String?,
      content: json['content'] as String?,
      resources: (json['resources'] as List<dynamic>?)
              ?.map((e) => LessonResource.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      isFree: json['is_free'] as bool? ?? false,
      isPublished: json['is_published'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'course_id': courseId,
      'title': title,
      'description': description,
      'type': type.value,
      'order': order,
      'duration_minutes': durationMinutes,
      'video_url': videoUrl,
      'content': content,
      'resources': resources.map((e) => e.toJson()).toList(),
      'is_free': isFree,
      'is_published': isPublished,
    };
  }

  /// Get formatted duration
  String get formattedDuration {
    if (durationMinutes < 60) {
      return '$durationMinutes د';
    }
    final hours = durationMinutes ~/ 60;
    final minutes = durationMinutes % 60;
    return '$hours:${minutes.toString().padLeft(2, '0')}';
  }
}

/// Lesson type enum
enum LessonType {
  video('video', 'فيديو'),
  article('article', 'مقالة'),
  quiz('quiz', 'اختبار'),
  assignment('assignment', 'واجب'),
  live('live', 'بث مباشر');

  final String value;
  final String label;
  const LessonType(this.value, this.label);

  static LessonType fromString(String value) {
    return LessonType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => LessonType.video,
    );
  }
}

/// Lesson resource model
class LessonResource {
  final String id;
  final String name;
  final String type;
  final String url;
  final int? sizeBytes;

  const LessonResource({
    required this.id,
    required this.name,
    required this.type,
    required this.url,
    this.sizeBytes,
  });

  factory LessonResource.fromJson(Map<String, dynamic> json) {
    return LessonResource(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      url: json['url'] as String,
      sizeBytes: json['size_bytes'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'url': url,
      'size_bytes': sizeBytes,
    };
  }

  /// Get formatted size
  String get formattedSize {
    if (sizeBytes == null) return '';
    if (sizeBytes! < 1024) return '$sizeBytes B';
    if (sizeBytes! < 1024 * 1024) {
      return '${(sizeBytes! / 1024).toStringAsFixed(1)} KB';
    }
    return '${(sizeBytes! / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

/// Category model
class CategoryModel {
  final String id;
  final String name;
  final String? icon;
  final String? color;
  final int courseCount;

  const CategoryModel({
    required this.id,
    required this.name,
    this.icon,
    this.color,
    this.courseCount = 0,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String?,
      color: json['color'] as String?,
      courseCount: json['course_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'color': color,
      'course_count': courseCount,
    };
  }
}

/// Course enrollment model
class EnrollmentModel {
  final String id;
  final String userId;
  final String courseId;
  final CourseModel? course;
  final double progress;
  final int completedLessons;
  final DateTime enrolledAt;
  final DateTime? completedAt;
  final DateTime? lastAccessedAt;

  const EnrollmentModel({
    required this.id,
    required this.userId,
    required this.courseId,
    this.course,
    this.progress = 0.0,
    this.completedLessons = 0,
    required this.enrolledAt,
    this.completedAt,
    this.lastAccessedAt,
  });

  factory EnrollmentModel.fromJson(Map<String, dynamic> json) {
    return EnrollmentModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      courseId: json['course_id'] as String,
      course: json['course'] != null
          ? CourseModel.fromJson(json['course'] as Map<String, dynamic>)
          : null,
      progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
      completedLessons: json['completed_lessons'] as int? ?? 0,
      enrolledAt: DateTime.parse(json['enrolled_at'] as String),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      lastAccessedAt: json['last_accessed_at'] != null
          ? DateTime.parse(json['last_accessed_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'course_id': courseId,
      'course': course?.toJson(),
      'progress': progress,
      'completed_lessons': completedLessons,
      'enrolled_at': enrolledAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'last_accessed_at': lastAccessedAt?.toIso8601String(),
    };
  }

  /// Check if course is completed
  bool get isCompleted => completedAt != null || progress >= 100;

  /// Get progress percentage
  int get progressPercentage => progress.round();
}

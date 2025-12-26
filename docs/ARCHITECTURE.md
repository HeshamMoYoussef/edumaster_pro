# البنية التقنية - EduMaster Pro

## نظرة عامة

يتبع المشروع **Clean Architecture** مع **GetX Pattern** لضمان:
- فصل الاهتمامات (Separation of Concerns)
- قابلية الاختبار (Testability)
- قابلية التوسع (Scalability)
- سهولة الصيانة (Maintainability)

---

## طبقات التطبيق

```
┌─────────────────────────────────────────────────────────────┐
│                    Presentation Layer                        │
│         (Views, Controllers, Widgets, Bindings)              │
├─────────────────────────────────────────────────────────────┤
│                     Domain Layer                             │
│              (Repositories, Use Cases)                       │
├─────────────────────────────────────────────────────────────┤
│                      Data Layer                              │
│        (Models, Providers, Mock Data, API Client)            │
├─────────────────────────────────────────────────────────────┤
│                      Core Layer                              │
│    (Constants, Theme, Utils, Network, Extensions)            │
└─────────────────────────────────────────────────────────────┘
```

---

## 1. Core Layer

### Constants
```dart
// color_constants.dart
class AppColors {
  static const Color primary = Color(0xFF7C3AED);
  // ...
}

// app_constants.dart
class AppConstants {
  static const double paddingM = 16.0;
  // ...
}

// api_constants.dart
class ApiConstants {
  static const String login = '/auth/login';
  // ...
}
```

### Network Layer
```dart
// تدفق الطلب
Request → ApiClient → Interceptors → Server
                ↓
         Response/Error
                ↓
         Repository → Controller → View
```

**Interceptors:**
1. **AuthInterceptor** - إضافة Token للطلبات
2. **LoggingInterceptor** - تسجيل الطلبات (Development فقط)
3. **ErrorInterceptor** - معالجة الأخطاء
4. **RetryInterceptor** - إعادة المحاولة

### Utils
- `helpers.dart` - دوال مساعدة (تنسيق التاريخ، العملة، إلخ)
- `validators.dart` - Validators لـ Reactive Forms
- `storage_service.dart` - التخزين المحلي مع GetStorage

---

## 2. Data Layer

### Models
كل Model يحتوي على:
- Constructor
- `fromJson()` - تحويل من JSON
- `toJson()` - تحويل إلى JSON
- `copyWith()` - نسخ مع تعديل
- Helper methods

```dart
class UserModel {
  final String id;
  final String fullName;
  // ...

  factory UserModel.fromJson(Map<String, dynamic> json) { ... }
  Map<String, dynamic> toJson() { ... }
  UserModel copyWith({ ... }) { ... }

  // Helpers
  String get levelTitle { ... }
  double get levelProgress { ... }
}
```

### Repository Pattern
```dart
abstract class AuthRepository {
  Future<Result<User>> login(String email, String password);
  Future<Result<void>> logout();
}

class AuthRepositoryImpl implements AuthRepository {
  final ApiClient _api;
  final MockAuthProvider _mock;

  bool get _useMock => EnvConfig.useMockData;

  @override
  Future<Result<User>> login(String email, String password) async {
    try {
      final response = _useMock
          ? await _mock.login(email, password)
          : await _api.post('/auth/login', data: {...});

      return Result.success(User.fromJson(response.data));
    } catch (e) {
      return Result.failure(e);
    }
  }
}
```

---

## 3. Presentation Layer

### Module Structure
كل Module يتبع نفس الهيكل:
```
module_name/
├── bindings/
│   └── module_binding.dart
├── controllers/
│   └── module_controller.dart
└── views/
    ├── module_view.dart
    └── widgets/
        └── module_specific_widget.dart
```

### Controller (GetX)
```dart
class HomeController extends GetxController {
  // Dependencies
  final AuthRepository _authRepo = Get.find();

  // Observable State
  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  final _courses = <Course>[].obs;
  List<Course> get courses => _courses;

  // Lifecycle
  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  // Methods
  Future<void> loadData() async {
    _isLoading.value = true;
    try {
      _courses.value = await _courseRepo.getCourses();
    } finally {
      _isLoading.value = false;
    }
  }
}
```

### Binding (Dependency Injection)
```dart
class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(
      () => HomeController(),
      fenix: true, // Recreate if disposed
    );
  }
}
```

### View
```dart
class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (controller.isLoading) {
          return const LoadingWidget();
        }
        return ListView.builder(
          itemCount: controller.courses.length,
          itemBuilder: (context, index) {
            return CourseCard(course: controller.courses[index]);
          },
        );
      }),
    );
  }
}
```

---

## 4. Reactive Forms

### Form Definition
```dart
class AuthController extends GetxController {
  final loginForm = FormGroup({
    'email': FormControl<String>(
      validators: [
        Validators.required,
        Validators.email,
      ],
    ),
    'password': FormControl<String>(
      validators: [
        Validators.required,
        Validators.minLength(8),
      ],
    ),
  });
}
```

### Form Usage in View
```dart
ReactiveForm(
  formGroup: controller.loginForm,
  child: Column(
    children: [
      ReactiveTextField<String>(
        formControlName: 'email',
        decoration: InputDecoration(labelText: 'البريد الإلكتروني'),
        validationMessages: {
          'required': (error) => 'البريد الإلكتروني مطلوب',
          'email': (error) => 'بريد إلكتروني غير صالح',
        },
      ),
      ReactiveTextField<String>(
        formControlName: 'password',
        obscureText: true,
        decoration: InputDecoration(labelText: 'كلمة المرور'),
      ),
      ReactiveFormConsumer(
        builder: (context, form, child) {
          return ElevatedButton(
            onPressed: form.valid ? controller.login : null,
            child: Text('تسجيل الدخول'),
          );
        },
      ),
    ],
  ),
)
```

---

## 5. Navigation

### Route Definition
```dart
abstract class Routes {
  static const splash = '/splash';
  static const login = '/login';
  static const home = '/home';
  static const courseDetails = '/course/:id';

  static String courseDetailsPath(String id) => '/course/$id';
}
```

### Page Configuration
```dart
class AppPages {
  static final pages = [
    GetPage(
      name: Routes.login,
      page: () => const LoginView(),
      binding: AuthBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.home,
      page: () => const HomeView(),
      binding: HomeBinding(),
      middlewares: [AuthMiddleware()],
    ),
  ];
}
```

### Middleware
```dart
class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final storage = Get.find<StorageService>();
    if (!storage.isLoggedIn) {
      return const RouteSettings(name: Routes.login);
    }
    return null;
  }
}
```

---

## 6. State Management (GetX)

### أنواع Observables
```dart
// Simple Observable
final count = 0.obs;

// List Observable
final items = <Item>[].obs;

// Object Observable
final user = Rx<User?>(null);

// Custom Observable
final _loading = false.obs;
bool get isLoading => _loading.value;
set isLoading(bool val) => _loading.value = val;
```

### Reactive UI
```dart
// Obx - Simple
Obx(() => Text('${controller.count}'))

// GetBuilder - Non-reactive (manual update)
GetBuilder<Controller>(
  builder: (c) => Text('${c.value}'),
)

// GetX - With lifecycle
GetX<Controller>(
  init: Controller(),
  builder: (c) => Text('${c.value}'),
)
```

---

## 7. Dependency Injection

### Initial Binding
```dart
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Core Services (Permanent)
    Get.put(StorageService(), permanent: true);
    Get.put(ApiClient(), permanent: true);

    // Repositories (Lazy)
    Get.lazyPut(() => AuthRepository(), fenix: true);
    Get.lazyPut(() => CourseRepository(), fenix: true);
  }
}
```

### Get Methods
| Method | Description |
|--------|-------------|
| `Get.put()` | Immediate instantiation |
| `Get.lazyPut()` | Lazy instantiation |
| `Get.putAsync()` | Async instantiation |
| `Get.find()` | Get registered instance |
| `Get.delete()` | Remove instance |

---

## 8. Error Handling

### API Exceptions
```dart
abstract class ApiException {
  final String message;
  const ApiException(this.message);
}

class NetworkException extends ApiException { ... }
class UnauthorizedException extends ApiException { ... }
class ValidationException extends ApiException { ... }
```

### Result Pattern
```dart
sealed class Result<T> {
  const Result();

  factory Result.success(T data) = Success<T>;
  factory Result.failure(dynamic error) = Failure<T>;
}

class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

class Failure<T> extends Result<T> {
  final dynamic error;
  const Failure(this.error);
}
```

### Usage
```dart
final result = await repository.getData();

switch (result) {
  case Success(data: final data):
    // Handle success
    break;
  case Failure(error: final error):
    // Handle error
    break;
}
```

---

## 9. Theming

### Theme Definition
```dart
class AppTheme {
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.light(
      primary: AppColors.primary,
      // ...
    ),
    // Component themes...
  );

  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.dark(
      primary: AppColors.primary,
      // ...
    ),
    // Component themes...
  );
}
```

### Theme Switching
```dart
class ThemeController extends GetxController {
  final _themeMode = ThemeMode.system.obs;

  void setTheme(ThemeMode mode) {
    _themeMode.value = mode;
    Get.changeThemeMode(mode);
    storage.setThemeMode(mode.index);
  }
}
```

---

## 10. Localization

### Translation Files
```dart
// ar_SA.dart
const Map<String, String> arSA = {
  'login': 'تسجيل الدخول',
  'email': 'البريد الإلكتروني',
  // ...
};

// en_US.dart
const Map<String, String> enUS = {
  'login': 'Login',
  'email': 'Email',
  // ...
};
```

### Usage
```dart
// In View
Text('login'.tr)

// With parameters
Text('welcome_user'.trParams({'name': 'أحمد'}))

// Change locale
Get.updateLocale(const Locale('en', 'US'));
```

---

## Best Practices

### Do's ✅
- استخدم `GetView` بدلاً من `GetBuilder` للـ Views
- استخدم `lazyPut` مع `fenix: true` للـ Controllers
- افصل الـ Business Logic عن الـ UI
- استخدم Repository Pattern للبيانات
- اكتب Unit Tests للـ Controllers

### Don'ts ❌
- لا تضع Logic في الـ Views
- لا تستخدم `Get.put` للـ Controllers (استخدم Bindings)
- لا تخلط بين الـ Observables والـ Streams
- لا تنسى `onClose()` للتنظيف

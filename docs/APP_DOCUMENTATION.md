# EduMaster Pro - التوثيق الشامل للتطبيق

## نظرة عامة

**EduMaster Pro** هو تطبيق تعليمي متكامل مبني بـ Flutter، يوفر منصة تعليمية شاملة تربط بين الطلاب والمعلمين وأولياء الأمور.

### المميزات الرئيسية:
- نظام تسجيل دخول متعدد الأدوار (طالب، معلم، ولي أمر، مدير)
- دورات تعليمية مع فيديوهات واختبارات
- جلسات بث مباشر عبر Jitsi Meet
- نظام إنجازات وشارات مع نقاط
- محفظة رقمية مع عملة EduCoins
- معلم ذكي بالذكاء الاصطناعي
- لوحات تحكم منفصلة لكل دور

---

## 1. هيكل المشروع

```
edumaster_pro/
├── android/                    # إعدادات Android
├── ios/                        # إعدادات iOS
├── assets/                     # الموارد
│   ├── images/                # الصور
│   ├── icons/                 # الأيقونات
│   └── animations/            # ملفات Lottie
├── docs/                       # التوثيق
├── lib/                        # الكود الرئيسي
│   ├── main.dart              # نقطة البداية
│   └── app/                   # التطبيق
│       ├── config/            # الإعدادات
│       ├── core/              # النواة
│       ├── data/              # طبقة البيانات
│       ├── global/            # المكونات العامة
│       ├── modules/           # الميزات/الشاشات
│       ├── routes/            # التوجيه
│       └── translations/      # الترجمات
└── pubspec.yaml               # المكتبات
```

---

## 2. النواة (Core)

### 2.1 الثوابت (Constants)

#### `app_constants.dart`
```dart
// المسافات
paddingXS: 4, paddingS: 8, paddingM: 16, paddingL: 24, paddingXL: 32

// الحدود المستديرة
radiusS: 8, radiusM: 12, radiusL: 16, radiusXL: 24

// أحجام الأزرار
buttonHeightS: 45, buttonHeightM: 52, buttonHeightL: 60

// مكافآت EduCoins
dailyLoginReward: 5
lessonCompleteReward: 10
quizCompleteReward: 20
courseCompleteReward: 100
referralReward: 50

// النقاط والمستويات
pointsPerLevel: 1000
maxLevel: 100
```

#### `color_constants.dart`
```dart
// الألوان الأساسية
primary: #7C3AED (بنفسجي)
secondary: #F97316 (برتقالي)
accent: #06B6D4 (سماوي)

// ألوان الحالات
success: #10B981, warning: #F59E0B, error: #EF4444

// ألوان المواد الدراسية
math: #3B82F6, science: #10B981, language: #F97316
art: #EC4899, music: #8B5CF6, history: #F59E0B

// ألوان المستويات
beginner: أخضر, intermediate: ذهبي
advanced: أحمر, expert: بنفسجي
```

### 2.2 الثيم (Theme)

يدعم التطبيق **Light Mode** و **Dark Mode**:

```dart
// Light Theme
background: #F8FAFC
surface: #FFFFFF
textPrimary: #1E293B

// Dark Theme
background: #0F172A
surface: #1E293B
textPrimary: #F8FAFC
```

**الخط الأساسي:** Cairo (يدعم العربية)

### 2.3 الخدمات (Services)

#### `StorageService`
خدمة التخزين المحلي:
```dart
// حفظ المستخدم
saveUser(UserModel user)
getUser() → UserModel?

// التوكن
saveToken(String token)
getToken() → String?

// الإعدادات
getThemeMode() → String
setThemeMode(String mode)
getLocale() → String
setLocale(String locale)
```

#### `JitsiService`
خدمة البث المباشر:
```dart
// الانضمام لاجتماع
joinMeeting({
  roomName: String,
  userName: String,
  userEmail: String?,
  isAudioMuted: bool,
  isVideoMuted: bool,
  isHost: bool,
})

// مغادرة الاجتماع
leaveMeeting()

// الأحداث
setEventListeners({
  onConferenceJoined,
  onConferenceTerminated,
  onParticipantJoined,
  onParticipantLeft,
})
```

---

## 3. طبقة البيانات (Data Layer)

### 3.1 النماذج (Models)

#### `UserModel` - المستخدم
```dart
class UserModel {
  String id;
  String email;
  String fullName;
  String? phone;
  String? avatar;
  UserRole role;        // student, parent, teacher, admin
  int level;
  int points;
  int eduCoins;
  int streak;           // أيام الدراسة المتواصلة
  bool isPremium;
  UserStats? stats;
}
```

#### `CourseModel` - الدورة
```dart
class CourseModel {
  String id;
  String title;
  String description;
  String thumbnail;
  String teacherId;
  CourseLevel level;    // beginner, intermediate, advanced, expert
  double price;
  double? discountPrice;
  int totalLessons;
  int durationMinutes;
  double rating;
  int totalStudents;
  bool hasCertificate;
  List<LessonModel> lessons;
}
```

#### `TeacherModel` - المعلم
```dart
class TeacherModel {
  String id;
  String fullName;
  String bio;
  List<String> subjects;
  int experienceYears;
  double rating;
  int totalStudents;
  double hourlyRate;
  bool isVerified;
  bool isAvailable;
  TeacherAvailability availability;
}
```

#### `SessionModel` - الجلسة
```dart
class SessionModel {
  String id;
  String teacherId;
  String studentId;
  String subject;
  SessionType type;     // oneOnOne, group, workshop
  SessionStatus status; // pending, confirmed, inProgress, completed
  DateTime scheduledAt;
  int durationMinutes;
  double price;
  String? meetingUrl;
}
```

#### `AchievementModel` - الإنجاز
```dart
class AchievementModel {
  String id;
  String name;
  String description;
  String icon;
  AchievementType type;   // badge, milestone, streak
  AchievementRarity rarity; // common, rare, epic, legendary
  int points;
  bool isUnlocked;
  double progress;
}
```

#### `WalletModel` - المحفظة
```dart
class WalletModel {
  double balance;       // الرصيد بالريال
  int eduCoins;         // العملات الخاصة
  List<TransactionModel> transactions;
}
```

### 3.2 المستودعات (Repositories)

| Repository | الوظيفة |
|------------|---------|
| `AuthRepository` | تسجيل الدخول والتسجيل |
| `UserRepository` | بيانات المستخدم |
| `CourseRepository` | الدورات والدروس |
| `TeacherRepository` | المعلمين |
| `SessionRepository` | الجلسات المباشرة |
| `WalletRepository` | المحفظة والمعاملات |
| `AchievementRepository` | الإنجازات والشارات |

---

## 4. الوحدات (Modules)

### 4.1 وحدة المصادقة (Auth)

**الشاشات:**
- `LoginView` - تسجيل الدخول
- `RegisterView` - التسجيل
- `ForgotPasswordView` - نسيان كلمة المرور
- `OtpView` - التحقق بالرمز
- `ResetPasswordView` - إعادة تعيين كلمة المرور

**المتحكم:** `AuthController`
```dart
// تسجيل الدخول
login(email, password) → UserModel

// التسجيل
register(userData) → UserModel

// التحقق
verifyOtp(otp) → bool
resetPassword(newPassword) → bool

// تسجيل دخول سريع (للتطوير)
quickLoginAsStudent()
quickLoginAsParent()
quickLoginAsTeacher()
```

### 4.2 وحدة الصفحة الرئيسية (Home)

**المتحكم:** `HomeController`
```dart
// البيانات المحملة
featuredCourses      // الدورات المميزة
popularTeachers      // المعلمين الشائعين
upcomingSessions     // الجلسات القادمة
recentActivities     // الأنشطة الأخيرة
dailyChallenge       // التحدي اليومي
```

### 4.3 وحدة الدورات (Courses)

**الشاشات:**
- `CoursesView` - قائمة الدورات
- `CourseDetailsView` - تفاصيل الدورة
- `CoursePlayerView` - مشغل الفيديو
- `QuizView` - الاختبارات

**المتحكم:** `CoursesController`
```dart
getCourses({category, level, sortBy})
getCourseDetails(courseId)
enrollCourse(courseId)
markLessonComplete(lessonId)
submitQuiz(quizId, answers)
```

### 4.4 وحدة المعلمين (Teachers)

**الشاشات:**
- `TeachersView` - قائمة المعلمين
- `TeacherProfileView` - ملف المعلم
- `BookSessionView` - حجز جلسة

**المتحكم:** `TeachersController`
```dart
getTeachers({subject, rating, availability})
getTeacherProfile(teacherId)
getAvailableSlots(teacherId, date)
bookSession(teacherId, slot, subject)
```

### 4.5 وحدة الجلسات (Sessions)

**الشاشات:**
- `SessionsView` - قائمة الجلسات
- `SessionDetailsView` - تفاصيل الجلسة
- `LiveSessionView` - الجلسة المباشرة

**المتحكم:** `LiveSessionController`
```dart
// حالة الجلسة
isConnecting, isConnected
sessionTitle, duration

// التحكم
toggleMicrophone()
toggleCamera()
toggleScreenShare()
toggleWhiteboard()
toggleChat()
endSession()

// الدردشة
chatMessages
sendMessage(text)

// السبورة
drawingStrokes
addDrawingPoint(point)
clearWhiteboard()
```

### 4.6 وحدة المعلم الذكي (AI Tutor)

**الشاشات:**
- `AiTutorView` - المحادثة مع المعلم الذكي

**المتحكم:** `AiTutorController`
```dart
messages           // سجل المحادثة
sendMessage(text)  // إرسال رسالة
selectSubject()    // اختيار المادة
```

### 4.7 وحدة المحفظة (Wallet)

**الشاشات:**
- `WalletView` - المحفظة الرئيسية
- `TransactionsView` - سجل المعاملات
- `TopUpView` - شحن الرصيد

**المتحكم:** `WalletController`
```dart
balance           // الرصيد
eduCoins          // العملات
transactions      // المعاملات

topUp(amount)     // شحن
withdraw(amount)  // سحب
transfer(userId, amount)
convertCoins(coins)
```

### 4.8 وحدة الإنجازات (Achievements)

**الشاشات:**
- `AchievementsView` - الإنجازات والشارات
- `LeaderboardView` - لوحة المتصدرين
- `ChallengesView` - التحديات اليومية

**المتحكم:** `AchievementsController`
```dart
achievements      // جميع الإنجازات
unlockedBadges    // الشارات المفتوحة
dailyChallenge    // التحدي اليومي
leaderboard       // المتصدرين

claimReward(achievementId)
completeDailyChallenge()
```

### 4.9 لوحة تحكم ولي الأمر (Parent Dashboard)

**الشاشات:**
- `ParentDashboardView` - اللوحة الرئيسية
- `ChildProgressView` - تقدم الأبناء
- `ChildActivitiesView` - أنشطة الأبناء

**المتحكم:** `ParentController`
```dart
children          // قائمة الأبناء
selectedChild     // الابن المحدد

getChildProgress(childId)
getChildActivities(childId)
setStudyLimits(childId, limits)
```

### 4.10 لوحة تحكم المعلم (Teacher Dashboard)

**الشاشات:**
- `TeacherDashboardView` - اللوحة الرئيسية
  - `TeacherHomeTab` - الرئيسية
  - `TeacherSessionsTab` - الجلسات
  - `TeacherCoursesTab` - الدورات
  - `TeacherEarningsTab` - الأرباح
  - `SettingsView` - الإعدادات

**المتحكم:** `TeacherDashboardController`
```dart
upcomingSessions    // الجلسات القادمة
myCourses          // دوراتي
totalEarnings      // إجمالي الأرباح
monthlyEarnings    // أرباح الشهر

startSession(sessionId)
createCourse(courseData)
withdrawEarnings(amount)
```

---

## 5. نظام التوجيه (Routing)

### المسارات الرئيسية

```dart
// المصادقة
/splash              → SplashView
/onboarding          → OnboardingView
/login               → LoginView
/register            → RegisterView

// الرئيسية
/main                → MainView (مع NavigationBar)
/home                → HomeView

// الدورات
/courses             → CoursesView
/course/:id          → CourseDetailsView
/course/:id/player   → CoursePlayerView
/course/:id/quiz/:qid → QuizView

// المعلمين
/teachers            → TeachersView
/teacher/:id         → TeacherProfileView
/teacher/:id/book    → BookSessionView

// الجلسات
/sessions            → SessionsView
/session/:id         → SessionDetailsView
/session/:id/live    → LiveSessionView

// الإضافية
/ai-tutor            → AiTutorView
/wallet              → WalletView
/achievements        → AchievementsView
/leaderboard         → LeaderboardView
/profile             → ProfileView
/settings            → SettingsView
/notifications       → NotificationsView

// اللوحات الخاصة
/parent              → ParentDashboardView
/teacher-dashboard   → TeacherDashboardView
```

### التوجيه حسب الدور

```dart
// بعد تسجيل الدخول
switch (user.role) {
  case student → /main
  case parent  → /parent
  case teacher → /teacher-dashboard
  case admin   → /admin
}
```

---

## 6. إدارة الحالة (State Management)

### GetX Pattern

```dart
// المتحكم
class ExampleController extends GetxController {
  // Observable
  final _items = <Item>[].obs;
  List<Item> get items => _items;

  // Loading state
  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    _isLoading.value = true;
    _items.value = await repository.getItems();
    _isLoading.value = false;
  }
}

// في الواجهة
Obx(() => controller.isLoading
  ? LoadingWidget()
  : ListView.builder(...)
)
```

### الـ Bindings

```dart
class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => HomeController());
    Get.lazyPut(() => CoursesController());
  }
}
```

---

## 7. البث المباشر (Live Sessions)

### تقنية Jitsi Meet

**المميزات:**
- مجاني بالكامل
- بدون حدود للوقت
- كاميرا وميكروفون
- مشاركة الشاشة
- دردشة نصية
- تسجيل (يحتاج خادم خاص)

### الإعداد

**Android (build.gradle.kts):**
```kotlin
minSdk = 24  // مطلوب لـ Jitsi
```

**AndroidManifest.xml:**
```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.BLUETOOTH" />
```

### الاستخدام

```dart
// بدء جلسة
await jitsiService.joinMeeting(
  roomName: 'edumaster_session_123',
  userName: 'أحمد محمد',
  isHost: true,
);

// إنهاء جلسة
await jitsiService.leaveMeeting();
```

---

## 8. نظام النقاط والإنجازات

### كسب النقاط

| النشاط | النقاط |
|--------|--------|
| تسجيل دخول يومي | 5 |
| إكمال درس | 10 |
| إكمال اختبار | 20 |
| إكمال دورة | 100 |
| دعوة صديق | 50 |
| تحدي يومي | 25-50 |

### المستويات

```dart
المستوى = النقاط ÷ 1000
الحد الأقصى = 100 مستوى
```

### ندرة الشارات

| الندرة | اللون | النسبة |
|--------|-------|--------|
| عادي (Common) | رمادي | 60% |
| غير شائع (Uncommon) | أخضر | 25% |
| نادر (Rare) | أزرق | 10% |
| ملحمي (Epic) | بنفسجي | 4% |
| أسطوري (Legendary) | ذهبي | 1% |

---

## 9. المحفظة والمعاملات

### العملات

| العملة | الاستخدام |
|--------|-----------|
| **الرصيد (ريال)** | شراء الدورات، حجز الجلسات |
| **EduCoins** | مكافآت، خصومات، ميزات إضافية |

### أنواع المعاملات

```dart
enum TransactionCategory {
  coursePayment,    // شراء دورة
  sessionPayment,   // حجز جلسة
  deposit,          // إيداع
  withdrawal,       // سحب
  refund,           // استرداد
  reward,           // مكافأة
  referral,         // دعوة صديق
  dailyLogin,       // تسجيل دخول
  achievement,      // إنجاز
}
```

---

## 10. دعم اللغات

### اللغات المدعومة

- العربية (ar) - الافتراضية
- الإنجليزية (en)

### الاستخدام

```dart
// في الكود
'welcome'.tr  // يعيد الترجمة

// تغيير اللغة
localeController.changeLocale('en');
```

### دعم RTL

التطبيق يدعم الكتابة من اليمين لليسار بشكل كامل:
- تخطيط يتكيف تلقائياً
- أيقونات تنعكس عند الحاجة
- خط Cairo العربي

---

## 11. المكتبات المستخدمة

### إدارة الحالة
- `get: ^4.7.3` - GetX

### واجهة المستخدم
- `flutter_svg: ^2.2.3` - SVG
- `cached_network_image: ^3.4.1` - الصور
- `shimmer: ^3.0.0` - تأثير التحميل
- `lottie: ^3.3.2` - رسوميات متحركة
- `fl_chart: ^1.1.1` - رسوم بيانية
- `iconsax: ^0.0.8` - أيقونات

### الفيديو والبث
- `video_player: ^2.10.1` - مشغل الفيديو
- `chewie: ^1.13.0` - واجهة الفيديو
- `jitsi_meet_flutter_sdk: ^11.6.0` - البث المباشر

### التخزين والشبكة
- `get_storage: ^2.1.1` - التخزين المحلي
- `dio: ^5.9.0` - HTTP Client
- `connectivity_plus: ^7.0.0` - حالة الإنترنت

### الأدوات
- `reactive_forms: ^18.2.2` - النماذج
- `intl: ^0.20.2` - التنسيق
- `google_fonts: ^6.3.3` - الخطوط
- `url_launcher: ^6.3.2` - فتح الروابط
- `share_plus: ^12.0.1` - المشاركة
- `image_picker: ^1.2.1` - اختيار الصور

---

## 12. إعدادات Android

### `build.gradle.kts`
```kotlin
android {
    minSdk = 24           // مطلوب لـ Jitsi
    targetSdk = 34

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
}
```

### الأذونات (AndroidManifest.xml)
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
<uses-permission android:name="android.permission.BLUETOOTH" />
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
<uses-permission android:name="android.permission.WAKE_LOCK" />
```

---

## 13. أوامر التشغيل

```bash
# تثبيت المكتبات
flutter pub get

# تشغيل التطبيق
flutter run

# بناء APK
flutter build apk --release

# بناء App Bundle
flutter build appbundle --release

# تحليل الكود
flutter analyze

# تنظيف المشروع
flutter clean
```

---

## 14. ملاحظات للإنتاج

### قبل النشر:

1. **إزالة أزرار التطوير:**
   - أزرار تسجيل الدخول السريع
   - زر اختبار البث المباشر

2. **تغيير الإعدادات:**
   - `applicationId` فريد
   - مفاتيح API حقيقية
   - خادم API حقيقي

3. **الأمان:**
   - تفعيل ProGuard
   - إخفاء مفاتيح API
   - HTTPS فقط

4. **الاختبار:**
   - اختبار على أجهزة حقيقية
   - اختبار البث المباشر
   - اختبار الدفع

---

## 15. هيكل الملفات التفصيلي

```
lib/app/
├── config/
│   └── app_config.dart
├── core/
│   ├── constants/
│   │   ├── app_constants.dart
│   │   ├── api_constants.dart
│   │   ├── asset_constants.dart
│   │   └── color_constants.dart
│   ├── extensions/
│   │   └── string_extensions.dart
│   ├── network/
│   │   ├── api_client.dart
│   │   └── api_exceptions.dart
│   ├── services/
│   │   └── jitsi_service.dart
│   ├── theme/
│   │   ├── app_theme.dart
│   │   └── app_text_theme.dart
│   └── utils/
│       ├── storage_service.dart
│       ├── validators.dart
│       └── helpers.dart
├── data/
│   ├── models/
│   │   ├── user_model.dart
│   │   ├── course_model.dart
│   │   ├── teacher_model.dart
│   │   ├── session_model.dart
│   │   ├── achievement_model.dart
│   │   └── wallet_model.dart
│   ├── providers/
│   │   └── api_provider.dart
│   ├── repositories/
│   │   ├── auth_repository.dart
│   │   ├── user_repository.dart
│   │   ├── course_repository.dart
│   │   ├── teacher_repository.dart
│   │   ├── session_repository.dart
│   │   ├── wallet_repository.dart
│   │   └── achievement_repository.dart
│   └── mock/
│       └── mock_data.dart
├── global/
│   ├── bindings/
│   │   └── initial_binding.dart
│   ├── controllers/
│   │   ├── app_controller.dart
│   │   ├── theme_controller.dart
│   │   └── locale_controller.dart
│   ├── middlewares/
│   │   └── auth_middleware.dart
│   └── widgets/
│       ├── custom_button.dart
│       ├── custom_text_field.dart
│       ├── empty_state_widget.dart
│       └── loading_widget.dart
├── modules/
│   ├── splash/
│   ├── onboarding/
│   ├── auth/
│   ├── main/
│   ├── home/
│   ├── courses/
│   ├── teachers/
│   ├── sessions/
│   ├── ai_tutor/
│   ├── wallet/
│   ├── achievements/
│   ├── profile/
│   ├── settings/
│   ├── notifications/
│   ├── parent/
│   └── teacher_dashboard/
├── routes/
│   ├── app_pages.dart
│   └── app_routes.dart
└── translations/
    ├── app_translations.dart
    ├── ar.dart
    └── en.dart
```

---

## الخاتمة

**EduMaster Pro** هو تطبيق تعليمي متكامل يوفر تجربة تعليمية شاملة مع ميزات متقدمة مثل البث المباشر والإنجازات والمحفظة الرقمية. تم بناؤه باستخدام أفضل الممارسات في Flutter مع هيكلية نظيفة وقابلة للتوسع.

---

*آخر تحديث: ديسمبر 2024*

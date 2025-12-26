# EduMaster Pro

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)
![GetX](https://img.shields.io/badge/GetX-4.6.6-8B5CF6)
![License](https://img.shields.io/badge/License-MIT-green)

**منصة تعليمية متكاملة باللغة العربية**

[المميزات](#المميزات) | [التثبيت](#التثبيت) | [البنية](#البنية) | [التوثيق](#التوثيق)

</div>

---

## نظرة عامة

**EduMaster Pro** هي منصة تعليمية شاملة مبنية بـ Flutter، تقدم تجربة تعلم متكاملة للطلاب مع دعم للمعلمين وأولياء الأمور.

### الفئات المستهدفة

| الفئة | الميزات |
|-------|---------|
| **الطلاب** | كورسات، جلسات مباشرة، مساعد AI، إنجازات |
| **المعلمون** | إنشاء محتوى، جلسات خاصة، تقييمات |
| **أولياء الأمور** | متابعة الأبناء، تقارير، إشعارات |

---

## المميزات

### التعلم الذاتي
- مكتبة كورسات متنوعة
- دروس فيديو عالية الجودة
- تتبع التقدم التلقائي
- شهادات إتمام

### التعلم التفاعلي
- جلسات مباشرة مع المعلمين
- حجز مواعيد مرنة
- غرف محادثة خاصة

### المساعد الذكي (AI Tutor)
- إجابة الأسئلة فورياً
- شرح المفاهيم الصعبة
- اقتراحات مخصصة

### نظام التحفيز
- إنجازات وشارات
- لوحة المتصدرين
- تحديات يومية
- نقاط ومكافآت

### المحفظة الرقمية
- شحن الرصيد
- شراء الكورسات
- سجل المعاملات

### لوحة ولي الأمر
- متابعة تقدم الأبناء
- تقارير الاستخدام
- التحكم بالإعدادات

---

## التقنيات

| التقنية | الاستخدام |
|---------|-----------|
| **Flutter 3.x** | Framework |
| **Dart 3.x** | Language |
| **GetX** | State Management, DI, Navigation |
| **Reactive Forms** | Form Validation |
| **Dio** | HTTP Client |
| **GetStorage** | Local Storage |
| **Material 3** | Design System |

---

## التثبيت

### المتطلبات
- Flutter SDK 3.10+
- Dart SDK 3.0+

### الخطوات

```bash
# استنساخ المشروع
git clone https://github.com/your-username/edumaster_pro.git

# الدخول للمجلد
cd edumaster_pro

# تثبيت المكتبات
flutter pub get

# تشغيل التطبيق
flutter run
```

### تشغيل على أجهزة محددة

```bash
# Android
flutter run -d android

# iOS
flutter run -d ios

# Web
flutter run -d chrome

# Windows
flutter run -d windows
```

---

## البنية

```
lib/
├── main.dart                 # نقطة البداية
└── app/
    ├── core/                 # الطبقة الأساسية
    │   ├── config/          # إعدادات البيئات
    │   ├── constants/       # الثوابت
    │   ├── theme/           # الثيم
    │   ├── utils/           # الأدوات المساعدة
    │   └── network/         # HTTP Client
    │
    ├── data/                 # طبقة البيانات
    │   ├── models/          # النماذج
    │   ├── providers/       # Mock Data
    │   └── repositories/    # المستودعات
    │
    ├── global/               # المكونات العامة
    │   ├── bindings/        # DI Bindings
    │   ├── controllers/     # Global Controllers
    │   ├── middlewares/     # Route Guards
    │   └── widgets/         # Reusable Widgets
    │
    ├── modules/              # الوحدات (14 module)
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
    │   └── parent/
    │
    ├── routes/               # التنقل
    │   ├── app_routes.dart
    │   └── app_pages.dart
    │
    └── translations/         # الترجمات
        ├── ar_SA.dart
        ├── en_US.dart
        └── app_translations.dart
```

---

## الوحدات

| الوحدة | الوصف | الشاشات |
|--------|-------|---------|
| **Splash** | شاشة البداية | 1 |
| **Onboarding** | التعريف بالتطبيق | 1 (4 pages) |
| **Auth** | المصادقة | 4 (Login, Register, Forgot, OTP) |
| **Main** | التنقل الرئيسي | 1 |
| **Home** | الصفحة الرئيسية | 1 + 6 widgets |
| **Courses** | الكورسات | 3 (List, Details, Player) |
| **Teachers** | المعلمون | 2 (List, Profile) |
| **Sessions** | الجلسات | 2 (List, Details) |
| **AI Tutor** | المساعد الذكي | 1 |
| **Wallet** | المحفظة | 1 |
| **Achievements** | الإنجازات | 2 (List, Leaderboard) |
| **Profile** | الملف الشخصي | 2 (View, Edit) |
| **Settings** | الإعدادات | 1 |
| **Parent** | لوحة ولي الأمر | 1 |

---

## اللغات

يدعم التطبيق لغتين:

| اللغة | الكود | الاتجاه |
|-------|-------|---------|
| العربية | ar_SA | RTL |
| الإنجليزية | en_US | LTR |

### تغيير اللغة برمجياً

```dart
// التبديل للعربية
Get.updateLocale(const Locale('ar', 'SA'));

// التبديل للإنجليزية
Get.updateLocale(const Locale('en', 'US'));
```

---

## الثيم

يدعم التطبيق الوضع الفاتح والداكن:

```dart
// التبديل للوضع الداكن
Get.changeThemeMode(ThemeMode.dark);

// التبديل للوضع الفاتح
Get.changeThemeMode(ThemeMode.light);

// الوضع التلقائي (حسب النظام)
Get.changeThemeMode(ThemeMode.system);
```

---

## Mock Data

المشروع يعمل حالياً على بيانات وهمية (Mock Data) للتطوير والاختبار:

- 8 تصنيفات تعليمية
- 6+ معلمين
- 6+ كورسات
- 3+ جلسات مباشرة
- 6+ إنجازات
- تحديات يومية
- لوحة متصدرين

### التبديل للـ Backend الحقيقي

```dart
// في lib/app/core/config/env_config.dart
class EnvConfig {
  static const bool useMockData = false; // غيّر إلى false
  static const String baseUrl = 'https://api.edumaster.com';
}
```

---

## التوثيق

| الملف | الوصف |
|-------|-------|
| [ARCHITECTURE.md](docs/ARCHITECTURE.md) | البنية التقنية والأنماط |
| [PROGRESS.md](docs/PROGRESS.md) | تقدم التطوير |
| [PLAN.md](docs/PLAN.md) | خطة المشروع |

---

## الأوامر المفيدة

```bash
# تحليل الكود
flutter analyze

# تشغيل الاختبارات
flutter test

# بناء APK
flutter build apk --release

# بناء iOS
flutter build ios --release

# بناء Web
flutter build web --release

# تنظيف المشروع
flutter clean && flutter pub get
```

---

## المساهمة

1. Fork المشروع
2. أنشئ branch جديد (`git checkout -b feature/amazing-feature`)
3. Commit التغييرات (`git commit -m 'Add amazing feature'`)
4. Push للـ branch (`git push origin feature/amazing-feature`)
5. افتح Pull Request

---

## الترخيص

هذا المشروع مرخص تحت [MIT License](LICENSE).

---

## التواصل

- **البريد**: support@edumaster.com
- **الموقع**: https://edumaster.com

---

<div align="center">

**صُنع بـ Flutter**

</div>

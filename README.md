<div align="center">

# 🎓 EduMaster Pro

### A full-featured education platform — Flutter + GetX, Clean Architecture

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=flat-square&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=flat-square&logo=dart&logoColor=white)
![GetX](https://img.shields.io/badge/State-GetX_4.7-8A2BE2?style=flat-square)
![Clean Architecture](https://img.shields.io/badge/Architecture-Clean-6C757D?style=flat-square)
![Dio](https://img.shields.io/badge/Networking-Dio-13B9FD?style=flat-square)
![Reactive Forms](https://img.shields.io/badge/Forms-Reactive_Forms-FF6F00?style=flat-square)
![WebRTC](https://img.shields.io/badge/Live_Sessions-WebRTC-333333?style=flat-square)
![i18n](https://img.shields.io/badge/i18n-AR%2FEN-00C853?style=flat-square)
![License](https://img.shields.io/badge/License-MIT-green?style=flat-square)

[Features](#-features) · [Architecture](#-architecture) · [Installation](#-installation--production-setup) · [Modules](#-modules) · [Documentation](#-documentation)

</div>

---

## 📖 Overview

**EduMaster Pro** is a complete education platform serving three distinct audiences from one codebase — students, teachers, and parents — with course delivery, live 1:1 sessions over embedded WebRTC, an AI tutor, gamified achievements, and an in-app wallet.

| Audience | Capabilities |
|---|---|
| **Students** | Courses, live sessions, AI assistant, achievements & leaderboard |
| **Teachers** | Content creation, private sessions, assessments |
| **Parents** | Progress tracking, usage reports, notifications |

---

## ✨ Features

**Self-paced learning** — a course library with high-quality video lessons, automatic progress tracking, and completion certificates.

**Live interactive sessions** — book time with a teacher, join a private room over embedded WebRTC (no third-party video SDK dependency), with local notifications reminding both sides before the session starts.

**AI Tutor** — instant answers to student questions, on-demand concept explanations, and personalized study suggestions.

**Gamification** — badges and achievements, a leaderboard, daily challenges, and a points/rewards system to drive engagement.

**Digital wallet** — top up balance, purchase courses, and review a full transaction history.

**Parent dashboard** — track a child's progress, review usage reports, and control account settings from a separate parent view.

---

## 🏗 Architecture

**Clean Architecture** layered on top of **GetX** for state management, dependency injection, and navigation:

```
┌──────────────────────────────────────────────────────────────┐
│                    Presentation Layer                         │
│         Views, GetX Controllers, Widgets, Bindings            │
├──────────────────────────────────────────────────────────────┤
│                      Domain Layer                              │
│              Repository contracts, Use Cases                   │
├──────────────────────────────────────────────────────────────┤
│                       Data Layer                                │
│      Models, Repository implementations, Mock/API providers      │
├──────────────────────────────────────────────────────────────┤
│                       Core Layer                                 │
│     Constants, Theme, Utils, Network client, Extensions           │
└──────────────────────────────────────────────────────────────┘
```

```
lib/
├── main.dart
└── app/
    ├── core/                  # Cross-cutting: config, constants, theme, utils, network
    │   ├── config/                 # Environment config (mock vs. real backend)
    │   ├── constants/
    │   ├── theme/
    │   ├── utils/
    │   └── network/                # ApiClient + interceptors
    │
    ├── data/                  # Models, repository implementations, mock/API providers
    │   ├── models/
    │   ├── providers/               # Mock data providers (development/demo mode)
    │   └── repositories/
    │
    ├── global/                # Cross-module shared code
    │   ├── bindings/                # GetX dependency-injection bindings
    │   ├── controllers/              # App-wide controllers
    │   ├── middlewares/              # Route guards
    │   └── widgets/                  # Reusable UI components
    │
    ├── modules/               # 14 self-contained feature modules
    │   ├── splash/  onboarding/  auth/  main/  home/
    │   ├── courses/  teachers/  sessions/  ai_tutor/
    │   ├── wallet/  achievements/  profile/  settings/  parent/
    │
    ├── routes/                # app_routes.dart, app_pages.dart — GetX named routes
    └── translations/          # ar_SA.dart, en_US.dart, app_translations.dart
```

### Why this shape?

Every module follows the identical `bindings / controllers / views` structure, so a new feature (say, a 15th module) is a mechanical addition rather than an architectural decision — the pattern is already decided.

The interesting design choice is in the **Data layer**: each `RepositoryImpl` holds both a real `ApiClient` and a `MockProvider`, and switches between them based on a single `EnvConfig.useMockData` flag:

```dart
class AuthRepositoryImpl implements AuthRepository {
  final ApiClient _api;
  final MockAuthProvider _mock;
  bool get _useMock => EnvConfig.useMockData;

  @override
  Future<Result<User>> login(String email, String password) async {
    final response = _useMock
        ? await _mock.login(email, password)
        : await _api.post('/auth/login', data: {...});
    return Result.success(User.fromJson(response.data));
  }
}
```

This is dependency inversion doing real work: the app currently ships on mock data for demo/development, and flipping one constant in `env_config.dart` swaps every repository to the live backend — with zero changes to any controller or view, because they only ever depend on the abstract `Repository` contract, never on `ApiClient` or `MockProvider` directly.

### Network Layer

```
Request → ApiClient → Interceptors → Server
                            │
                    ┌───────┴────────┐
              AuthInterceptor   LoggingInterceptor
              (attach token)    (dev-only request/response logs)
                    │
              ErrorInterceptor  RetryInterceptor
              (normalize errors) (retry on transient failure)
                            │
                     Response/Error
                            │
              Repository → Controller → View
```

---

## 🚀 Installation & Production Setup

### Prerequisites

- Flutter SDK `3.10+`
- Dart SDK `^3.10.1`

### Local Development

```bash
git clone https://github.com/HeshamMoYoussef/edumaster_pro.git
cd edumaster_pro

flutter pub get
flutter run
```

### Run on a Specific Platform

```bash
flutter run -d android
flutter run -d ios
flutter run -d chrome    # Web
flutter run -d windows
```

### Switching from Mock Data to a Real Backend

The app ships running on mock data for development/demo purposes. To point it at a live API:

```dart
// lib/app/core/config/env_config.dart
class EnvConfig {
  static const bool useMockData = false; // set to false
  static const String baseUrl = 'https://api.edumaster.com';
}
```

### Useful Commands

```bash
flutter analyze              # static analysis
flutter test                 # run tests
flutter build apk --release  # Android APK
flutter build ios --release  # iOS
flutter build web --release  # Web
flutter clean && flutter pub get  # clean rebuild
```

---

## 📦 Modules

| Module | Description | Screens |
|---|---|---|
| **Splash** | App launch screen | 1 |
| **Onboarding** | App introduction | 1 (4 pages) |
| **Auth** | Authentication | 4 (Login, Register, Forgot Password, OTP) |
| **Main** | Root navigation shell | 1 |
| **Home** | Landing dashboard | 1 + 6 widgets |
| **Courses** | Course catalog & player | 3 (List, Details, Player) |
| **Teachers** | Teacher directory | 2 (List, Profile) |
| **Sessions** | Live session booking | 2 (List, Details) |
| **AI Tutor** | AI assistant | 1 |
| **Wallet** | Digital wallet | 1 |
| **Achievements** | Gamification | 2 (List, Leaderboard) |
| **Profile** | User profile | 2 (View, Edit) |
| **Settings** | App settings | 1 |
| **Parent** | Parent dashboard | 1 |

---

## 🌍 Localization & Theming

The app ships with full Arabic (RTL) and English (LTR) support out of the box:

| Language | Code | Direction |
|---|---|---|
| Arabic | `ar_SA` | RTL |
| English | `en_US` | LTR |

```dart
Get.updateLocale(const Locale('ar', 'SA'));   // switch to Arabic
Get.updateLocale(const Locale('en', 'US'));   // switch to English

Get.changeThemeMode(ThemeMode.dark);    // dark mode
Get.changeThemeMode(ThemeMode.light);   // light mode
Get.changeThemeMode(ThemeMode.system);  // follow system
```

---

## 🧪 Mock Data

The project currently runs on realistic mock data for development and demo purposes:

- 8 education categories
- 6+ teachers
- 6+ courses
- 3+ live sessions
- 6+ achievements
- Daily challenges
- Leaderboard

See [Switching from Mock Data to a Real Backend](#switching-from-mock-data-to-a-real-backend) above to point the app at a live API.

---

## 📦 Tech Stack

| Concern | Package |
|---|---|
| State / DI / Routing | `get` (GetX) |
| Forms | `reactive_forms` |
| Local Storage | `get_storage` |
| Networking | `dio`, `connectivity_plus` |
| Live Sessions | `flutter_webrtc`, `permission_handler` |
| Notifications | `flutter_local_notifications`, `timezone` |
| Media | `video_player`, `chewie`, `cached_network_image`, `image_picker` |
| UI/Animation | `flutter_animate`, `lottie`, `shimmer`, `iconsax`, `google_fonts` |
| Charts | `fl_chart` |
| Utilities | `intl`, `intl_phone_field`, `timeago`, `url_launcher`, `share_plus` |

---

## 📚 Documentation

| File | Description |
|---|---|
| [ARCHITECTURE.md](docs/ARCHITECTURE.md) | Technical architecture and patterns |
| [APP_DOCUMENTATION.md](docs/APP_DOCUMENTATION.md) | Full app documentation |
| [PRD_EduMaster_Platform.md](docs/PRD_EduMaster_Platform.md) | Product requirements document |
| [PROGRESS.md](docs/PROGRESS.md) | Development progress log |
| [PLAN.md](docs/PLAN.md) | Project plan |

---

## 🤝 Contributing

1. Fork the project
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the [MIT License](LICENSE).

---

## 📬 Contact

- **Email**: support@edumaster.com
- **Website**: https://edumaster.com

---

<div align="center">

Made with 💙 by [Hesham Mohamed Youssef](https://github.com/HeshamMoYoussef) using Flutter

</div>

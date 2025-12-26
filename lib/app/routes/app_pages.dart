import 'package:get/get.dart';

import 'app_routes.dart';
import '../modules/splash/bindings/splash_binding.dart';
import '../modules/splash/views/splash_view.dart';
import '../modules/onboarding/bindings/onboarding_binding.dart';
import '../modules/onboarding/views/onboarding_view.dart';
import '../modules/auth/bindings/auth_binding.dart';
import '../modules/auth/views/login_view.dart';
import '../modules/auth/views/register_view.dart';
import '../modules/auth/views/forgot_password_view.dart';
import '../modules/auth/views/otp_view.dart';
import '../modules/main/bindings/main_binding.dart';
import '../modules/main/views/main_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/courses/bindings/courses_binding.dart';
import '../modules/courses/views/courses_view.dart';
import '../modules/courses/views/course_details_view.dart';
import '../modules/courses/views/course_player_view.dart';
import '../modules/teachers/bindings/teachers_binding.dart';
import '../modules/teachers/views/teachers_view.dart';
import '../modules/teachers/views/teacher_profile_view.dart';
import '../modules/sessions/bindings/sessions_binding.dart';
import '../modules/sessions/views/sessions_view.dart';
import '../modules/sessions/views/session_details_view.dart';
import '../modules/sessions/views/live_session_view.dart';
import '../modules/sessions/views/book_session_view.dart';
import '../modules/ai_tutor/bindings/ai_tutor_binding.dart';
import '../modules/ai_tutor/views/ai_tutor_view.dart';
import '../modules/wallet/bindings/wallet_binding.dart';
import '../modules/wallet/views/wallet_view.dart';
import '../modules/achievements/bindings/achievements_binding.dart';
import '../modules/achievements/views/achievements_view.dart';
import '../modules/achievements/views/leaderboard_view.dart';
import '../modules/profile/bindings/profile_binding.dart';
import '../modules/profile/views/profile_view.dart';
import '../modules/profile/views/edit_profile_view.dart';
import '../modules/settings/bindings/settings_binding.dart';
import '../modules/settings/views/settings_view.dart';
import '../modules/parent/bindings/parent_binding.dart';
import '../modules/parent/views/parent_dashboard_view.dart';
import '../modules/teacher_dashboard/bindings/teacher_dashboard_binding.dart';
import '../modules/teacher_dashboard/views/teacher_dashboard_view.dart';
import '../modules/notifications/bindings/notifications_binding.dart';
import '../modules/notifications/views/notifications_view.dart';
import '../global/middlewares/auth_middleware.dart';

/// Application pages configuration
class AppPages {
  AppPages._();

  static const initial = Routes.splash;

  static final routes = <GetPage>[
    // Splash
    GetPage(
      name: Routes.splash,
      page: () => const SplashView(),
      binding: SplashBinding(),
      transition: Transition.fade,
    ),

    // Onboarding
    GetPage(
      name: Routes.onboarding,
      page: () => const OnboardingView(),
      binding: OnboardingBinding(),
      transition: Transition.rightToLeft,
    ),

    // Auth
    GetPage(
      name: Routes.login,
      page: () => const LoginView(),
      binding: AuthBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.register,
      page: () => const RegisterView(),
      binding: AuthBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.forgotPassword,
      page: () => const ForgotPasswordView(),
      binding: AuthBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.otp,
      page: () => const OtpView(),
      binding: AuthBinding(),
      transition: Transition.rightToLeft,
    ),

    // Main (with bottom navigation)
    GetPage(
      name: Routes.main,
      page: () => const MainView(),
      binding: MainBinding(),
      middlewares: [AuthMiddleware()],
      transition: Transition.fadeIn,
    ),

    // Home
    GetPage(
      name: Routes.home,
      page: () => const HomeView(),
      binding: HomeBinding(),
      middlewares: [AuthMiddleware()],
      transition: Transition.fadeIn,
    ),

    // Courses
    GetPage(
      name: Routes.courses,
      page: () => const CoursesView(),
      binding: CoursesBinding(),
      middlewares: [AuthMiddleware()],
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.courseDetails,
      page: () => const CourseDetailsView(),
      binding: CoursesBinding(),
      middlewares: [AuthMiddleware()],
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.coursePlayer,
      page: () => const CoursePlayerView(),
      binding: CoursesBinding(),
      middlewares: [AuthMiddleware()],
      transition: Transition.downToUp,
    ),

    // Teachers
    GetPage(
      name: Routes.teachers,
      page: () => const TeachersView(),
      binding: TeachersBinding(),
      middlewares: [AuthMiddleware()],
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.teacherProfile,
      page: () => const TeacherProfileView(),
      binding: TeachersBinding(),
      middlewares: [AuthMiddleware()],
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.bookSession,
      page: () => const BookSessionView(),
      bindings: [TeachersBinding(), SessionsBinding()],
      middlewares: [AuthMiddleware()],
      transition: Transition.rightToLeft,
    ),

    // Sessions
    GetPage(
      name: Routes.sessions,
      page: () => const SessionsView(),
      binding: SessionsBinding(),
      middlewares: [AuthMiddleware()],
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.sessionDetails,
      page: () => const SessionDetailsView(),
      binding: SessionsBinding(),
      middlewares: [AuthMiddleware()],
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.liveSession,
      page: () => const LiveSessionView(),
      binding: SessionsBinding(),
      middlewares: [AuthMiddleware()],
      transition: Transition.fadeIn,
    ),

    // AI Tutor
    GetPage(
      name: Routes.aiTutor,
      page: () => const AiTutorView(),
      binding: AiTutorBinding(),
      middlewares: [AuthMiddleware()],
      transition: Transition.rightToLeft,
    ),

    // Wallet
    GetPage(
      name: Routes.wallet,
      page: () => const WalletView(),
      binding: WalletBinding(),
      middlewares: [AuthMiddleware()],
      transition: Transition.rightToLeft,
    ),

    // Achievements
    GetPage(
      name: Routes.achievements,
      page: () => const AchievementsView(),
      binding: AchievementsBinding(),
      middlewares: [AuthMiddleware()],
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.leaderboard,
      page: () => const LeaderboardView(),
      binding: AchievementsBinding(),
      middlewares: [AuthMiddleware()],
      transition: Transition.rightToLeft,
    ),

    // Profile
    GetPage(
      name: Routes.profile,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
      middlewares: [AuthMiddleware()],
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.editProfile,
      page: () => const EditProfileView(),
      binding: ProfileBinding(),
      middlewares: [AuthMiddleware()],
      transition: Transition.rightToLeft,
    ),

    // Settings
    GetPage(
      name: Routes.settings,
      page: () => const SettingsView(),
      binding: SettingsBinding(),
      middlewares: [AuthMiddleware()],
      transition: Transition.rightToLeft,
    ),

    // Parent Dashboard
    GetPage(
      name: Routes.parentDashboard,
      page: () => const ParentDashboardView(),
      binding: ParentBinding(),
      middlewares: [AuthMiddleware()],
      transition: Transition.fadeIn,
    ),

    // Teacher Dashboard
    GetPage(
      name: Routes.teacherDashboard,
      page: () => const TeacherDashboardView(),
      binding: TeacherDashboardBinding(),
      middlewares: [AuthMiddleware()],
      transition: Transition.fadeIn,
    ),

    // Notifications
    GetPage(
      name: Routes.notifications,
      page: () => const NotificationsView(),
      binding: NotificationsBinding(),
      middlewares: [AuthMiddleware()],
      transition: Transition.rightToLeft,
    ),
  ];
}

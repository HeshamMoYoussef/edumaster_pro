/// Application-wide constants
class AppConstants {
  AppConstants._();

  // Padding & Margins
  static const double paddingXS = 4.0;
  static const double paddingS = 8.0;
  static const double paddingM = 16.0;
  static const double paddingL = 24.0;
  static const double paddingXL = 32.0;
  static const double paddingXXL = 48.0;

  // Border Radius
  static const double radiusXS = 4.0;
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 24.0;
  static const double radiusXXL = 32.0;
  static const double radiusFull = 9999.0;

  // Button Heights
  static const double buttonHeight = 55.0; // Default
  static const double buttonHeightS = 45.0;
  static const double buttonHeightM = 55.0;
  static const double buttonHeightL = 60.0;

  // Icon Sizes
  static const double iconSizeXS = 16.0;
  static const double iconSizeS = 20.0;
  static const double iconSizeM = 24.0;
  static const double iconSizeL = 32.0;
  static const double iconSizeXL = 48.0;
  static const double iconSizeXXL = 64.0;

  // Avatar Sizes
  static const double avatarSizeXS = 24.0;
  static const double avatarSizeS = 32.0;
  static const double avatarSizeM = 48.0;
  static const double avatarSizeL = 64.0;
  static const double avatarSizeXL = 96.0;
  static const double avatarSizeXXL = 128.0;

  // Card Sizes
  static const double cardElevation = 2.0;
  static const double cardElevationHover = 8.0;

  // Animation Durations
  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);
  static const Duration animationVerySlow = Duration(milliseconds: 800);

  // Responsive Breakpoints
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;

  // Input
  static const int maxPasswordLength = 32;
  static const int minPasswordLength = 8;
  static const int maxNameLength = 50;
  static const int maxBioLength = 500;
  static const int maxMessageLength = 1000;

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Session
  static const int sessionDurationMinutes = 60;
  static const int minSessionDuration = 30;
  static const int maxSessionDuration = 180;

  // EduCoins
  static const int eduCoinsPerLogin = 5;
  static const int eduCoinsPerLesson = 10;
  static const int eduCoinsPerQuiz = 20;
  static const int eduCoinsPerCourse = 100;
  static const int eduCoinsReferral = 50;

  // Levels
  static const int pointsPerLevel = 1000;
  static const int maxLevel = 100;

  // Storage Keys
  static const String storageKeyToken = 'auth_token';
  static const String storageKeyRefreshToken = 'refresh_token';
  static const String storageKeyUser = 'user_data';
  static const String storageKeyTheme = 'theme_mode';
  static const String storageKeyLocale = 'locale';
  static const String storageKeyOnboarding = 'onboarding_completed';
  static const String storageKeyFirstLaunch = 'first_launch';
  static const String storageKeyNotifications = 'notifications_enabled';
}

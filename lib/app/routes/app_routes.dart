/// Application routes
abstract class Routes {
  Routes._();

  // Initial
  static const splash = '/splash';
  static const onboarding = '/onboarding';

  // Auth
  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';
  static const resetPassword = '/reset-password';
  static const otp = '/otp';

  // Main
  static const main = '/main';
  static const home = '/home';

  // Courses
  static const courses = '/courses';
  static const courseDetails = '/course/:id';
  static const coursePlayer = '/course/:id/player';
  static const courseQuiz = '/course/:id/quiz/:quizId';

  // Teachers
  static const teachers = '/teachers';
  static const teacherProfile = '/teacher/:id';
  static const bookSession = '/teacher/:id/book';

  // Sessions
  static const sessions = '/sessions';
  static const sessionDetails = '/session/:id';
  static const liveSession = '/session/:id/live';

  // AI Tutor
  static const aiTutor = '/ai-tutor';
  static const aiChat = '/ai-tutor/chat';

  // Wallet
  static const wallet = '/wallet';
  static const walletHistory = '/wallet/history';
  static const topUp = '/wallet/top-up';
  static const withdraw = '/wallet/withdraw';

  // Achievements
  static const achievements = '/achievements';
  static const leaderboard = '/leaderboard';
  static const dailyChallenges = '/challenges';

  // Profile
  static const profile = '/profile';
  static const editProfile = '/profile/edit';
  static const settings = '/settings';
  static const notifications = '/notifications';

  // Parent
  static const parentDashboard = '/parent';
  static const childProgress = '/parent/child/:id';

  // Teacher
  static const teacherDashboard = '/teacher-dashboard';
  static const teacherSchedule = '/teacher-dashboard/schedule';
  static const teacherStudents = '/teacher-dashboard/students';
  static const teacherEarnings = '/teacher-dashboard/earnings';

  // Other
  static const search = '/search';
  static const categories = '/categories';
  static const favorites = '/favorites';
  static const help = '/help';
  static const about = '/about';
  static const privacyPolicy = '/privacy-policy';
  static const termsOfService = '/terms-of-service';

  // Helper methods for dynamic routes
  static String courseDetailsPath(String id) => '/course/$id';
  static String coursePlayerPath(String id) => '/course/$id/player';
  static String courseQuizPath(String courseId, String quizId) =>
      '/course/$courseId/quiz/$quizId';
  static String teacherProfilePath(String id) => '/teacher/$id';
  static String bookSessionPath(String teacherId) => '/teacher/$teacherId/book';
  static String sessionDetailsPath(String id) => '/session/$id';
  static String liveSessionPath(String id) => '/session/$id/live';
  static String childProgressPath(String childId) => '/parent/child/$childId';
}

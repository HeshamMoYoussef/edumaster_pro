/// API endpoint constants
class ApiConstants {
  ApiConstants._();

  // Auth Endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String verifyOtp = '/auth/verify-otp';
  static const String resendOtp = '/auth/resend-otp';
  static const String sendOtp = '/auth/send-otp';
  static const String socialLogin = '/auth/social';
  static const String changePassword = '/auth/change-password';

  // User Endpoints
  static const String profile = '/users/profile';
  static const String userProfile = '/users/profile';
  static const String updateProfile = '/users/profile';
  static const String uploadAvatar = '/users/avatar';
  static const String userStats = '/users/stats';
  static const String userProgress = '/users/progress';
  static const String userAchievements = '/users/achievements';
  static const String userCertificates = '/users/certificates';

  // Course Endpoints
  static const String courses = '/courses';
  static const String courseDetails = '/courses/{id}';
  static const String categories = '/courses/categories';
  static const String courseCategories = '/courses/categories';
  static const String myEnrollments = '/courses/my-enrollments';
  static const String courseLessons = '/courses/{id}/lessons';
  static const String courseEnroll = '/courses/{id}/enroll';
  static const String courseProgress = '/courses/{id}/progress';
  static const String courseReviews = '/courses/{id}/reviews';
  static const String courseQuizzes = '/courses/{id}/quizzes';
  static const String featuredCourses = '/courses/featured';
  static const String popularCourses = '/courses/popular';
  static const String recommendedCourses = '/courses/recommended';

  // Teacher Endpoints
  static const String teachers = '/teachers';
  static const String teacherDetails = '/teachers/{id}';
  static const String teacherCourses = '/teachers/{id}/courses';
  static const String teacherReviews = '/teachers/{id}/reviews';
  static const String teacherAvailability = '/teachers/{id}/availability';
  static const String featuredTeachers = '/teachers/featured';
  static const String topTeachers = '/teachers/top';

  // Session Endpoints
  static const String sessions = '/sessions';
  static const String sessionDetails = '/sessions/{id}';
  static const String bookSession = '/sessions/book';
  static const String cancelSession = '/sessions/{id}/cancel';
  static const String rescheduleSession = '/sessions/{id}/reschedule';
  static const String upcomingSessions = '/sessions/upcoming';
  static const String sessionHistory = '/sessions/history';
  static const String sessionNotes = '/sessions/{id}/notes';

  // Chat & AI Tutor Endpoints
  static const String chatRooms = '/chat/rooms';
  static const String chatMessages = '/chat/rooms/{id}/messages';
  static const String aiTutor = '/ai/tutor';
  static const String aiTutorHistory = '/ai/tutor/history';
  static const String aiTutorSuggestions = '/ai/tutor/suggestions';

  // Wallet & Transactions
  static const String wallet = '/wallet';
  static const String walletBalance = '/wallet/balance';
  static const String transactions = '/wallet/transactions';
  static const String walletTransactions = '/wallet/transactions';
  static const String topUp = '/wallet/deposit';
  static const String walletDeposit = '/wallet/deposit';
  static const String withdraw = '/wallet/withdraw';
  static const String walletWithdraw = '/wallet/withdraw';
  static const String walletTransfer = '/wallet/transfer';

  // Achievements & Gamification
  static const String achievements = '/achievements';
  static const String badges = '/achievements/badges';
  static const String leaderboard = '/achievements/leaderboard';
  static const String dailyChallenges = '/achievements/daily-challenges';
  static const String streaks = '/achievements/streaks';

  // Community
  static const String posts = '/community/posts';
  static const String postDetails = '/community/posts/{id}';
  static const String postComments = '/community/posts/{id}/comments';
  static const String groups = '/community/groups';
  static const String groupDetails = '/community/groups/{id}';

  // Notifications
  static const String notifications = '/notifications';
  static const String notificationSettings = '/notifications/settings';
  static const String markNotificationRead = '/notifications/{id}/read';
  static const String markAllNotificationsRead = '/notifications/read-all';

  // Parent Dashboard
  static const String parentChildren = '/parent/children';
  static const String childProgress = '/parent/children/{id}/progress';
  static const String childActivities = '/parent/children/{id}/activities';
  static const String childReports = '/parent/children/{id}/reports';

  // Settings
  static const String settings = '/settings';
  static const String notificationPreferences = '/settings/notifications';
  static const String privacySettings = '/settings/privacy';

  // Search
  static const String search = '/search';
  static const String searchCourses = '/search/courses';
  static const String searchTeachers = '/search/teachers';
  static const String searchSuggestions = '/search/suggestions';

  // Misc
  static const String faqs = '/misc/faqs';
  static const String supportTicket = '/misc/support';
  static const String appConfig = '/misc/config';
  static const String countries = '/misc/countries';
  static const String subjects = '/misc/subjects';
}

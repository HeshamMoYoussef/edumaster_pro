/// Environment configuration for the application
/// Supports development, staging, and production environments
enum Environment { development, staging, production }

class EnvConfig {
  static Environment _environment = Environment.development;

  static Environment get environment => _environment;

  static void setEnvironment(Environment env) {
    _environment = env;
  }

  /// Whether to use mock data instead of real API
  static bool get useMockData {
    switch (_environment) {
      case Environment.development:
        return true; // Use mock data in development
      case Environment.staging:
        return false;
      case Environment.production:
        return false;
    }
  }

  /// Base URL for API requests
  static String get baseUrl {
    switch (_environment) {
      case Environment.development:
        return 'https://dev-api.edumaster.pro/v1';
      case Environment.staging:
        return 'https://staging-api.edumaster.pro/v1';
      case Environment.production:
        return 'https://api.edumaster.pro/v1';
    }
  }

  /// WebSocket URL for real-time features
  static String get wsUrl {
    switch (_environment) {
      case Environment.development:
        return 'wss://dev-ws.edumaster.pro';
      case Environment.staging:
        return 'wss://staging-ws.edumaster.pro';
      case Environment.production:
        return 'wss://ws.edumaster.pro';
    }
  }

  /// Enable logging
  static bool get enableLogging {
    return _environment != Environment.production;
  }

  /// API request timeout in milliseconds
  static int get requestTimeout => 30000;

  /// Connection timeout in milliseconds
  static int get connectionTimeout => 30000;

  /// Maximum retry attempts for failed requests
  static int get maxRetryAttempts => 3;

  /// App name
  static String get appName => 'EduMaster Pro';

  /// App version
  static String get appVersion => '1.0.0';
}

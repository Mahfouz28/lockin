/// Application Configuration
class AppConfig {
  AppConfig._();

  static const String appName = 'Lock In';
  static const String appVersion = '1.0.0';
  static const String buildNumber = '1';
  static const String appLogo = 'assets/images/logo.png';

  // Developer Info
  static const String developerName = 'Mahmoud Mahfouz';
  static const String developerGithub = 'https://github.com/mahfouz28';
  static const String developerProfile = 'mahmoud-mahfouz.com';
  static const String developerLinkedIn =
      'https://www.linkedin.com/in/mahmoud-mahfouz';
  static const String developerEmail = 'contact@mahmoud-mahfouz.com';
  // Environment
  static const bool isProduction = false;
  static const bool enableLogging = true;

  // API Configuration
  static String get baseUrl {
    return isProduction
        ? 'https://api.production.com'
        : 'https://api.development.com';
  }
}

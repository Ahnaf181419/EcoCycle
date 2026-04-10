class AppConstants {
  AppConstants._();

  static const String appName = 'EcoCycle';
  static const String appNameLower = 'ecocycle';

  static const String defaultRole = 'citizen';
  static const String moderatorRole = 'moderator';
  static const String adminRole = 'admin';

  static const double confidenceThreshold = 0.7;
  static const double maxImageSizeKB = 500;
  static const int maxDailySubmissions = 50;
  static const int leaderboardLimit = 100;
  static const int feedPageSize = 20;
  static const int historyPageSize = 20;

  static const String primaryApproach = 'gemini';
  static const String secondaryApproach = 'tflite';
  static const String geminiSecondaryApproach = 'gemini_secondary';

  static const int duplicateTimeWindowHours = 24;
  static const int duplicateHammingThreshold = 5;

  static const int pointsRecyclable = 10;
  static const int pointsOrganic = 8;
  static const int pointsEWaste = 15;
  static const int pointsHazardous = 20;

  static const Duration animationDurationFast = Duration(milliseconds: 150);
  static const Duration animationDurationNormal = Duration(milliseconds: 250);
  static const Duration animationDurationSlow = Duration(milliseconds: 400);
  static const Duration animationDurationCelebration = Duration(
    milliseconds: 800,
  );
}

abstract class AppConstants {
  // ─── App Info ─────────────────────────────────────────────────────────────
  static const String appName = 'HaramainQu';
  static const String appFullName = 'HaramainQu - Pendamping Ibadah Umroh';
  static const String appTagline = 'Ibadah Umroh Lebih Mudah & Terstruktur';
  static const String companyName = 'Haramain Tour';
  static const String appVersion = '1.0.0';

  // ─── API Configuration ────────────────────────────────────────────────────
  static const String apiBaseUrl = 'https://api.haramaintour.com/v1';
  static const String apiTimeout = '30000'; // ms
  static const String jwtTokenKey = 'jwt_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userDataKey = 'user_data';
  static const String userRoleKey = 'user_role';

  // ─── Ibadah Constants ─────────────────────────────────────────────────────
  static const int tawafTotal = 7;
  static const int saiTotal = 7;
  static const List<int> dzikirTargets = [33, 99, 100, 1000];
  static const int defaultDzikirTarget = 33;

  // ─── Ibadah IDs ───────────────────────────────────────────────────────────
  static const String ibadahIhram = 'ihram';
  static const String ibadahTawaf = 'tawaf';
  static const String ibadahSai = 'sai';
  static const String ibadahTahallul = 'tahallul';
  static const String ibadahShalatMaqam = 'shalat_maqam';

  // ─── Hive Box Names ───────────────────────────────────────────────────────
  static const String hiveBoxUser = 'user_box';
  static const String hiveBoxProgress = 'progress_box';
  static const String hiveBoxTracking = 'tracking_box';
  static const String hiveBoxReminder = 'reminder_box';
  static const String hiveBoxDoa = 'doa_box';
  static const String hiveBoxKamus = 'kamus_box';
  static const String hiveBoxOffline = 'offline_box';

  // ─── Duration Constants ───────────────────────────────────────────────────
  static const Duration splashDuration = Duration(seconds: 3);
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationNormal = Duration(milliseconds: 350);
  static const Duration animationSlow = Duration(milliseconds: 600);
  static const Duration snackbarDuration = Duration(seconds: 3);

  // ─── Storage Keys ─────────────────────────────────────────────────────────
  static const String keyOnboardingDone = 'onboarding_done';
  static const String keySelectedLanguage = 'selected_language';
  static const String keyDarkMode = 'dark_mode';
  static const String keyRememberLogin = 'remember_login';

  // ─── Languages ────────────────────────────────────────────────────────────
  static const String langId = 'id'; // Bahasa Indonesia
  static const String langAr = 'ar'; // Arabic
  static const String langEn = 'en'; // English
}

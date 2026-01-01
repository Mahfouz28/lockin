// lib/core/services/shared_prefs_service.dart

import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsService {
  // Singleton pattern
  static final SharedPrefsService _instance = SharedPrefsService._internal();
  factory SharedPrefsService() => _instance;
  SharedPrefsService._internal();

  // Keys
  static const String _focusModeKey = 'focus_mode_enabled';
  static const String _blockedAppsKey = 'blocked_apps';
  static const String _focusEndTimeKey = 'focus_end_time';
  static const String _notificationsKey = 'app_notifications';

  // General keys (مستخدمة في أماكن أخرى في التطبيق)
  static const String _darkModeKey = 'is_dark_mode';
  static const String _appLanguageKey = 'app_language';
  static const String _firstLaunchKey = 'is_first_launch';
  static const String _onboardingShownKey = 'onboarding_shown';

  SharedPreferences? _prefs;

  /// تهيئة SharedPreferences - بتُستدعى مرة واحدة في initializeDependencies()
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // ===================== Focus Mode =====================
  Future<bool> isFocusModeEnabled() async {
    await init();
    return _prefs!.getBool(_focusModeKey) ?? false;
  }

  Future<void> setFocusModeEnabled(bool value) async {
    await init();
    await _prefs!.setBool(_focusModeKey, value);
  }

  // ===================== Blocked Apps =====================
  Future<List<String>> getBlockedApps() async {
    await init();
    return _prefs!.getStringList(_blockedAppsKey) ?? [];
  }

  Future<void> setBlockedApps(List<String> packages) async {
    await init();
    await _prefs!.setStringList(_blockedAppsKey, packages);
  }

  Future<void> clearBlockedApps() async {
    await init();
    await _prefs!.remove(_blockedAppsKey);
  }

  // ===================== Focus Timer =====================
  Future<void> setFocusEndTime(DateTime time) async {
    await init();
    await _prefs!.setString(_focusEndTimeKey, time.toIso8601String());
  }

  Future<DateTime?> getFocusEndTime() async {
    await init();
    final String? str = _prefs!.getString(_focusEndTimeKey);
    return str != null ? DateTime.parse(str) : null;
  }

  Future<void> clearFocusEndTime() async {
    await init();
    await _prefs!.remove(_focusEndTimeKey);
  }

  // ===================== Notifications History =====================
  /// إضافة إشعار جديد مع timestamp
  Future<void> addNotification(String title, String body) async {
    await init();
    final List<String> notifications =
        _prefs!.getStringList(_notificationsKey) ?? [];

    final String entry = '${DateTime.now().toIso8601String()}|||$title|||$body';
    notifications.insert(0, entry); // الأحدث في الأول

    // الحد الأقصى 100 إشعار عشان ما يثقلش التخزين
    if (notifications.length > 100) {
      notifications.removeRange(100, notifications.length);
    }

    await _prefs!.setStringList(_notificationsKey, notifications);
  }

  /// جلب كل الإشعارات مرتبة من الأحدث للأقدم
  Future<List<Map<String, String>>> getNotifications() async {
    await init();
    final List<String> rawList = _prefs!.getStringList(_notificationsKey) ?? [];

    return rawList.map((entry) {
      final parts = entry.split('|||');
      if (parts.length != 3) {
        return {
          'time': DateTime.now().toIso8601String(),
          'title': 'Unknown',
          'body': '',
        };
      }
      return {'time': parts[0], 'title': parts[1], 'body': parts[2]};
    }).toList();
  }

  Future<void> clearNotifications() async {
    await init();
    await _prefs!.remove(_notificationsKey);
  }

  // ===================== General / App Settings =====================
  Future<bool> getBool(String key, {bool defaultValue = false}) async {
    await init();
    return _prefs!.getBool(key) ?? defaultValue;
  }

  Future<void> setBool(String key, bool value) async {
    await init();
    await _prefs!.setBool(key, value);
  }

  Future<String?> getString(String key) async {
    await init();
    return _prefs!.getString(key);
  }

  Future<void> setString(String key, String value) async {
    await init();
    await _prefs!.setString(key, value);
  }

  Future<void> remove(String key) async {
    await init();
    await _prefs!.remove(key);
  }

  // دوال شائعة الاستخدام في التطبيق
  Future<bool> isDarkMode() async => await getBool(_darkModeKey);

  Future<void> setDarkMode(bool value) async =>
      await setBool(_darkModeKey, value);

  Future<String> getAppLanguage() async =>
      await getString(_appLanguageKey) ?? 'en';

  Future<void> setAppLanguage(String lang) async =>
      await setString(_appLanguageKey, lang);

  Future<bool> isFirstLaunch() async =>
      await getBool(_firstLaunchKey, defaultValue: true);

  Future<void> setFirstLaunchCompleted() async =>
      await setBool(_firstLaunchKey, false);

  Future<bool> isOnboardingShown() async =>
      await getBool(_onboardingShownKey, defaultValue: false);

  Future<void> setOnboardingShown() async =>
      await setBool(_onboardingShownKey, true);

  // ===================== Clear All =====================
  Future<void> clearAll() async {
    await init();
    await _prefs!.clear();
  }
}

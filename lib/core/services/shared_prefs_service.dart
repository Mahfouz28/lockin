import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsService {
  // Keys
  static const String _focusModeKey = 'focus_mode_enabled';
  static const String _blockedAppsKey = 'blocked_apps';
  static const String _focusEndTimeKey = 'focus_end_time';
  static const String _notificationsKey = 'app_notifications';

  SharedPreferences? _prefs;

  /// Initialize SharedPreferences (call once in main.dart or before use)
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
    final str = _prefs!.getString(_focusEndTimeKey);
    return str != null ? DateTime.parse(str) : null;
  }

  Future<void> clearFocusEndTime() async {
    await init();
    await _prefs!.remove(_focusEndTimeKey);
  }

  // ===================== Notifications History =====================
  /// Add a new notification (stored with timestamp)
  Future<void> addNotification(String title, String body) async {
    await init();
    final List<String> notifications =
        _prefs!.getStringList(_notificationsKey) ?? [];

    final entry = '${DateTime.now().toIso8601String()}|||$title|||$body';
    notifications.insert(0, entry); // newest at top

    // Limit max notifications to 100
    if (notifications.length > 100) {
      notifications.removeRange(100, notifications.length);
    }

    await _prefs!.setStringList(_notificationsKey, notifications);
  }

  /// Get all notifications sorted newest first
  Future<List<Map<String, String>>> getNotifications() async {
    await init();
    final List<String> rawList = _prefs!.getStringList(_notificationsKey) ?? [];
    return rawList.map((entry) {
      final parts = entry.split('|||');
      if (parts.length != 3)
        return {'time': '', 'title': 'Unknown', 'body': ''};
      return {'time': parts[0], 'title': parts[1], 'body': parts[2]};
    }).toList();
  }

  /// Clear all notifications
  Future<void> clearNotifications() async {
    await init();
    await _prefs!.remove(_notificationsKey);
  }

  // ===================== General Helpers =====================
  Future<void> setString(String key, String value) async {
    await init();
    await _prefs!.setString(key, value);
  }

  Future<String?> getString(String key) async {
    await init();
    return _prefs!.getString(key);
  }

  Future<void> remove(String key) async {
    await init();
    await _prefs!.remove(key);
  }

  Future<void> clearAll() async {
    await init();
    await _prefs!.clear();
  }
}

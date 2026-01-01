// lib/core/services/notification_service.dart
// تم تصحيح اسم الملف فقط (notification بدل notifcation)

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:lockin/core/services/shared_prefs_service.dart';
import 'package:lockin/core/theme/colors.dart';

class NotificationService {
  // Singleton pattern
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const String _focusChannelId = 'focus_sessions_channel';
  static const String _generalChannelId = 'general_channel';

  // تخزين مؤقت للترجمات عشان ما نعملش load كل مرة
  Map<String, dynamic>? _cachedTranslations;
  String? _currentLang;

  /// تحميل ملف الترجمة المناسب (ar.json أو en.json)
  Future<Map<String, dynamic>> _loadTranslations() async {
    final prefs = SharedPrefsService();
    final String lang = await prefs.getString('app_language') ?? 'en';

    // إذا اللغة نفسها والترجمات محملة بالفعل، نرجعها مباشرة
    if (_cachedTranslations != null && _currentLang == lang) {
      return _cachedTranslations!;
    }

    _currentLang = lang;

    final String path = 'assets/lang/$lang.json';

    try {
      final String jsonString = await rootBundle.loadString(path);
      _cachedTranslations = json.decode(jsonString) as Map<String, dynamic>;
      return _cachedTranslations!;
    } catch (e) {
      // Fallback إلى الإنجليزية لو الملف مش موجود أو فيه خطأ
      final String jsonString = await rootBundle.loadString(
        'assets/lang/en.json',
      );
      _cachedTranslations = json.decode(jsonString) as Map<String, dynamic>;
      return _cachedTranslations!;
    }
  }

  /// جلب نص مترجم باستخدام dot notation مثل 'focus_mode.focus_complete_title'
  Future<String> _getTr(String key) async {
    final Map<String, dynamic> translations = await _loadTranslations();

    final List<String> parts = key.split('.');
    dynamic value = translations;

    for (final part in parts) {
      if (value is Map<String, dynamic> && value.containsKey(part)) {
        value = value[part];
      } else {
        return key; // إرجاع المفتاح لو مش موجود (سهل التصحيح)
      }
    }

    return value.toString();
  }

  /// تهيئة الإشعارات + إنشاء القنوات مع أسماء مترجمة
  Future<void> initialize() async {
    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _plugin.initialize(initSettings);

    // جلب النصوص المترجمة للقنوات
    final String focusName = await _getTr('notifications.focus_channel_name');
    final String focusDesc = await _getTr(
      'notifications.focus_channel_description',
    );
    final String generalName = await _getTr(
      'notifications.general_channel_name',
    );
    final String generalDesc = await _getTr(
      'notifications.general_channel_description',
    );

    final AndroidNotificationChannel focusChannel = AndroidNotificationChannel(
      _focusChannelId,
      focusName,
      description: focusDesc,
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 1000, 500, 1000]),
      ledColor: AppColors.primary,
      showBadge: true,
    );

    final AndroidNotificationChannel generalChannel =
        AndroidNotificationChannel(
          _generalChannelId,
          generalName,
          description: generalDesc,
          importance: Importance.high,
          playSound: true,
          enableVibration: true,
          showBadge: true,
        );

    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    await androidPlugin?.createNotificationChannel(focusChannel);
    await androidPlugin?.createNotificationChannel(generalChannel);
  }

  /// عرض إشعار عام (دالة داخلية)
  Future<void> _showNotification({
    required String title,
    required String body,
    required int id,
    String? payload,
    String channelId = _focusChannelId,
  }) async {
    // جلب اسم ووصف القناة مترجم مرة تانية (للتحديث الديناميكي لو اللغة اتغيرت)
    final String channelName = channelId == _focusChannelId
        ? await _getTr('notifications.focus_channel_name')
        : await _getTr('notifications.general_channel_name');

    final String channelDesc = channelId == _focusChannelId
        ? await _getTr('notifications.focus_channel_description')
        : await _getTr('notifications.general_channel_description');

    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          channelId,
          channelName,
          channelDescription: channelDesc,
          importance: Importance.max,
          priority: Priority.high,
          color: AppColors.primary,
          colorized: true,
          playSound: true,
          enableVibration: true,
          vibrationPattern: Int64List.fromList([0, 1000, 500, 1000]),
          ledColor: AppColors.primary,
          ledOnMs: 1000,
          ledOffMs: 500,
          icon: '@mipmap/ic_launcher',
          largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
          ticker: title,
          styleInformation: BigTextStyleInformation(body, contentTitle: title),
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'default',
    );

    final NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.show(id, title, body, details, payload: payload);

    // حفظ الإشعار في السجل المحلي
    await SharedPrefsService().addNotification(title, body);
  }

  // ====================== Public Methods ======================

  Future<void> showFocusCompleteNotification() async {
    final String title = await _getTr('focus_mode.focus_complete_title');
    final String body = await _getTr('focus_mode.focus_complete_body');

    await _showNotification(title: title, body: body, id: 100);
  }

  Future<void> showFocusEndingSoonNotification() async {
    final String title = await _getTr('focus_mode.focus_warning_title');
    final String body = await _getTr('focus_mode.focus_warning_body');

    await _showNotification(title: title, body: body, id: 101);
  }

  Future<void> showGeneralNotification({
    required String title,
    required String body,
    int id = 0,
  }) async {
    await _showNotification(
      title: title,
      body: body,
      id: id,
      channelId: _generalChannelId,
    );
  }

  // دالة اختبار سريعة (مفيدة في Onboarding)
  Future<void> showTestNotification() async {
    await _showNotification(
      title: 'Hello in Lock In App! 👋',
      body: 'الإشعار شغال تمام! جرب ميزة Focus Mode دلوقتي.',
      id: 999,
      channelId: _generalChannelId,
    );
  }

  Future<void> cancelAll() async => await _plugin.cancelAll();

  Future<void> cancel(int id) async => await _plugin.cancel(id);
}

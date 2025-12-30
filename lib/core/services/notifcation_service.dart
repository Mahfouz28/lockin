import 'dart:typed_data';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:lockin/core/services/shared_prefs_service.dart';
import 'package:lockin/core/theme/colors.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings();

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(initSettings);
  }

  Future<void> showNotification({
    required String title,
    required String body,
    int id = 0,
    String? payload,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      'default_channel',
      'General Notifications',
      channelDescription: 'Default channel for notifications',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      vibrationPattern: Int64List.fromList(const [0, 1000, 500, 1000]),
      icon: '@mipmap/ic_launcher',
      largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      color: AppColors.primary,
      ledColor: AppColors.primary,
      ledOnMs: 1000,
      ledOffMs: 500,
    );

    final iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.show(id, title, body, details, payload: payload);
    await SharedPrefsService().addNotification(title, body);
  }

  /// Focus complete notification
  Future<void> showFocusCompleteNotification() async {
    await showNotification(
      title: tr('focus_mode.focus_complete_title'),
      body: tr('focus_mode.focus_complete_body'),
      id: 100,
    );
  }

  /// Focus about to end warning
  Future<void> showFocusEndingSoonNotification() async {
    await showNotification(
      title: tr('focus_mode.focus_warning_title'),
      body: tr('focus_mode.focus_warning_body'),
      id: 101,
    );
  }

  Future<void> cancelAll() async => await _plugin.cancelAll();
}

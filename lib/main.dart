import 'dart:io';

import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lockin/core/services/shared_prefs_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:workmanager/workmanager.dart'; // ← أضف ده

import 'core/routes/app_router.dart';
import 'core/routes/routes.dart';
import 'core/theme/app_theme.dart';
import 'core/localization/localization_manager.dart';

// Global notification plugin
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// Workmanager callback dispatcher (مهم جدًا يكون top-level)
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == 'focus_complete') {
      // دالة الإشعار (هتكون معرفة في focus_mode_cubit أو هنا)
      await showFocusCompleteNotification();
    }
    return Future.value(true);
  });
}

// دالة عرض الإشعار (يمكن تنقلها لملف منفصل لاحقًا)
Future<void> showFocusCompleteNotification() async {
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'focus_complete_channel',
    'Focus Mode',
    channelDescription: 'Notification when focus session ends',
    importance: Importance.max,
    priority: Priority.high,
    playSound: true,
    enableVibration: true,
  );

  const DarwinNotificationDetails iOSDetails = DarwinNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
  );

  const NotificationDetails notificationDetails = NotificationDetails(
    android: androidDetails,
    iOS: iOSDetails,
  );

  await flutterLocalNotificationsPlugin.show(
    100,
    'Focus Session Complete! 🎉',
    'Amazing work! You stayed focused and completed your session.',
    notificationDetails,
  );

  // حفظ في التاريخ
  await SharedPrefsService().addNotification(
    'Focus Session Complete! 🎉',
    'Amazing work! You stayed focused and completed your session.',
  );
}

// طلب إذن الإشعارات (Android 13+)
Future<void> requestNotificationPermission() async {
  if (Platform.isAndroid) {
    final status = await Permission.notification.status;

    if (status.isDenied) {
      await Permission.notification.request();
    }

    if (status.isPermanentlyDenied) {
      await openAppSettings();
    }
  }
}

// تهيئة الإشعارات
Future<void> initNotifications() async {
  tz.initializeTimeZones();

  const AndroidInitializationSettings androidInit =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const DarwinInitializationSettings iOSInit = DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );

  const InitializationSettings initSettings = InitializationSettings(
    android: androidInit,
    iOS: iOSInit,
  );

  await flutterLocalNotificationsPlugin.initialize(initSettings);
}

// تهيئة Workmanager
Future<void> initWorkManager() async {
  await Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: false, // true لو عايز تشوف logs في debug
  );
}

Future<ThemeData> _getInitialTheme() async {
  final prefs = await SharedPreferences.getInstance();
  final isDark = prefs.getBool('is_dark_mode') ?? false;
  return isDark ? AppTheme.darkTheme : AppTheme.lightTheme;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await EasyLocalization.ensureInitialized();

  final sharedPrefsService = SharedPrefsService();
  await sharedPrefsService.init();

  // تهيئة الإشعارات
  await initNotifications();

  // تهيئة Workmanager (مهم جدًا للإشعار حتى لو app killed)
  await initWorkManager();

  // طلب إذن الإشعارات من أول تشغيل
  await requestNotificationPermission();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  final initialTheme = await _getInitialTheme();

  runApp(
    EasyLocalization(
      supportedLocales: LocalizationManager.supportedLocales,
      path: LocalizationManager.translationsPath,
      fallbackLocale: LocalizationManager.fallbackLocale,
      startLocale: LocalizationManager.fallbackLocale,
      child: MyApp(initialTheme: initialTheme),
    ),
  );
}

class MyApp extends StatelessWidget {
  final ThemeData initialTheme;

  const MyApp({super.key, required this.initialTheme});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(414, 896),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return ThemeProvider(
          initTheme: initialTheme,
          builder: (context, myTheme) {
            return ThemeSwitcher(
              clipper: const ThemeSwitcherCircleClipper(),
              builder: (context) {
                return MaterialApp(
                  title: 'Lock In',
                  debugShowCheckedModeBanner: false,
                  theme: myTheme,
                  initialRoute: Routes.splash,
                  onGenerateRoute: AppRouter.generateRoute,
                  localizationsDelegates: context.localizationDelegates,
                  supportedLocales: context.supportedLocales,
                  locale: context.locale,
                );
              },
            );
          },
        );
      },
    );
  }
}

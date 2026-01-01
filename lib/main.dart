// lib/main.dart

import 'dart:io';

import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lockin/core/di/injection_container.dart'; // أهم إضافة
import 'package:lockin/core/routes/app_router.dart';
import 'package:lockin/core/routes/routes.dart';
import 'package:lockin/core/services/notifcation_service.dart';
import 'package:lockin/core/services/shared_prefs_service.dart';
import 'package:lockin/core/theme/app_theme.dart';
import 'package:lockin/core/localization/localization_manager.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:workmanager/workmanager.dart';

// Workmanager callback dispatcher (يجب يكون top-level)
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      // في الـ background isolate، مفيش GetIt جاهز، لازم نهيئ الإشعارات يدويًا
      final notificationService = NotificationService();
      await notificationService.initialize();

      switch (task) {
        case 'focus_complete':
          await notificationService.showFocusCompleteNotification();
          break;
        case 'focus_ending_soon':
          await notificationService.showFocusEndingSoonNotification();
          break;
      }
    } catch (e) {
      debugPrint('Workmanager task error: $e');
    }

    return Future.value(true);
  });
}

Future<ThemeData> _getInitialTheme() async {
  // بنستخدم الـ SharedPrefsService المسجل في GetIt بعد التهيئة
  final isDark = await sl<SharedPrefsService>().getBool('is_dark_mode');
  return isDark ? AppTheme.darkTheme : AppTheme.lightTheme;
}

Future<void> _requestCriticalPermissions() async {
  if (Platform.isAndroid) {
    final status = await Permission.notification.status;
    if (status.isDenied || status.isPermanentlyDenied) {
      await Permission.notification.request();
    }
  }
  // أضف صلاحيات تانية لاحقًا لو احتجت (مثل Usage Stats لقفل التطبيقات)
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تهيئة EasyLocalization
  await EasyLocalization.ensureInitialized();

  // أهم خطوة: تهيئة كل التبعيات باستخدام GetIt
  await initializeDependencies();

  // تهيئة Workmanager للمهام في الخلفية (حتى لو التطبيق مقفول)
  await Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: false, // غيّر لـ true لو عايز تشوف logs في الـ debug
  );

  // طلب الصلاحيات المهمة من أول مرة
  await _requestCriticalPermissions();

  // تحديد اتجاه الشاشة
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // ستايل شريط الحالة
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // جلب الثيم الأولي بناءً على الإعدادات المحفوظة
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
                  title: 'لوك إن',
                  debugShowCheckedModeBanner: false,
                  theme: myTheme,
                  localizationsDelegates: context.localizationDelegates,
                  supportedLocales: context.supportedLocales,
                  locale: context.locale,
                  initialRoute: Routes.splash,
                  onGenerateRoute: AppRouter.generateRoute,
                );
              },
            );
          },
        );
      },
    );
  }
}

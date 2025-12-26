import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart'; // للحفظ
import 'core/routes/app_router.dart';
import 'core/routes/routes.dart';
import 'core/theme/app_theme.dart';
import 'core/localization/localization_manager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Future<ThemeData> _getInitialTheme() async {
  final prefs = await SharedPreferences.getInstance();
  final isDark = prefs.getBool('is_dark_mode') ?? false;
  return isDark ? AppTheme.darkTheme : AppTheme.lightTheme;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

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

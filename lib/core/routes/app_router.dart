import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lockin/features/facts/views/facts_screen.dart';
import 'package:lockin/features/foucs_mode/cubit/focus_mode_cubit.dart';
import 'package:lockin/features/foucs_mode/views/foucs_mode_screen.dart';
import 'package:lockin/core/services/shared_prefs_service.dart';
import 'package:lockin/features/foucs_mode/services/installed_apps_service.dart';
import 'package:lockin/features/home/cubit/home_cubit.dart';
import 'package:lockin/features/noti/views/noti_screen.dart';
import 'routes.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/home/views/home_screen.dart';

/// Application Router
class AppRouter {
  AppRouter._();

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.splash:
        return _buildRoute(const SplashScreen(), settings);
      case Routes.onboarding:
        return _buildRoute(
          BlocProvider(
            create: (context) =>
                FocusModeCubit(SharedPrefsService(), InstalledAppsService()),
            child: const OnboardingScreen(),
          ),
          settings,
        );
      case Routes.home:
        return _buildRoute(const HomeScreen(), settings);
      case Routes.facts:
        final args = settings.arguments as UsagePeriod?;
        return _buildRoute(
          FactsScreen(period: args, minutesPerDay: 0),
          settings,
        );
      case Routes.focusMode:
        return _buildRoute(
          FocusModeScreen(
            prefsService: SharedPrefsService(),
            installedAppsService: InstalledAppsService(),
          ),
          settings,
        );

      case Routes.notifications:
        return _buildRoute(const NotificationsScreen(), settings);

      default:
        return _buildRoute(
          Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
          settings,
        );
    }
  }

  static PageRouteBuilder _buildRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOutCubic;

        var tween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));

        return SlideTransition(position: animation.drive(tween), child: child);
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  static void navigateTo(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    Navigator.pushNamed(context, routeName, arguments: arguments);
  }

  static void navigateAndReplace(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    Navigator.pushReplacementNamed(context, routeName, arguments: arguments);
  }

  static void navigateAndRemoveUntil(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }

  static void goBack(BuildContext context) {
    Navigator.pop(context);
  }
}

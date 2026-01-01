import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lockin/core/di/injection_container.dart';
import 'package:lockin/features/facts/views/facts_screen.dart';
import 'package:lockin/features/foucs_mode/cubit/focus_mode_cubit.dart';
import 'package:lockin/features/foucs_mode/views/foucs_mode_screen.dart';
import 'package:lockin/features/home/cubit/home_cubit.dart';
import 'package:lockin/features/home/views/home_screen.dart';
import 'package:lockin/features/noti/views/noti_screen.dart';
import 'package:lockin/features/onboarding/onboarding_screen.dart';
import 'package:lockin/features/splash/splash_screen.dart';
import 'routes.dart';

/// Application Router with Dependency Injection
class AppRouter {
  AppRouter._();

  // =================================================================
  // Route Generation
  // =================================================================

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.splash:
        return _buildRoute(const SplashScreen(), settings);

      case Routes.onboarding:
        return _buildRoute(_buildOnboardingScreen(), settings);

      case Routes.home:
        return _buildRoute(_buildHomeScreen(), settings);

      case Routes.focusMode:
        return _buildRoute(_buildFocusModeScreen(), settings);

      case Routes.notifications:
        return _buildRoute(const NotificationsScreen(), settings);

      case Routes.facts:
        return _buildRoute(_buildFactsScreen(settings), settings);

      default:
        return _buildRoute(_buildErrorScreen(settings), settings);
    }
  }

  // =================================================================
  // Screen Builders with Dependency Injection
  // =================================================================

  /// Build Onboarding Screen with FocusModeCubit
  static Widget _buildOnboardingScreen() {
    return BlocProvider(
      create: (context) => sl<FocusModeCubit>(),
      child: const OnboardingScreen(),
    );
  }

  /// Build Home Screen with multiple cubits
  static Widget _buildHomeScreen() {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => sl<HomeCubit>()..loadUsageData()),
        BlocProvider(
          create: (context) => sl<FocusModeCubit>()..checkActiveFocusMode(),
        ),
      ],
      child: const HomeScreen(),
    );
  }

  /// Build Focus Mode Screen with FocusModeCubit
  static Widget _buildFocusModeScreen() {
    return BlocProvider(
      create: (context) => sl<FocusModeCubit>()..loadApps(),
      child: const FocusModeScreen(),
    );
  }

  /// Build Facts Screen with arguments
  static Widget _buildFactsScreen(RouteSettings settings) {
    final args = _extractFactsArguments(settings);

    return FactsScreen(period: args.period, minutesPerDay: args.minutesPerDay);
  }

  /// Build error screen for undefined routes
  static Widget _buildErrorScreen(RouteSettings settings) {
    return Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'No route defined for ${settings.name}',
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // =================================================================
  // Argument Extraction
  // =================================================================

  /// Extract and validate Facts screen arguments
  static _FactsArguments _extractFactsArguments(RouteSettings settings) {
    final args = settings.arguments as Map<String, dynamic>?;

    return _FactsArguments(
      period: args?['period'] as UsagePeriod? ?? UsagePeriod.today,
      minutesPerDay: args?['minutesPerDay'] as int? ?? 0,
    );
  }

  // =================================================================
  // Route Builder
  // =================================================================

  /// Build page route with slide transition
  static PageRouteBuilder _buildRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: _slideTransition,
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  /// Slide transition animation
  static Widget _slideTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    const begin = Offset(1.0, 0.0);
    const end = Offset.zero;
    const curve = Curves.easeInOutCubic;

    final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

    return SlideTransition(position: animation.drive(tween), child: child);
  }

  // =================================================================
  // Navigation Helpers
  // =================================================================

  /// Navigate to a route
  static Future<T?> navigateTo<T>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.pushNamed<T>(context, routeName, arguments: arguments);
  }

  /// Navigate and replace current route
  static Future<T?> navigateAndReplace<T>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.pushReplacementNamed<T, dynamic>(
      context,
      routeName,
      arguments: arguments,
    );
  }

  /// Navigate and remove all previous routes
  static Future<T?> navigateAndRemoveUntil<T>(
    BuildContext context,
    String routeName, {
    Object? arguments,
    bool Function(Route<dynamic>)? predicate,
  }) {
    return Navigator.pushNamedAndRemoveUntil<T>(
      context,
      routeName,
      predicate ?? (route) => false,
      arguments: arguments,
    );
  }

  /// Go back to previous route
  static void goBack<T>(BuildContext context, [T? result]) {
    Navigator.pop<T>(context, result);
  }

  /// Check if can go back
  static bool canGoBack(BuildContext context) {
    return Navigator.canPop(context);
  }

  /// Navigate to home and clear stack
  static Future<void> navigateToHome(BuildContext context) {
    return navigateAndRemoveUntil(context, Routes.home);
  }

  /// Navigate to facts screen with arguments
  static Future<void> navigateToFacts(
    BuildContext context, {
    required UsagePeriod period,
    required int minutesPerDay,
  }) {
    return navigateTo(
      context,
      Routes.facts,
      arguments: {'period': period, 'minutesPerDay': minutesPerDay},
    );
  }

  /// Navigate to focus mode
  static Future<void> navigateToFocusMode(BuildContext context) {
    return navigateTo(context, Routes.focusMode);
  }

  /// Navigate to notifications
  static Future<void> navigateToNotifications(BuildContext context) {
    return navigateTo(context, Routes.notifications);
  }
}

// =================================================================
// Helper Classes
// =================================================================

/// Facts screen arguments
class _FactsArguments {
  final UsagePeriod period;
  final int minutesPerDay;

  _FactsArguments({required this.period, required this.minutesPerDay});
}

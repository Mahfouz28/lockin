part of 'home_cubit.dart';

enum UsagePeriod { today, weekly, monthly }

class AppUsageEntry {
  final String packageName;
  final String appName;
  final Uint8List? icon;
  final int minutes;

  AppUsageEntry({
    required this.packageName,
    required this.appName,
    this.icon,
    required this.minutes,
  });
}

class HomeState {
  final List<AppUsageEntry> apps;
  final UsagePeriod period;
  final bool isLoading;
  final String? error;
  final int totalMinutes;

  // Averages
  final int dailyAverage;
  final int weeklyAverage;
  final int monthlyAverage;

  // Warnings
  final String? usageWarning;

  // Most used app (new)
  final String? mostUsedApp;

  HomeState({
    this.apps = const [],
    this.period = UsagePeriod.today,
    this.isLoading = false,
    this.error,
    this.totalMinutes = 0,
    this.dailyAverage = 0,
    this.weeklyAverage = 0,
    this.monthlyAverage = 0,
    this.usageWarning,
    this.mostUsedApp,
  });

  HomeState copyWith({
    List<AppUsageEntry>? apps,
    UsagePeriod? period,
    bool? isLoading,
    String? error,
    int? totalMinutes,
    int? dailyAverage,
    int? weeklyAverage,
    int? monthlyAverage,
    String? usageWarning,
    String? mostUsedApp,
  }) {
    return HomeState(
      apps: apps ?? this.apps,
      period: period ?? this.period,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      totalMinutes: totalMinutes ?? this.totalMinutes,
      dailyAverage: dailyAverage ?? this.dailyAverage,
      weeklyAverage: weeklyAverage ?? this.weeklyAverage,
      monthlyAverage: monthlyAverage ?? this.monthlyAverage,
      usageWarning: usageWarning ?? this.usageWarning,
      mostUsedApp: mostUsedApp ?? this.mostUsedApp,
    );
  }
}

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

  HomeState({
    this.apps = const [],
    this.period = UsagePeriod.today,
    this.isLoading = false,
    this.error,
    this.totalMinutes = 0,
  });

  HomeState copyWith({
    List<AppUsageEntry>? apps,
    UsagePeriod? period,
    bool? isLoading,
    String? error,
    int? totalMinutes,
    int? totalMonthlyAvg,
    int? totalYearlyAvg,
  }) {
    return HomeState(
      apps: apps ?? this.apps,
      period: period ?? this.period,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      totalMinutes: totalMinutes ?? this.totalMinutes,
    );
  }
}

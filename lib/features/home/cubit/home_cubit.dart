import 'dart:typed_data';
import 'package:app_usage/app_usage.dart';
import 'package:bloc/bloc.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:installed_apps/app_info.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final Map<String, AppInfo> _appsMap = {};

  HomeCubit() : super(HomeState()) {
    _loadInstalledApps().then((_) => loadUsageData());
  }

  Future<void> _loadInstalledApps() async {
    try {
      List<AppInfo> apps = await InstalledApps.getInstalledApps(
        excludeSystemApps: true,
        withIcon: true,
      );

      for (var app in apps) {
        if (app.packageName.isNotEmpty) {
          _appsMap[app.packageName] = app;
        }
      }
    } catch (e) {
      print('Error loading installed apps: $e');
    }
  }

  int calculateMonthlyAverage(int weeklyMinutes) {
    const double weeksInMonth = 4.345;
    return (weeklyMinutes * weeksInMonth).round();
  }

  int calculateYearlyAverage(int weeklyMinutes) {
    const double weeksInYear = 52.143;
    return (weeklyMinutes * weeksInYear).round();
  }

  Future<void> loadUsageData({UsagePeriod? period}) async {
    emit(state.copyWith(isLoading: true, period: period ?? state.period));

    try {
      DateTime end = DateTime.now();
      DateTime start;

      switch (state.period) {
        case UsagePeriod.today:
          start = DateTime(end.year, end.month, end.day);
          break;

        case UsagePeriod.weekly:
          start = end.subtract(const Duration(days: 7));
          break;

        case UsagePeriod.monthly:
          start = end.subtract(const Duration(days: 30));
          break;
      }

      List<AppUsageInfo> usageList = await AppUsage().getAppUsage(start, end);

      List<AppUsageEntry> appList = [];
      int totalWeeklyMinutes = 0;

      for (var usage in usageList) {
        if (usage.usage.inMinutes == 0) continue;

        AppInfo? appInfo = _appsMap[usage.packageName];
        int minutes = usage.usage.inMinutes;
        totalWeeklyMinutes += minutes;

        appList.add(
          AppUsageEntry(
            packageName: usage.packageName,
            appName: appInfo?.name ?? usage.packageName.split('.').last,
            icon: appInfo?.icon,
            minutes: minutes,
          ),
        );
      }

      appList.sort((a, b) => b.minutes.compareTo(a.minutes));

      // Only calculate monthly/yearly averages if weekly data is available
      int totalMonthlyAvg = calculateMonthlyAverage(totalWeeklyMinutes);
      int totalYearlyAvg = calculateYearlyAverage(totalWeeklyMinutes);

      emit(
        state.copyWith(
          apps: appList,
          isLoading: false,
          totalMinutes: totalWeeklyMinutes,
          totalMonthlyAvg: totalMonthlyAvg,
          totalYearlyAvg: totalYearlyAvg,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: 'فشل جلب البيانات: $e'));
    }
  }

  void changePeriod(UsagePeriod period) {
    loadUsageData(period: period);
  }

  @override
  Future<void> close() {
    return super.close();
  }
}

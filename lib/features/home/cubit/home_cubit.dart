import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:app_usage/app_usage.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:installed_apps/app_info.dart';
import 'package:lockin/core/services/shared_prefs_service.dart';
import 'package:workmanager/workmanager.dart';

part 'home_state.dart';

const String hourlyUsageTask = "hourly_usage_task";

class HomeCubit extends Cubit<HomeState> {
  final Map<String, AppInfo> _appsMap = {};
  Timer? _foregroundTimer;

  HomeCubit() : super(HomeState()) {
    _init();
  }

  Future<void> _init() async {
    await _loadInstalledApps();
    await loadUsageData();
    _startForegroundHourlyNotifications();

    // Register background task with Workmanager
    Workmanager().initialize(
      _backgroundTaskDispatcher,
      isInDebugMode: kDebugMode,
    );
    Workmanager().registerPeriodicTask(
      "hourly_usage_task_unique",
      hourlyUsageTask,
      frequency: const Duration(hours: 1),
    );
  }

  Future<void> _loadInstalledApps() async {
    try {
      List<AppInfo> apps = await InstalledApps.getInstalledApps(
        excludeSystemApps: true,
        withIcon: true,
      );

      for (var app in apps) {
        if (app.packageName.isNotEmpty) _appsMap[app.packageName] = app;
      }
    } catch (e) {
      if (kDebugMode) print('Error loading installed apps: $e');
    }
  }

  int calculateDailyAverage(int weeklyMinutes) => (weeklyMinutes / 7).round();
  int calculateWeeklyAverage(int weeklyMinutes) => weeklyMinutes;
  int calculateMonthlyAverage(int weeklyMinutes) =>
      (weeklyMinutes * 4.345).round();

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
      int totalMinutesInPeriod = 0;
      String mostUsedApp = '';

      for (var usage in usageList) {
        if (usage.usage.inMinutes == 0) continue;

        AppInfo? appInfo = _appsMap[usage.packageName];
        int minutes = usage.usage.inMinutes;
        totalMinutesInPeriod += minutes;

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
      if (appList.isNotEmpty) mostUsedApp = appList.first.appName;

      int dailyAvg = calculateDailyAverage(totalMinutesInPeriod);
      int weeklyAvg = calculateWeeklyAverage(totalMinutesInPeriod);
      int monthlyAvg = calculateMonthlyAverage(totalMinutesInPeriod);

      String? usageWarning;
      if (dailyAvg >= 180)
        usageWarning = tr('usage_warning.daily_limit_exceeded');

      emit(
        state.copyWith(
          apps: appList,
          isLoading: false,
          totalMinutes: totalMinutesInPeriod,
          dailyAverage: dailyAvg,
          weeklyAverage: weeklyAvg,
          monthlyAverage: monthlyAvg,
          mostUsedApp: mostUsedApp,
          usageWarning: usageWarning,
          error: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          error: tr('error.failed_to_fetch_usage', args: [e.toString()]),
        ),
      );
      if (kDebugMode) print('Usage data error: $e');
    }
  }

  void changePeriod(UsagePeriod period) => loadUsageData(period: period);

  void _startForegroundHourlyNotifications() {
    _foregroundTimer?.cancel();
    _foregroundTimer = Timer.periodic(const Duration(hours: 1), (_) async {
      await _sendNotification();
    });
  }

  Future<void> _sendNotification() async {
    String mostUsedApp = state.mostUsedApp ?? '';
    int totalHours = (state.totalMinutes / 60).round();

    String title = tr('usage_notification.title');
    String body = tr(
      'usage_notification.body',
      args: [totalHours.toString(), mostUsedApp],
    );

    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    const androidDetails = AndroidNotificationDetails(
      'hourly_usage_channel',
      'Hourly Usage',
      channelDescription: 'Notifies you about phone usage every hour',
      importance: Importance.max,
      priority: Priority.high,
    );

    const iOSDetails = DarwinNotificationDetails();
    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iOSDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      notificationDetails,
    );

    await SharedPrefsService().addNotification(title, body);
  }

  @override
  Future<void> close() async {
    _foregroundTimer?.cancel();
    return super.close();
  }
}

// Workmanager background task
void _backgroundTaskDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == hourlyUsageTask) {
      final prefs = SharedPrefsService();
      final usageList = await AppUsage().getAppUsage(
        DateTime.now().subtract(const Duration(hours: 1)),
        DateTime.now(),
      );

      int totalMinutes = 0;
      String mostUsedApp = '';
      final Map<String, int> usageMap = {};

      for (var u in usageList) {
        usageMap[u.packageName] = u.usage.inMinutes;
        totalMinutes += u.usage.inMinutes;
      }

      if (usageMap.isNotEmpty) {
        final topApp = usageMap.entries.reduce(
          (a, b) => a.value > b.value ? a : b,
        );
        mostUsedApp = topApp.key.split('.').last;
      }

      int totalHours = (totalMinutes / 60).round();
      String title = tr('usage_notification.title');
      String body = tr(
        'usage_notification.body',
        args: [totalHours.toString(), mostUsedApp],
      );

      final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
          FlutterLocalNotificationsPlugin();

      const androidDetails = AndroidNotificationDetails(
        'hourly_usage_channel',
        'Hourly Usage',
        channelDescription: 'Notifies you about phone usage every hour',
        importance: Importance.max,
        priority: Priority.high,
      );

      const iOSDetails = DarwinNotificationDetails();
      final notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iOSDetails,
      );

      await flutterLocalNotificationsPlugin.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title,
        body,
        notificationDetails,
      );

      await prefs.addNotification(title, body);
    }
    return Future.value(true);
  });
}

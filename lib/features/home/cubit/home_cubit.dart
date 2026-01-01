// lib/features/home/cubit/home_cubit.dart

import 'dart:async';
import 'package:app_usage/app_usage.dart';
import 'package:bloc/bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:installed_apps/app_info.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:lockin/core/services/notifcation_service.dart';
import 'package:lockin/core/services/shared_prefs_service.dart';
import 'package:workmanager/workmanager.dart';

part 'home_state.dart';

const String hourlyUsageTask = "hourly_usage_task";
const String hourlyUsageUniqueId = "hourly_usage_unique";

class HomeCubit extends Cubit<HomeState> {
  final NotificationService _notificationService;
  final Map<String, AppInfo> _appsMap = {};
  Timer? _foregroundTimer;

  HomeCubit(this._notificationService) : super(HomeState()) {
    _initialize();
  }

  // =================================================================
  // Initialization
  // =================================================================

  Future<void> _initialize() async {
    await _loadInstalledApps();
    await loadUsageData();
    _startForegroundHourlyCheck();
    await _registerBackgroundTask();
  }

  /// Load all installed apps info
  Future<void> _loadInstalledApps() async {
    try {
      final List<AppInfo> apps = await InstalledApps.getInstalledApps(
        excludeSystemApps: true,
        withIcon: true,
      );

      for (final app in apps) {
        if (app.packageName.isNotEmpty) {
          _appsMap[app.packageName] = app;
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading installed apps: $e');
      }
    }
  }

  /// Register background hourly notification task
  Future<void> _registerBackgroundTask() async {
    try {
      await Workmanager().registerPeriodicTask(
        hourlyUsageUniqueId,
        hourlyUsageTask,
        frequency: const Duration(hours: 1),
        initialDelay: const Duration(minutes: 5),
        constraints: Constraints(networkType: NetworkType.not_required),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error registering background task: $e');
      }
    }
  }

  // =================================================================
  // Usage Data Management
  // =================================================================

  /// Load usage data for the selected period
  Future<void> loadUsageData({UsagePeriod? forcedPeriod}) async {
    final period = forcedPeriod ?? state.period;
    emit(state.copyWith(isLoading: true, period: period));

    try {
      final dateRange = _getDateRange(period);
      final usageList = await _fetchUsageData(dateRange);
      final processedData = _processUsageData(usageList, period);

      emit(
        state.copyWith(
          apps: processedData.apps,
          totalMinutes: processedData.totalMinutes,
          dailyAverage: processedData.dailyAverage,
          mostUsedApp: processedData.mostUsedApp,
          isLoading: false,
          error: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          error: tr('no_usage_data'),
        ),
      );
      
      if (kDebugMode) {
        print('Usage data error: $e');
      }
    }
  }

  /// Change usage period and reload data
  void changePeriod(UsagePeriod period) {
    loadUsageData(forcedPeriod: period);
  }

  // =================================================================
  // Notification Management
  // =================================================================

  /// Start foreground hourly notification timer
  void _startForegroundHourlyCheck() {
    _foregroundTimer?.cancel();
    
    _foregroundTimer = Timer.periodic(
      const Duration(hours: 1),
      (_) => _triggerHourlyNotification(),
    );
  }

  /// Trigger hourly usage notification
  Future<void> _triggerHourlyNotification() async {
    final totalHours = (state.totalMinutes / 60).round();
    final mostUsed = state.mostUsedApp ?? tr('usage_notification.unknown_app');

    await _notificationService.showGeneralNotification(
      title: tr('usage_notification.title'),
      body: tr(
        'usage_notification.body',
        args: [totalHours.toString(), mostUsed],
      ),
      id: DateTime.now().hour,
    );
  }

  // =================================================================
  // Private Helper Methods
  // =================================================================

  /// Get date range for the selected period
  _DateRange _getDateRange(UsagePeriod period) {
    final end = DateTime.now();
    final DateTime start;

    switch (period) {
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

    return _DateRange(start: start, end: end);
  }

  /// Fetch usage data from AppUsage
  Future<List<AppUsageInfo>> _fetchUsageData(_DateRange range) async {
    return await AppUsage().getAppUsage(range.start, range.end);
  }

  /// Process raw usage data into structured format
  _ProcessedUsageData _processUsageData(
    List<AppUsageInfo> usageList,
    UsagePeriod period,
  ) {
    int totalMinutesInPeriod = 0;
    final List<AppUsageEntry> appList = [];

    for (final usage in usageList) {
      if (usage.usage.inMinutes == 0) continue;

      final appInfo = _appsMap[usage.packageName];
      final minutes = usage.usage.inMinutes;
      totalMinutesInPeriod += minutes;

      appList.add(
        AppUsageEntry(
          packageName: usage.packageName,
          appName: appInfo?.name ?? _extractAppName(usage.packageName),
          icon: appInfo?.icon,
          minutes: minutes,
        ),
      );
    }

    appList.sort((a, b) => b.minutes.compareTo(a.minutes));

    final mostUsedApp = appList.isEmpty
        ? tr('usage_notification.unknown_app')
        : appList.first.appName;

    final dailyAverage = _calculateDailyAverage(
      totalMinutesInPeriod,
      period,
    );

    return _ProcessedUsageData(
      apps: appList,
      totalMinutes: totalMinutesInPeriod,
      dailyAverage: dailyAverage,
      mostUsedApp: mostUsedApp,
    );
  }

  /// Extract app name from package name
  String _extractAppName(String packageName) {
    return packageName.split('.').last;
  }

  /// Calculate daily average based on period
  int _calculateDailyAverage(int periodMinutes, UsagePeriod period) {
    switch (period) {
      case UsagePeriod.today:
        return periodMinutes;
      case UsagePeriod.weekly:
        return (periodMinutes / 7).round();
      case UsagePeriod.monthly:
        return (periodMinutes / 30).round();
    }
  }

  // =================================================================
  // Cleanup
  // =================================================================

  @override
  Future<void> close() async {
    _foregroundTimer?.cancel();
    await super.close();
  }
}

// =================================================================
// Helper Classes
// =================================================================

class _DateRange {
  final DateTime start;
  final DateTime end;

  _DateRange({required this.start, required this.end});
}

class _ProcessedUsageData {
  final List<AppUsageEntry> apps;
  final int totalMinutes;
  final int dailyAverage;
  final String mostUsedApp;

  _ProcessedUsageData({
    required this.apps,
    required this.totalMinutes,
    required this.dailyAverage,
    required this.mostUsedApp,
  });
}

// =================================================================
// Background Task Dispatcher
// =================================================================

@pragma('vm:entry-point')
void backgroundTaskDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task != hourlyUsageTask) {
      return Future.value(false);
    }

    try {
      await _executeHourlyNotificationTask();
      return Future.value(true);
    } catch (e) {
      if (kDebugMode) {
        print('Background hourly task error: $e');
      }
      return Future.value(false);
    }
  });
}

/// Execute hourly notification in background
Future<void> _executeHourlyNotificationTask() async {
  await NotificationService().initialize();

  final prefs = SharedPrefsService();
  await prefs.init();
  
  final langCode = await prefs.getString('app_language');
  final texts = _getLocalizedTexts(langCode ?? 'en');

  final usageData = await _fetchLastHourUsage();
  final notificationBody = _formatNotificationBody(texts, usageData);

  await NotificationService().showGeneralNotification(
    title: texts['title']!,
    body: notificationBody,
    id: 999,
  );

  if (kDebugMode) {
    print('Background hourly notification sent: $notificationBody');
  }
}

/// Get localized texts for background notification
Map<String, String> _getLocalizedTexts(String langCode) {
  const localizedTexts = {
    'en': {
      'title': 'Hourly Usage Update',
      'body': 'You spent {hours} hours today. Most used: {app}',
      'unknown': 'your phone',
    },
    'ar': {
      'title': 'تحديث الاستخدام الساعي',
      'body': 'قضيت {hours} ساعة اليوم. الأكثر استخدامًا: {app}',
      'unknown': 'تليفونك',
    },
  };

  return localizedTexts[langCode] ?? localizedTexts['en']!;
}

/// Fetch usage data for the last hour
Future<_HourlyUsageData> _fetchLastHourUsage() async {
  final end = DateTime.now();
  final start = end.subtract(const Duration(hours: 1));

  final usageList = await AppUsage().getAppUsage(start, end);

  if (usageList.isEmpty) {
    return _HourlyUsageData(
      totalMinutes: 0,
      mostUsedApp: '',
    );
  }

  final totalMinutes = usageList.fold(
    0,
    (sum, u) => sum + u.usage.inMinutes,
  );

  final topApp = usageList.reduce(
    (a, b) => a.usage.inMinutes > b.usage.inMinutes ? a : b,
  );

  return _HourlyUsageData(
    totalMinutes: totalMinutes,
    mostUsedApp: topApp.packageName.split('.').last,
  );
}

/// Format notification body with usage data
String _formatNotificationBody(
  Map<String, String> texts,
  _HourlyUsageData usageData,
) {
  final totalHours = (usageData.totalMinutes / 60).round();
  final mostUsedApp = usageData.mostUsedApp.isEmpty
      ? texts['unknown']!
      : usageData.mostUsedApp;

  return texts['body']!
      .replaceAll('{hours}', totalHours.toString())
      .replaceAll('{app}', mostUsedApp);
}

class _HourlyUsageData {
  final int totalMinutes;
  final String mostUsedApp;

  _HourlyUsageData({
    required this.totalMinutes,
    required this.mostUsedApp,
  });
}
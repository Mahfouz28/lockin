import 'package:workmanager/workmanager.dart';
import 'package:app_usage/app_usage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/overlay_service.dart';

const String monitorTask = "appUsageMonitorTask";

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == monitorTask) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final bool isFocusModeActive =
            prefs.getBool('focus_mode_active') ?? false;
        final List<String> restrictedApps =
            prefs.getStringList('restricted_apps') ?? [];

        if (!isFocusModeActive || restrictedApps.isEmpty) return true;

        // جلب التطبيقات المستخدمة في آخر 5 ثواني
        DateTime endTime = DateTime.now();
        DateTime startTime = endTime.subtract(const Duration(seconds: 5));

        List<AppUsageInfo> usageList = await AppUsage().getAppUsage(
          startTime,
          endTime,
        );

        for (var info in usageList) {
          if (restrictedApps.contains(info.packageName)) {
            // التطبيق محظور → نعرض الـ overlay
            await OverlayService.showLockScreen(info.appName);
            break;
          }
        }
      } catch (e) {
        print("خطأ في التتبع: $e");
      }
    }
    return Future.value(true);
  });
}

class BackgroundMonitor {
  static Future<void> initialize() async {
    await Workmanager().initialize(callbackDispatcher, isInDebugMode: true);

    // تشغيل كل 15 ثانية (الحد الأدنى في أندرويد 13+ هو 15 دقيقة، لكن في الـ debug بيشتغل أسرع)
    await Workmanager().registerPeriodicTask(
      "1",
      monitorTask,
      frequency: const Duration(seconds: 15), // هيشتغل كل 15 ثانية في الـ debug
      constraints: Constraints(networkType: NetworkType.not_required),
    );
  }

  static Future<void> startMonitoring() async {
    await Workmanager().registerPeriodicTask(
      "1",
      monitorTask,
      frequency: const Duration(minutes: 15),
    );
  }

  static Future<void> stopMonitoring() async {
    await Workmanager().cancelAll();
  }
}

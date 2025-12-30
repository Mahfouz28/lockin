import 'package:app_usage/app_usage.dart';

class InstalledAppsService {
  Future<List<AppUsageInfo>> getInstalledApps() async {
    try {
      DateTime endDate = DateTime.now();
      DateTime startDate = endDate.subtract(Duration(days: 1));

      List<AppUsageInfo> infoList = await AppUsage().getAppUsage(
        startDate,
        endDate,
      );

      return infoList;
    } catch (exception) {
      print(exception);
      return [];
    }
  }
}

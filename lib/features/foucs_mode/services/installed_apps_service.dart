// lib/features/foucs_mode/services/installed_apps_service.dart

import 'package:installed_apps/installed_apps.dart';
import 'package:installed_apps/app_info.dart';

class InstalledAppsService {
  Future<List<AppInfo>> getInstalledApps() async {
    return await InstalledApps.getInstalledApps(withIcon: true);
  }
}

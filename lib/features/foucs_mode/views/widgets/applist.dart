// lib/features/foucs_mode/views/widgets/components/apps_list.dart

import 'package:flutter/material.dart';
import 'package:lockin/features/foucs_mode/views/widgets/app_card.dart';

class AppsList extends StatelessWidget {
  final List<dynamic> displayedApps;
  final List<dynamic> allApps;
  final bool isDark;

  const AppsList({
    super.key,
    required this.displayedApps,
    required this.allApps,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: displayedApps
          .map((app) => AppCard(app: app, allApps: allApps, isDark: isDark))
          .toList(),
    );
  }
}

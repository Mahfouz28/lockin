// lib/features/home/widgets/usage_pie_chart.dart
import 'dart:typed_data';

import 'package:easy_localization/easy_localization.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lockin/core/theme/colors.dart';
import 'package:lockin/features/home/cubit/home_cubit.dart';

class UsagePieChart extends StatelessWidget {
  final List<AppUsageEntry> apps;
  final int totalMinutes;

  const UsagePieChart({
    super.key,
    required this.apps,
    required this.totalMinutes,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    /// Top 5 + Other
    final List<AppUsageEntry> chartApps = apps.take(5).toList();
    final int usedMinutes = chartApps.fold(0, (sum, app) => sum + app.minutes);
    final int otherMinutes = totalMinutes - usedMinutes;

    if (otherMinutes > 0) {
      chartApps.add(
        AppUsageEntry(
          packageName: 'other',
          appName: 'Other',
          minutes: otherMinutes,
          icon: null,
        ),
      );
    }

    final List<Color> colors = [
      AppColors.primaryLight,
      AppColors.secondary,
      Colors.purple,
      Colors.orange,
      Colors.red,
    ];

    final List<PieChartSectionData> sections = List.generate(chartApps.length, (
      i,
    ) {
      final color = colors[i % colors.length];
      final app = chartApps[i];

      return PieChartSectionData(
        value: app.minutes.toDouble(),
        color: color,
        radius: 80.r,
        title: '',
        badgeWidget: PieLabel(text: app.appName, color: color, icon: app.icon),
        badgePositionPercentageOffset: 1.35,
      );
    });

    final String totalTime = totalMinutes >= 60
        ? '${(totalMinutes / 60).toStringAsFixed(1)}h'
        : '${totalMinutes}m';

    return Container(
      height: 350.h,
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      child: Stack(
        alignment: Alignment.center,
        children: [
          PieChart(
            PieChartData(
              sections: sections,
              centerSpaceRadius: 70.r,
              sectionsSpace: 4,
              startDegreeOffset: -90,
            ),
            swapAnimationDuration: const Duration(milliseconds: 900),
            swapAnimationCurve: Curves.easeOutCubic,
          ),

          /// Total time في المنتصف
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                totalTime,
                style: TextStyle(
                  fontSize: 36.sp,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                "Total time".tr(),
                style: TextStyle(
                  fontSize: 16.sp,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class PieLabel extends StatelessWidget {
  final String text;
  final Color color;
  final Uint8List? icon;

  const PieLabel({
    super.key,
    required this.text,
    required this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        /// السهم
        Container(width: 18.w, height: 2.h, color: color),
        SizedBox(width: 6.w),

        /// أيقونة التطبيق
        if (icon != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(6.r),
            child: Image.memory(
              icon!,
              width: 18.w,
              height: 18.w,
              fit: BoxFit.cover,
            ),
          ),

        if (icon != null) SizedBox(width: 6.w),

        /// اسم التطبيق
        Text(
          text,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
      ],
    );
  }
}

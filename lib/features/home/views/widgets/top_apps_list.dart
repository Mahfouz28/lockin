// lib/features/home/widgets/top_apps_list.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:lockin/core/theme/colors.dart';
import 'package:lockin/features/home/cubit/home_cubit.dart';

class TopAppsList extends StatelessWidget {
  final List<AppUsageEntry> apps; // ناخد الـ apps كـ parameter

  const TopAppsList({super.key, required this.apps});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (apps.isEmpty) {
      return Center(child: Text('no_usage_data'.tr()));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'top_apps_today'.tr(),
          style: TextStyle(
            fontSize: 22.sp,
            fontWeight: FontWeight.bold,
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
          ),
        ),
        SizedBox(height: 16.h),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: apps.length > 10 ? 10 : apps.length,
          itemBuilder: (context, index) {
            final app = apps[index];
            final hours = app.minutes ~/ 60;
            final mins = app.minutes % 60;

            return Card(
              margin: EdgeInsets.symmetric(vertical: 8.h),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: ListTile(
                leading: app.icon != null
                    ? Image.memory(
                        app.icon!,
                        width: 48.w,
                        height: 48.h,
                        fit: BoxFit.contain,
                      )
                    : CircleAvatar(
                        backgroundColor: AppColors.primaryLight.withOpacity(
                          0.2,
                        ),
                        child: Icon(Icons.apps, color: AppColors.primaryLight),
                      ),
                title: Text(
                  app.appName,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16.sp,
                  ),
                ),
                trailing: Text(
                  hours > 0 ? '$hours h $mins m' : '$mins m',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryLight,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

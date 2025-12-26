// lib/features/home/widgets/usage_period_tabs.dart
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lockin/core/theme/colors.dart';
import 'package:lockin/features/home/cubit/home_cubit.dart';

class UsagePeriodTabs extends StatelessWidget {
  final UsagePeriod currentPeriod;
  final Function(UsagePeriod) onPeriodChanged;

  const UsagePeriodTabs({
    super.key,
    required this.currentPeriod,
    required this.onPeriodChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(30.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: UsagePeriod.values.map((period) {
          bool isSelected = currentPeriod == period;
          return Expanded(
            child: GestureDetector(
              onTap: () => onPeriodChanged(period),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primaryLight
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(30.r),
                ),
                child: Text(
                  period.localizationKey.tr().toUpperCase(),

                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected
                        ? AppColors.textOnPrimary
                        : (isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight),
                    fontSize: 14.sp,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

extension UsagePeriodX on UsagePeriod {
  String get localizationKey {
    switch (this) {
      case UsagePeriod.today:
        return 'period.today';
      case UsagePeriod.weekly:
        return 'period.weekly';
      case UsagePeriod.monthly:
        return 'period.monthly';
    }
  }
}

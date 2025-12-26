// lib/features/home/widgets/focus_card.dart
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lockin/core/theme/colors.dart';

class FocusCard extends StatelessWidget {
  const FocusCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        gradient: isDark ? AppColors.darkGradient : AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: (isDark ? AppColors.primaryVariant : AppColors.primaryLight)
                .withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.self_improvement,
            size: 64.sp,
            color: AppColors.textOnPrimary,
          ),
          SizedBox(height: 16.h),
          Text(
            'ready_to_focus'.tr(),
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textOnPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'start_tracking'.tr(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16.sp,
              color: AppColors.textOnPrimary.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }
}

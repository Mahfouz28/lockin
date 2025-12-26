// lib/features/home/widgets/welcome_section.dart
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lockin/core/theme/colors.dart';

class WelcomeSection extends StatelessWidget {
  const WelcomeSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
    final textSecondary = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'welcome_message'.tr(),
          style: TextStyle(
            fontSize: 28.sp,
            fontWeight: FontWeight.bold,
            color: textPrimary,
            shadows: isDark
                ? []
                : [
                    Shadow(
                      offset: const Offset(1, 1),
                      blurRadius: 2,
                      color: Colors.black.withOpacity(0.1),
                    ),
                  ],
          ),
        ),
        SizedBox(height: 10.h),
        Text(
          'focus_today'.tr(),
          style: TextStyle(fontSize: 16.sp, color: textSecondary),
        ),
        SizedBox(height: 32.h),
      ],
    );
  }
}

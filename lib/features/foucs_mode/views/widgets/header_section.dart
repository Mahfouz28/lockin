// lib/features/foucs_mode/views/widgets/components/header_section.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:lockin/core/theme/colors.dart';

class HeaderSection extends StatelessWidget {
  final bool isDark;

  const HeaderSection({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tr('select_apps_and_duration'),
          style: TextStyle(
            fontSize: 28.sp,
            fontWeight: FontWeight.bold,
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
            height: 1.2,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          tr('focus_mode.subtitle'),
          style: TextStyle(
            fontSize: 14.sp,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

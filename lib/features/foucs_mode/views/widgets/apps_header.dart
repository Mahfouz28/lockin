// lib/features/foucs_mode/views/widgets/components/apps_header.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:lockin/core/theme/colors.dart';

class AppsHeader extends StatelessWidget {
  final bool isDark;
  final int selectedCount;

  const AppsHeader({
    super.key,
    required this.isDark,
    required this.selectedCount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            tr('select_apps_to_block'),
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
        ),
        if (selectedCount > 0) _SelectedBadge(selectedCount: selectedCount),
      ],
    );
  }
}

class _SelectedBadge extends StatelessWidget {
  final int selectedCount;

  const _SelectedBadge({required this.selectedCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        gradient: AppColors.successGradient,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.success.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        '$selectedCount selected',
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.bold,
          color: AppColors.textOnPrimary,
        ),
      ),
    );
  }
}

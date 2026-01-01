// lib/features/foucs_mode/views/widgets/components/show_more_button.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:lockin/core/theme/colors.dart';

class ShowMoreButton extends StatelessWidget {
  final VoidCallback onPressed;

  const ShowMoreButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        child: TextButton.icon(
          onPressed: onPressed,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.primaryLight,
            size: 24.sp,
          ),
          label: Text(
            tr('show_more'),
            style: TextStyle(
              fontSize: 16.sp,
              color: AppColors.primaryLight,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
            backgroundColor: AppColors.primaryLight.withOpacity(0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
        ),
      ),
    );
  }
}

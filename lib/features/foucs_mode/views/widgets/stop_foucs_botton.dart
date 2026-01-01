// lib/features/foucs_mode/views/widgets/components/stop_focus_button.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:lockin/core/theme/colors.dart';

class StopFocusButton extends StatelessWidget {
  final VoidCallback onPressed;

  const StopFocusButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 40.w),
      child: SizedBox(
        width: double.infinity,
        height: 64.h,
        child: ElevatedButton(
          onPressed: onPressed,
          style: _buildButtonStyle(),
          child: _buildButtonContent(),
        ),
      ),
    );
  }

  ButtonStyle _buildButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: AppColors.surfaceLight,
      foregroundColor: AppColors.primary,
      elevation: 28,
      shadowColor: AppColors.primaryLight.withOpacity(0.7),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32.r)),
    );
  }

  Widget _buildButtonContent() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.stop_circle_outlined, size: 24.sp, color: AppColors.error),
        SizedBox(width: 12.w),
        Text(
          tr('focus_mode.stop_focus_button'),
          style: TextStyle(
            fontSize: 19.sp,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

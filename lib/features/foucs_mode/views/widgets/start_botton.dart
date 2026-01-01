// lib/features/foucs_mode/views/widgets/components/start_button.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:lockin/core/theme/colors.dart';
import 'package:lockin/core/widgets/custom_button.dart';
import 'package:lockin/features/foucs_mode/cubit/focus_mode_cubit.dart';

class StartButton extends StatelessWidget {
  final FocusModeLoaded state;
  final int selectedCount;
  final VoidCallback onPressed;

  const StartButton({
    super.key,
    required this.state,
    required this.selectedCount,
    required this.onPressed,
  });

  bool get _isEnabled =>
      state.selectedDuration != null &&
      state.selectedDuration! >= 5 &&
      selectedCount > 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (!_isEnabled && selectedCount == 0) _ValidationWarning(),
        CustomButton(
          text: tr('start_focus_button'),
          onPressed: _isEnabled ? onPressed : null,
          height: 60.h,
          borderRadius: 30.r,
        ),
      ],
    );
  }
}

class _ValidationWarning extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.warning.withOpacity(0.3), width: 1),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: AppColors.warning,
            size: 20.sp,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              tr('validation.select_at_least_one_app'),
              style: TextStyle(
                fontSize: 13.sp,
                color: AppColors.warning,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

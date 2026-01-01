// lib/features/foucs_mode/views/widgets/components/timer_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import 'package:lockin/core/theme/colors.dart';

class TimerCard extends StatelessWidget {
  final bool isDark;
  final double selectedMinutes;
  final ValueChanged<double> onChanged;

  const TimerCard({
    super.key,
    required this.isDark,
    required this.selectedMinutes,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: _buildDecoration(),
      child: Column(
        children: [
          _buildSlider(context),
          SizedBox(height: 16.h),
          _RecommendationTip(isDark: isDark),
        ],
      ),
    );
  }

  BoxDecoration _buildDecoration() {
    return BoxDecoration(
      gradient: isDark
          ? LinearGradient(
              colors: [AppColors.primaryVariant, AppColors.primary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )
          : LinearGradient(
              colors: [
                AppColors.primaryLight.withOpacity(0.1),
                AppColors.accent.withOpacity(0.08),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
      borderRadius: BorderRadius.circular(24.r),
      border: Border.all(
        color: isDark ? AppColors.borderDark : AppColors.borderLight,
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: isDark
              ? Colors.black.withOpacity(0.3)
              : AppColors.primaryLight.withOpacity(0.1),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  Widget _buildSlider(BuildContext context) {
    return SleekCircularSlider(
      min: 5,
      max: 120,
      initialValue: selectedMinutes,
      appearance: CircularSliderAppearance(
        customWidths: CustomSliderWidths(
          trackWidth: 16,
          progressBarWidth: 24,
          shadowWidth: 40,
          handlerSize: 12,
        ),
        customColors: CustomSliderColors(
          trackColor: isDark
              ? AppColors.borderDark.withOpacity(0.5)
              : AppColors.borderLight,
          progressBarColors: [AppColors.primaryLight, AppColors.accent],
          shadowColor: AppColors.primaryLight,
          shadowMaxOpacity: 0.3,
          dotColor: AppColors.textOnPrimary,
        ),
        infoProperties: InfoProperties(
          bottomLabelText: tr('minutes'),
          bottomLabelStyle: TextStyle(
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
          mainLabelStyle: TextStyle(
            fontSize: 64.sp,
            fontWeight: FontWeight.bold,
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
            letterSpacing: -1,
          ),
          modifier: (value) => value.toInt().toString(),
        ),
        size: MediaQuery.of(context).size.width * 0.7,
        startAngle: 270,
        angleRange: 360,
      ),
      onChange: onChanged,
    );
  }
}

class _RecommendationTip extends StatelessWidget {
  final bool isDark;

  const _RecommendationTip({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.surfaceDark.withOpacity(0.5)
            : AppColors.surfaceLight.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.info_outline, size: 16.sp, color: AppColors.info),
          SizedBox(width: 8.w),
          Text(
            'Recommended: 25-45 minutes',
            style: TextStyle(
              fontSize: 12.sp,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

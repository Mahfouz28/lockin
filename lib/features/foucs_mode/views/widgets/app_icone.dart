// lib/features/foucs_mode/views/widgets/components/app_icon.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lockin/core/theme/colors.dart';

class AppIcon extends StatelessWidget {
  final dynamic app;
  final bool isSelected;
  final bool isDark;

  const AppIcon({
    super.key,
    required this.app,
    required this.isSelected,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56.w,
      height: 56.w,
      decoration: _buildDecoration(),
      child: _buildIconContent(),
    );
  }

  BoxDecoration _buildDecoration() {
    return BoxDecoration(
      shape: BoxShape.circle,
      gradient: isSelected
          ? LinearGradient(
              colors: [
                AppColors.primaryLight.withOpacity(0.3),
                AppColors.accent.withOpacity(0.2),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )
          : null,
      color: isSelected
          ? null
          : isDark
          ? AppColors.primaryVariant
          : AppColors.borderLight,
      border: Border.all(
        color: isSelected
            ? AppColors.primaryLight.withOpacity(0.5)
            : Colors.transparent,
        width: 2,
      ),
    );
  }

  Widget _buildIconContent() {
    if (app.icon != null) {
      return ClipOval(child: Image.memory(app.icon!, fit: BoxFit.cover));
    }

    return Icon(
      Icons.apps_rounded,
      color: isSelected
          ? AppColors.primaryLight
          : isDark
          ? AppColors.textSecondaryDark
          : AppColors.textSecondaryLight,
      size: 28.sp,
    );
  }
}

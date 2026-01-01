// lib/features/foucs_mode/views/widgets/components/custom_checkbox.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lockin/core/theme/colors.dart';

class CustomCheckbox extends StatelessWidget {
  final bool isSelected;

  const CustomCheckbox({super.key, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 28.w,
      height: 28.w,
      decoration: _buildDecoration(),
      child: isSelected ? _buildCheckIcon() : null,
    );
  }

  BoxDecoration _buildDecoration() {
    return BoxDecoration(
      shape: BoxShape.circle,
      gradient: isSelected ? AppColors.successGradient : null,
      color: isSelected ? null : Colors.transparent,
      border: Border.all(
        color: isSelected
            ? AppColors.success
            : AppColors.borderDark.withOpacity(0.5),
        width: 2,
      ),
      boxShadow: isSelected
          ? [
              BoxShadow(
                color: AppColors.success.withOpacity(0.4),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ]
          : null,
    );
  }

  Widget _buildCheckIcon() {
    return Icon(
      Icons.check_rounded,
      color: AppColors.textOnPrimary,
      size: 18.sp,
    );
  }
}

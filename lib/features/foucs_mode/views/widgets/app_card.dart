// lib/features/foucs_mode/views/widgets/components/app_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lockin/core/theme/colors.dart';
import 'package:lockin/features/foucs_mode/cubit/focus_mode_cubit.dart';
import 'package:lockin/features/foucs_mode/views/widgets/app_icone.dart';

import 'package:lockin/features/foucs_mode/views/widgets/custom_checbox.dart';

class AppCard extends StatelessWidget {
  final dynamic app;
  final List<dynamic> allApps;
  final bool isDark;

  const AppCard({
    super.key,
    required this.app,
    required this.allApps,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = app.selected;

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 200),
      tween: Tween(begin: 0.0, end: isSelected ? 1.0 : 0.0),
      builder: (context, value, child) {
        return Container(
          margin: EdgeInsets.only(bottom: 12.h),
          decoration: _buildDecoration(isSelected, value),
          child: _buildContent(context, isSelected),
        );
      },
    );
  }

  BoxDecoration _buildDecoration(bool isSelected, double value) {
    return BoxDecoration(
      gradient: isSelected
          ? LinearGradient(
              colors: [
                AppColors.primaryLight.withOpacity(0.15 * value),
                AppColors.accent.withOpacity(0.1 * value),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )
          : null,
      color: isSelected
          ? null
          : isDark
          ? AppColors.surfaceDark
          : AppColors.surfaceLight,
      borderRadius: BorderRadius.circular(16.r),
      border: Border.all(
        color: isSelected
            ? AppColors.primaryLight.withOpacity(0.5 + 0.5 * value)
            : isDark
            ? AppColors.borderDark
            : AppColors.borderLight,
        width: isSelected ? 2 : 1,
      ),
      boxShadow: isSelected
          ? [
              BoxShadow(
                color: AppColors.primaryLight.withOpacity(0.3 * value),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ]
          : [
              BoxShadow(
                color: isDark
                    ? Colors.black26
                    : AppColors.borderLight.withOpacity(0.3),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
    );
  }

  Widget _buildContent(BuildContext context, bool isSelected) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16.r),
        onTap: () => _onTap(context),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            children: [
              AppIcon(app: app, isSelected: isSelected, isDark: isDark),
              SizedBox(width: 16.w),
              _buildAppName(isSelected),
              SizedBox(width: 12.w),
              CustomCheckbox(isSelected: isSelected),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppName(bool isSelected) {
    return Expanded(
      child: Text(
        app.name,
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          color: isDark
              ? AppColors.textPrimaryDark
              : AppColors.textPrimaryLight,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  void _onTap(BuildContext context) {
    final index = allApps.indexOf(app);
    context.read<FocusModeCubit>().toggleAppSelection(index);
  }
}

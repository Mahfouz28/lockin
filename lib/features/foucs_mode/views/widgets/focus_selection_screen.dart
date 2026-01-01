// lib/features/foucs_mode/views/widgets/focus_selection_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lockin/core/theme/colors.dart';
import 'package:lockin/features/foucs_mode/cubit/focus_mode_cubit.dart';
import 'package:lockin/features/foucs_mode/views/widgets/applist.dart';
import 'package:lockin/features/foucs_mode/views/widgets/apps_header.dart';

import 'package:lockin/features/foucs_mode/views/widgets/header_section.dart';
import 'package:lockin/features/foucs_mode/views/widgets/show_more_botton.dart';
import 'package:lockin/features/foucs_mode/views/widgets/start_botton.dart';
import 'package:lockin/features/foucs_mode/views/widgets/timercard.dart';

class FocusSelectionScreen extends StatefulWidget {
  const FocusSelectionScreen({super.key});

  @override
  State<FocusSelectionScreen> createState() => _FocusSelectionScreenState();
}

class _FocusSelectionScreenState extends State<FocusSelectionScreen>
    with SingleTickerProviderStateMixin {
  double _selectedMinutes = 25.0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimation();
  }

  void _initAnimation() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTimerChanged(double value) {
    setState(() => _selectedMinutes = value);
    context.read<FocusModeCubit>().setDuration(value.toInt());
  }

  void _onStartPressed() {
    context.read<FocusModeCubit>().startFocusMode();
  }

  void _onShowMorePressed() {
    context.read<FocusModeCubit>().toggleExpand();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocBuilder<FocusModeCubit, FocusModeState>(
      builder: (context, state) {
        if (state is! FocusModeLoaded) {
          return _buildLoadingState(isDark);
        }

        return _buildLoadedState(context, state, isDark);
      },
    );
  }

  Widget _buildLoadingState(bool isDark) {
    return Center(
      child: CircularProgressIndicator(
        color: isDark ? AppColors.primaryLight : AppColors.primary,
      ),
    );
  }

  Widget _buildLoadedState(
    BuildContext context,
    FocusModeLoaded state,
    bool isDark,
  ) {
    final apps = state.installedApps;
    final selectedCount = apps.where((app) => app.selected).length;
    final displayedApps = state.isExpanded ? apps : apps.take(8).toList();

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HeaderSection(isDark: isDark),
            SizedBox(height: 32.h),
            TimerCard(
              isDark: isDark,
              selectedMinutes: _selectedMinutes,
              onChanged: _onTimerChanged,
            ),
            SizedBox(height: 40.h),
            AppsHeader(isDark: isDark, selectedCount: selectedCount),
            SizedBox(height: 16.h),
            AppsList(
              displayedApps: displayedApps,
              allApps: apps,
              isDark: isDark,
            ),
            if (apps.length > 8 && !state.isExpanded)
              ShowMoreButton(onPressed: _onShowMorePressed),
            SizedBox(height: 32.h),
            StartButton(
              state: state,
              selectedCount: selectedCount,
              onPressed: _onStartPressed,
            ),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }
}

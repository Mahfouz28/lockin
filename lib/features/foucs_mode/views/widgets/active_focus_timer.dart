// lib/features/focus_mode/views/widgets/active_focus_timer.dart
// (تأكد إن المجلد focus_mode مش foucs_mode)

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lockin/core/routes/routes.dart';
import 'package:lockin/core/theme/colors.dart';

import 'package:lockin/features/foucs_mode/cubit/focus_mode_cubit.dart';
import 'package:lockin/features/foucs_mode/views/widgets/motiv_text.dart';
import 'package:lockin/features/foucs_mode/views/widgets/stop_confirmation_dialog.dart';
import 'package:lockin/features/foucs_mode/views/widgets/stop_foucs_botton.dart';
import 'package:lockin/features/foucs_mode/views/widgets/timer_criclur.dart';

class ActiveFocusTimer extends StatelessWidget {
  const ActiveFocusTimer({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FocusModeCubit, FocusModeState>(
      listener: (context, state) {
        // لما الجلسة تتوقف أو تنتهي → نرجع لشاشة اختيار التطبيقات
        if (state is FocusModeStopped || state is FocusModeLoaded) {
          if (ModalRoute.of(context)?.isCurrent == true) {
            Navigator.pushReplacementNamed(context, Routes.home);
          }
        }
      },
      builder: (context, state) {
        if (state is! FocusModeActive) {
          return _buildNonActiveState();
        }

        // الحل النهائي: نستخدم BlocSelector عشان نحدث الـ Timer فقط
        return BlocSelector<
          FocusModeCubit,
          FocusModeState,
          ({int minutes, int seconds})
        >(
          selector: (state) {
            if (state is FocusModeActive) {
              return (
                minutes: state.remainingMinutes,
                seconds: state.remainingSeconds,
              );
            }
            return (minutes: 0, seconds: 0);
          },
          builder: (context, time) {
            return _buildActiveState(context, time);
          },
        );
      },
    );
  }

  Widget _buildNonActiveState() {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.darkGradient),
      child: const Center(
        child: CircularProgressIndicator(
          color: AppColors.primaryLight,
          strokeWidth: 6,
        ),
      ),
    );
  }

  Widget _buildActiveState(
    BuildContext context,
    ({int minutes, int seconds}) time,
  ) {
    void onStopPressed() {
      showStopConfirmationDialog(
        context,
        onConfirm: () {
          context.read<FocusModeCubit>().stopFocusMode();
        },
      );
    }

    return Container(
      decoration: const BoxDecoration(gradient: AppColors.darkGradient),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(height: 40.h),
            const MotivationText(), // ده ثابت → مش بيتغيرش كل ثانية
            SizedBox(height: 20.h),
            TimerCircularSlider(),
            SizedBox(height: 60.h),
            StopFocusButton(onPressed: onStopPressed),
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }
}

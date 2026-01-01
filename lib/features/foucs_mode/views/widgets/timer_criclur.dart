// lib/features/foucs_mode/views/widgets/components/timer_circular_slider.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import 'package:lockin/core/theme/colors.dart';
import 'package:lockin/features/foucs_mode/cubit/focus_mode_cubit.dart';

class TimerCircularSlider extends StatelessWidget {
  const TimerCircularSlider({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FocusModeCubit, FocusModeState>(
      builder: (context, state) {
        // إذا مش في وضع التركيز النشط → مخفي
        if (state is! FocusModeActive) {
          return const SizedBox.shrink();
        }

        final cubit = context.read<FocusModeCubit>();

        // المدة الكلية (اللي اختارها المستخدم)
        final int totalMinutes =
            cubit.selectedDuration ?? (state.remainingMinutes + 1);

        // حساب النسبة المئوية للتقدم (كم باقي من الوقت)
        final double progressValue = _calculateProgress(
          totalMinutes: totalMinutes,
          remainingMinutes: state.remainingMinutes,
          remainingSeconds: state.remainingSeconds,
        );

        // تنسيق الوقت كـ 04:32
        final String timeDisplay = _formatTimeDisplay(
          state.remainingMinutes,
          state.remainingSeconds,
        );

        return SleekCircularSlider(
          min: 0,
          max: 100,
          initialValue: progressValue,
          appearance: _buildAppearance(context, timeDisplay),
        );
      },
    );
  }

  /// حساب النسبة المئوية المتبقية (من 100% في البداية إلى 0% في النهاية)
  double _calculateProgress({
    required int totalMinutes,
    required int remainingMinutes,
    required int remainingSeconds,
  }) {
    if (totalMinutes <= 0) return 0.0;

    final int totalSeconds = totalMinutes * 60;
    final int remainingTotalSeconds = remainingMinutes * 60 + remainingSeconds;

    final double progress = (remainingTotalSeconds / totalSeconds) * 100;
    return progress.clamp(0.0, 100.0);
  }

  /// تنسيق الوقت → 05:47
  String _formatTimeDisplay(int minutes, int seconds) {
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  CircularSliderAppearance _buildAppearance(
    BuildContext context,
    String timeDisplay,
  ) {
    return CircularSliderAppearance(
      customWidths: CustomSliderWidths(
        trackWidth: 18,
        progressBarWidth: 26,
        shadowWidth: 60,
        handlerSize: 0, // بدون مؤشر يدوي
      ),
      customColors: CustomSliderColors(
        trackColor: AppColors.textOnPrimary.withOpacity(0.08),
        progressBarColors: const [
          AppColors.primaryLight,
          AppColors.accent,
          AppColors.secondary,
        ],
        shadowColor: AppColors.primaryLight,
        shadowMaxOpacity: 0.4,
      ),
      infoProperties: InfoProperties(
        mainLabelStyle: const TextStyle(
          fontSize: 82,
          fontWeight: FontWeight.w300,
          color: AppColors.textPrimaryDark,
          letterSpacing: 4,
        ),
        modifier: (_) => timeDisplay,
      ),
      size: MediaQuery.of(context).size.width * 0.85,
      startAngle: 270,
      angleRange: 360,
      animationEnabled: true,
    );
  }
}

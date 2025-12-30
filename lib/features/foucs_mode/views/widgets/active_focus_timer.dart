// features/foucs_mode/views/widgets/active_focus_timer.dart

import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lockin/core/theme/colors.dart';
import '../../cubit/focus_mode_cubit.dart';
import 'stop_confirmation_dialog.dart';

class ActiveFocusTimer extends StatelessWidget {
  const ActiveFocusTimer({super.key});

  @override
  Widget build(BuildContext context) {
    // استخدم BlocBuilder عشان تتعامل مع الـ state بشكل آمن
    return BlocBuilder<FocusModeCubit, FocusModeState>(
      builder: (context, state) {
        // لو الـ state مش Active → نعرض loading أو نرجع empty (مش هيحصل عاديًا)
        if (state is! FocusModeActive) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }

        final activeState = state; // آمن الآن

        final int totalSeconds = activeState.remainingMinutes * 60;

        return Container(
          decoration: const BoxDecoration(gradient: AppColors.darkGradient),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Hero(
                  tag: 'focus_timer_hero',
                  child: CircularCountDownTimer(
                    duration: totalSeconds,
                    initialDuration: 0,
                    controller: CountDownController(),
                    width: MediaQuery.of(context).size.width * 0.8,
                    height: MediaQuery.of(context).size.width * 0.8,
                    ringColor: Colors.white.withOpacity(0.15),
                    fillColor: Colors.transparent,
                    fillGradient: AppColors.accentGradient,
                    backgroundColor: Colors.transparent,
                    strokeWidth: 22.0,
                    strokeCap: StrokeCap.round,
                    textStyle: const TextStyle(
                      fontSize: 72,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          blurRadius: 10,
                          color: Colors.black26,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    textFormat: CountdownTextFormat.MM_SS,
                    isReverse: true,
                    isReverseAnimation: true,
                    autoStart: true,
                  ),
                ),

                const SizedBox(height: 48),
                const Text(
                  'Stay Focused!',
                  style: TextStyle(
                    fontSize: 30,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Deep work in progress',
                  style: TextStyle(fontSize: 18, color: Colors.white70),
                ),
                const SizedBox(height: 100),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 48),
                  child: SizedBox(
                    width: double.infinity,
                    height: 64,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.primary,
                        elevation: 16,
                        shadowColor: Colors.black45,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32),
                        ),
                      ),
                      onPressed: () => showStopConfirmationDialog(
                        context,
                        onConfirm: () {
                          context.read<FocusModeCubit>().stopFocusMode();
                          Navigator.pop(context); // Close the dialog
                        },
                      ),
                      child: Text(
                        'Stop Focus Mode',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// lib/features/focus_mode/views/focus_mode_screen.dart
// (المجلد الصحيح: focus_mode وليس foucs_mode)

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lockin/core/di/injection_container.dart' show sl;
import 'package:lockin/core/theme/colors.dart';
import 'package:lockin/features/foucs_mode/cubit/focus_mode_cubit.dart';
import 'package:lockin/features/foucs_mode/views/widgets/active_focus_timer.dart';
import 'package:lockin/features/foucs_mode/views/widgets/focus_selection_screen.dart';

class FocusModeScreen extends StatelessWidget {
  const FocusModeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<FocusModeCubit>(
      create: (_) => sl<FocusModeCubit>()
        ..checkActiveFocusMode() // يتحقق أولاً إذا كان فيه جلسة نشطة
        ..loadApps(), // يحمل التطبيقات في كل الأحوال
      child: Scaffold(
        appBar: AppBar(
          title: Text('focus_mode.title'.tr()), // "Focus Mode"
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          leading: BlocBuilder<FocusModeCubit, FocusModeState>(
            builder: (context, state) {
              // إخفاء زر الرجوع أثناء الـ Focus Mode النشط
              if (state is FocusModeActive) return const SizedBox.shrink();
              return const BackButton(color: Colors.white);
            },
          ),
        ),
        body: BlocConsumer<FocusModeCubit, FocusModeState>(
          listener: (context, state) {
            // رسائل الـ SnackBar
            if (state is FocusModeError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.redAccent,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }

            if (state is FocusModeStarted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('focus_mode.focus_started_message'.tr()),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 3),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }

            if (state is FocusModeStopped) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('focus_mode.focus_stopped_message'.tr()),
                  backgroundColor: Colors.blue,
                  duration: const Duration(seconds: 3),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          builder: (context, state) {
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 900),
              reverseDuration: const Duration(milliseconds: 700),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (Widget child, Animation<double> animation) {
                final bool isTimer =
                    child.key == const ValueKey('active_timer');

                final Tween<Offset> offsetTween = Tween<Offset>(
                  begin: isTimer
                      ? const Offset(0.0, 0.6)
                      : const Offset(0.0, -0.4),
                  end: Offset.zero,
                );

                final Animation<Offset> slideAnimation = offsetTween
                    .chain(CurveTween(curve: Curves.easeOutCubic))
                    .animate(animation);

                return ClipRect(
                  child: FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: slideAnimation,
                      child: ScaleTransition(
                        scale: Tween<double>(begin: 0.92, end: 1.0).animate(
                          CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeOutBack,
                          ),
                        ),
                        child: child,
                      ),
                    ),
                  ),
                );
              },
              child: _buildBody(context, state),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, FocusModeState state) {
    // إذا كان Focus Mode نشط → نعرض الـ Timer
    if (state is FocusModeActive) {
      return const ActiveFocusTimer(key: ValueKey('active_timer'));
    }

    // إذا كان في حالة تحميل (أول مرة أو بعد إيقاف)
    if (state is FocusModeLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: AppColors.primaryLight),
            const SizedBox(height: 24),
          ],
        ),
      );
    }

    // إذا كان في خطأ → نعرض رسالة خطأ مع إمكانية المحاولة مرة أخرى
    if (state is FocusModeError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 80, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                state.message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.read<FocusModeCubit>().loadApps(),
                child: Text('retry'.tr()),
              ),
            ],
          ),
        ),
      );
    }

    // الحالة الطبيعية: FocusModeLoaded أو FocusModeStopped أو أي حالة أخرى
    // → نعرض شاشة اختيار التطبيقات والمدة
    return const FocusSelectionScreen(key: ValueKey('selection_screen'));
  }
}

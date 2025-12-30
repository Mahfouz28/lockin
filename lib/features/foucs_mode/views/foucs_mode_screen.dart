// features/foucs_mode/views/focus_mode_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lockin/core/services/shared_prefs_service.dart';
import 'package:lockin/features/foucs_mode/cubit/focus_mode_cubit.dart';
import 'package:lockin/features/foucs_mode/services/installed_apps_service.dart';
import 'package:lockin/core/theme/colors.dart';
import 'package:lockin/features/foucs_mode/views/widgets/active_focus_timer.dart';
import 'package:lockin/features/foucs_mode/views/widgets/focus_selection_screen.dart';

class FocusModeScreen extends StatelessWidget {
  final SharedPrefsService prefsService;
  final InstalledAppsService installedAppsService;

  const FocusModeScreen({
    super.key,
    required this.prefsService,
    required this.installedAppsService,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<FocusModeCubit>(
      create: (_) =>
          FocusModeCubit(prefsService, installedAppsService)
            ..checkActiveFocusMode(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Focus Mode'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          leading: BlocBuilder<FocusModeCubit, FocusModeState>(
            builder: (context, state) {
              if (state is FocusModeActive) return const SizedBox.shrink();
              return const BackButton(color: Colors.white);
            },
          ),
        ),
        body: BlocConsumer<FocusModeCubit, FocusModeState>(
          listener: (context, state) {
            if (state is FocusModeError) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            }
            if (state is FocusModeStarted || state is FocusModeStopped) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    state is FocusModeStarted
                        ? "Focus Mode Started!"
                        : "Focus Mode Stopped!",
                  ),
                ),
              );
              Navigator.pop(context);
            }
          },
          builder: (context, state) {
            if (state is FocusModeActive) {
              return const ActiveFocusTimer();
            }
            if (state is FocusModeLoaded) {
              return const FocusSelectionScreen();
            }
            // Loading or Initial
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          },
        ),
      ),
    );
  }
}

// features/foucs_mode/views/widgets/focus_selection_screen.dart

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import 'package:lockin/core/theme/colors.dart';
import 'package:lockin/features/foucs_mode/cubit/focus_mode_cubit.dart';
import 'package:lockin/features/foucs_mode/models/installed_app_model.dart.dart';
import 'active_focus_timer.dart'; // ← مهم للـ Hero

class FocusSelectionScreen extends StatefulWidget {
  const FocusSelectionScreen({super.key});

  @override
  State<FocusSelectionScreen> createState() => _FocusSelectionScreenState();
}

class _FocusSelectionScreenState extends State<FocusSelectionScreen> {
  double _selectedMinutes = 30.0; // القيمة الافتراضية

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FocusModeCubit, FocusModeState>(
      builder: (context, state) {
        if (state is! FocusModeLoaded) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }

        final loadedState = state;
        final apps = List<InstalledAppModel>.from(loadedState.installedApps);
        final displayedApps = loadedState.isExpanded
            ? apps
            : apps.take(5).toList();

        return Container(
          color: AppColors.backgroundDark,
          child: Column(
            children: [
              // Sleek Circular Slider مع Hero Animation
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Hero(
                  tag: 'focus_timer_hero', // نفس الـ tag في الـ Timer screen
                  child: SleekCircularSlider(
                    min: 5,
                    max: 120,
                    initialValue: _selectedMinutes,
                    appearance: CircularSliderAppearance(
                      customWidths: CustomSliderWidths(
                        trackWidth: 20,
                        progressBarWidth: 28,
                        shadowWidth: 40,
                        handlerSize: 16,
                      ),
                      customColors: CustomSliderColors(
                        trackColor: Colors.white.withOpacity(0.1),
                        progressBarColor: AppColors.primaryLight,
                        shadowColor: AppColors.primaryLight,
                        shadowMaxOpacity: 0.2,
                        dotColor: AppColors.primaryLight,
                      ),
                      infoProperties: InfoProperties(
                        mainLabelStyle: TextStyle(
                          fontSize: 72,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        modifier: (double value) {
                          final minutes = value.toInt();
                          return '$minutes\nدقيقة';
                        },
                      ),
                      size: 280,
                      angleRange: 360,
                      startAngle: 270,
                      spinnerMode: false,
                    ),
                    onChange: (double value) {
                      setState(() {
                        _selectedMinutes = value;
                      });
                      context.read<FocusModeCubit>().setDuration(value.toInt());
                    },
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Apps List
              Expanded(
                child: ListView.builder(
                  itemCount:
                      displayedApps.length +
                      (loadedState.isExpanded || apps.length <= 5 ? 0 : 1),
                  itemBuilder: (context, index) {
                    if (!loadedState.isExpanded &&
                        index == 5 &&
                        apps.length > 5) {
                      return Center(
                        child: TextButton(
                          onPressed: () =>
                              context.read<FocusModeCubit>().toggleExpand(),
                          child: Text(
                            'Show More Apps',
                            style: TextStyle(color: AppColors.secondaryLight),
                          ),
                        ),
                      );
                    }

                    final int appIndex = !loadedState.isExpanded && index > 4
                        ? index - 1
                        : index;
                    final app = apps[appIndex];

                    return ListTile(
                      leading: app.icon != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.memory(
                                Uint8List.fromList(app.icon!),
                                width: 48,
                                height: 48,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Icon(
                              Icons.apps,
                              color: AppColors.secondary,
                              size: 48,
                            ),
                      title: Text(
                        app.name,
                        style: TextStyle(
                          color: AppColors.textPrimaryDark,
                          fontSize: 16,
                        ),
                      ),
                      trailing: Checkbox(
                        value: app.selected,
                        activeColor: AppColors.secondary,
                        checkColor: Colors.white,
                        onChanged: (_) => context
                            .read<FocusModeCubit>()
                            .toggleAppSelection(appIndex),
                      ),
                    );
                  },
                ),
              ),

              // Start Button مع Hero Transition
              Padding(
                padding: const EdgeInsets.all(20),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedMinutes < 5
                        ? Colors.grey.shade700
                        : AppColors.secondary,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 12,
                  ),
                  onPressed: _selectedMinutes < 5
                      ? null
                      : () async {
                          await context.read<FocusModeCubit>().startFocusMode();
                          if (context.mounted && state is FocusModeActive) {
                            // انتقال بـ Hero + Fade Animation إلى شاشة الـ Timer
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                transitionDuration: const Duration(
                                  milliseconds: 1000,
                                ),
                                pageBuilder: (_, __, ___) =>
                                    const ActiveFocusTimer(),
                                transitionsBuilder: (_, animation, __, child) {
                                  return FadeTransition(
                                    opacity: animation,
                                    child: ScaleTransition(
                                      scale: Tween<double>(begin: 0.8, end: 1.0)
                                          .animate(
                                            CurvedAnimation(
                                              parent: animation,
                                              curve: Curves.easeOutBack,
                                            ),
                                          ),
                                      child: child,
                                    ),
                                  );
                                },
                              ),
                            );
                          }
                        },
                  child: Text(
                    'Start Focus Mode',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

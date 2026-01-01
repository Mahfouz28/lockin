// lib/features/home/views/home_screen.dart

import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lockin/core/routes/routes.dart';
import 'package:lockin/core/widgets/custom_button.dart';

import 'package:lockin/features/foucs_mode/cubit/focus_mode_cubit.dart';
import 'package:lockin/features/foucs_mode/views/widgets/active_focus_timer.dart';
import 'package:lockin/features/home/cubit/home_cubit.dart';
import 'package:lottie/lottie.dart';

import 'widgets/focus_card.dart';
import 'widgets/home_app_bar.dart';
import 'widgets/welcome_section.dart';
import 'widgets/usage_period_tabs.dart';
import 'widgets/usage_pie_chart.dart';
import 'widgets/top_apps_list.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return ThemeSwitchingArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: const HomeAppBar(),
        body: SafeArea(
          child: BlocListener<FocusModeCubit, FocusModeState>(
            listener: (context, focusState) {
              if (focusState is FocusModeActive) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ActiveFocusTimer(),
                    ),
                  );
                });
              }
            },
            child: BlocBuilder<HomeCubit, HomeState>(
              builder: (context, state) {
                if (state.error != null) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 32.w),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 80.sp,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          SizedBox(height: 24.h),
                          Text(
                            state.error!,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          SizedBox(height: 32.h),
                          CustomButton(
                            text: 'retry'.tr(),
                            onPressed: () =>
                                context.read<HomeCubit>().loadUsageData(),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 100.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const WelcomeSection(),
                      SizedBox(height: 24.h),
                      const FocusCard(),
                      SizedBox(height: 40.h),

                      // Tabs للفترة
                      state.isLoading
                          ? const SizedBox.shrink()
                          : UsagePeriodTabs(
                              currentPeriod: state.period,
                              onPeriodChanged: (period) {
                                context.read<HomeCubit>().changePeriod(period);
                              },
                            ),

                      SizedBox(height: 30.h),

                      // الـ Pie Chart مع Loading جميل
                      Builder(
                        builder: (_) {
                          final bool isChartEmpty =
                              state.apps.isEmpty || state.totalMinutes == 0;

                          if (state.isLoading || isChartEmpty) {
                            return SizedBox(
                              height: 240.h,
                              child: Center(
                                child: Lottie.asset(
                                  "assets/lotti/Loading animation blue.json",
                                  width: 180.w,
                                ),
                              ),
                            );
                          }

                          return UsagePieChart(
                            apps: state.apps,
                            totalMinutes: state.totalMinutes,
                          );
                        },
                      ),

                      SizedBox(height: 40.h),

                      CustomButton(
                        text: "seeMoreFacts".tr(),
                        onPressed: () {
                          final cubit = context.read<HomeCubit>();
                          Navigator.pushNamed(
                            context,
                            Routes.facts,
                            arguments: {
                              'period': cubit.state.period,
                              'minutesPerDay': cubit.state.dailyAverage,
                            },
                          );
                        },
                      ),

                      SizedBox(height: 32.h),

                      Divider(
                        thickness: 2,
                        color: Theme.of(context).dividerColor.withOpacity(0.5),
                      ),

                      SizedBox(height: 24.h),

                      // زر Focus Mode
                      CustomButton(
                        text: tr('focus_mode.title'),
                        onPressed: () {
                          Navigator.pushNamed(context, Routes.focusMode);
                        },
                      ),

                      SizedBox(height: 32.h),

                      if (!state.isLoading && state.apps.isNotEmpty)
                        TopAppsList(apps: state.apps),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

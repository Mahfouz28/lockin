import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lockin/core/routes/routes.dart';
import 'package:lockin/core/services/shared_prefs_service.dart';
import 'package:lockin/core/widgets/custom_button.dart';

import 'package:lockin/features/foucs_mode/cubit/focus_mode_cubit.dart';
import 'package:lockin/features/foucs_mode/services/installed_apps_service.dart';
import 'package:lockin/features/foucs_mode/views/foucs_mode_screen.dart';
import 'package:lockin/features/home/cubit/home_cubit.dart';
import 'package:lockin/features/home/views/widgets/top_apps_list.dart';
import 'package:lottie/lottie.dart';

import 'widgets/focus_card.dart';
import 'widgets/home_app_bar.dart';
import 'widgets/welcome_section.dart';
import 'widgets/usage_period_tabs.dart';
import 'widgets/usage_pie_chart.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => HomeCubit()..loadUsageData()),
        BlocProvider(
          create: (_) =>
              FocusModeCubit(SharedPrefsService(), InstalledAppsService())
                ..checkActiveFocusMode(),
        ),
      ],
      child: ThemeSwitchingArea(
        child: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: const HomeAppBar(),
          body: SafeArea(
            child: Stack(
              children: [
                // المحتوى الرئيسي
                BlocBuilder<HomeCubit, HomeState>(
                  builder: (context, state) {
                    if (state.error != null) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 80.sp,
                              color: Theme.of(context).colorScheme.error,
                            ),
                            SizedBox(height: 20.h),
                            Text(
                              state.error!,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            SizedBox(height: 20.h),
                            ElevatedButton(
                              onPressed: () =>
                                  context.read<HomeCubit>().loadUsageData(),
                              child: Text('retry'.tr()),
                            ),
                          ],
                        ),
                      );
                    }

                    return SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 20.h,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const WelcomeSection(),
                          const FocusCard(),
                          SizedBox(height: 40.h),

                          state.isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : UsagePeriodTabs(
                                  currentPeriod: state.period,
                                  onPeriodChanged: (period) {
                                    context.read<HomeCubit>().changePeriod(
                                      period,
                                    );
                                  },
                                ),

                          SizedBox(height: 30.h),

                          Builder(
                            builder: (_) {
                              final bool isChartLoading =
                                  state.isLoading ||
                                  state.apps.isEmpty ||
                                  state.totalMinutes == 0;

                              if (isChartLoading) {
                                return SizedBox(
                                  height: 220.h,
                                  child: Center(
                                    child: LottieBuilder.asset(
                                      "assets/lotti/Loading animation blue.json",
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
                              Navigator.pushNamed(
                                context,
                                Routes.facts,
                                arguments: context
                                    .read<HomeCubit>()
                                    .state
                                    .period,
                              );
                            },
                          ),

                          SizedBox(height: 20.h),

                          Divider(
                            color: Theme.of(context).dividerColor,
                            thickness: 2,
                          ),

                          SizedBox(height: 10.h),

                          CustomButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder:
                                      (
                                        context,
                                        animation,
                                        secondaryAnimation,
                                      ) => FocusModeScreen(
                                        prefsService: SharedPrefsService(),
                                        installedAppsService:
                                            InstalledAppsService(),
                                      ),
                                  transitionsBuilder:
                                      (
                                        context,
                                        animation,
                                        secondaryAnimation,
                                        child,
                                      ) {
                                        const begin = Offset(1.0, 0.0);
                                        const end = Offset.zero;
                                        const curve = Curves.easeInOut;

                                        final tween = Tween(
                                          begin: begin,
                                          end: end,
                                        ).chain(CurveTween(curve: curve));

                                        return SlideTransition(
                                          position: animation.drive(tween),
                                          child: child,
                                        );
                                      },
                                  transitionDuration: const Duration(
                                    milliseconds: 300,
                                  ),
                                ),
                              );
                            },
                            text: "focus mode".tr(),
                          ),

                          TopAppsList(apps: state.apps),
                        ],
                      ),
                    );
                  },
                ),

                // شريط الـ Timer العلوي (Focus Mode Indicator)
                BlocBuilder<FocusModeCubit, FocusModeState>(
                  builder: (context, focusState) {
                    if (focusState is FocusModeActive) {
                      return Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: Material(
                          elevation: 8,
                          child: Container(
                            color: Colors.red.shade600,
                            padding: EdgeInsets.only(
                              left: 16.w,
                              right: 16.w,
                              top: MediaQuery.of(context).padding.top + 12.h,
                              bottom: 12.h,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.lock_clock,
                                      color: Colors.white,
                                      size: 24.sp,
                                    ),
                                    SizedBox(width: 12.w),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Focus Mode Active',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          '${focusState.remainingMinutes} minutes remaining',
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(
                                              0.9,
                                            ),
                                            fontSize: 14.sp,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                  onPressed: () {
                                    context
                                        .read<FocusModeCubit>()
                                        .stopFocusMode();
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

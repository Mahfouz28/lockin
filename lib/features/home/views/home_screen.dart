import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lockin/core/routes/routes.dart';

import 'package:lockin/core/widgets/custom_button.dart';
import 'package:lockin/features/home/cubit/home_cubit.dart';
import 'package:lockin/features/home/views/widgets/top_apps_list.dart';
import 'package:lottie/lottie.dart';

import 'widgets/focus_card.dart';
import 'widgets/home_app_bar.dart';
import 'widgets/welcome_section.dart';
import 'widgets/usage_period_tabs.dart';
import 'widgets/usage_pie_chart.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomeCubit(),
      child: ThemeSwitchingArea(
        child: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: const HomeAppBar(),
          body: SafeArea(
            child: BlocBuilder<HomeCubit, HomeState>(
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
                                context.read<HomeCubit>().changePeriod(period);
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
                        text: "See more Facts",
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            Routes.facts,
                            arguments: context.read<HomeCubit>().state.period,
                          );
                        },
                      ),

                      SizedBox(height: 20.h),

                      Divider(
                        color: Theme.of(context).dividerColor,
                        thickness: 2,
                      ),

                      SizedBox(height: 10.h),

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

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:lockin/core/widgets/custom_button.dart';
import 'package:lockin/features/facts/models/facts_model.dart';
import 'package:lockin/features/facts/view_models/fact_viewmodel.dart';
import 'package:lockin/features/home/cubit/home_cubit.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'reduce_screen_time_tips_screen.dart';

class FactsScreen extends StatelessWidget {
  final UsagePeriod? period;
  final int? minutesPerDay;

  const FactsScreen({
    super.key,
    required this.period,
    required this.minutesPerDay,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          FactsViewModel(period: period!, minutesPerDay: minutesPerDay!),
      child: Consumer<FactsViewModel>(
        builder: (context, vm, _) => Scaffold(
          appBar: AppBar(title: Text('facts_screen.app_bar_title'.tr())),
          body: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: vm.showAllFacts ? null : vm.next,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 700),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              child: vm.showAllFacts
                  ? _AllFactsView(
                      key: const ValueKey('all'),
                      facts: vm.facts,
                      onContinue: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ReduceScreenTimeTipsScreen(
                              isPositive: vm.factsData.isPositive,
                            ),
                          ),
                        );
                      },
                    )
                  : _SingleFactView(
                      key: ValueKey(vm.currentIndex),
                      period: vm.period,
                      fact: vm.facts[vm.currentIndex],
                      index: vm.currentIndex,
                      total: vm.facts.length,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

/* ─────────────────────────────── */
/* SINGLE FACT VIEW */
/* ─────────────────────────────── */

class _SingleFactView extends StatelessWidget {
  final UsagePeriod period;
  final FactItem fact;
  final int index;
  final int total;

  const _SingleFactView({
    super.key,
    required this.period,
    required this.fact,
    required this.index,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _headerTitle(period),
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 40.h),
            Icon(
              fact.icon,
              size: 64.sp,
              color: fact.isWarning
                  ? Theme.of(context).colorScheme.error
                  : Theme.of(context).colorScheme.primary,
            ),
            SizedBox(height: 24.h),
            Text(
              fact.text,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontSize: 21.sp, height: 1.7),
            ),
            SizedBox(height: 48.h),
            Text(
              'facts_screen.tap_to_continue'.tr(
                namedArgs: {'current': '${index + 1}', 'total': '$total'},
              ),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(
                  context,
                ).textTheme.bodySmall?.color?.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _headerTitle(UsagePeriod period) {
    switch (period) {
      case UsagePeriod.today:
        return 'facts_screen.header_titles.pause_moment'.tr();
      case UsagePeriod.weekly:
        return 'facts_screen.header_titles.think_about'.tr();
      case UsagePeriod.monthly:
        return 'facts_screen.header_titles.monthly_reality'.tr();
    }
  }
}

/* ─────────────────────────────── */
/* ALL FACTS VIEW */
/* ─────────────────────────────── */

class _AllFactsView extends StatelessWidget {
  final List<FactItem> facts;
  final VoidCallback onContinue;

  const _AllFactsView({
    super.key,
    required this.facts,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'facts_screen.now_take_it_in'.tr(),
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          SizedBox(height: 32.h),
          ...facts.map(
            (fact) => Padding(
              padding: EdgeInsets.only(bottom: 24.h),
              child: _FactCard(fact: fact),
            ),
          ),
          SizedBox(height: 24.h),
          CustomButton(
            text: 'facts_screen.how_can_improve'.tr(),
            onPressed: onContinue,
          ),
        ],
      ),
    );
  }
}

class _FactCard extends StatelessWidget {
  final FactItem fact;

  const _FactCard({required this.fact});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: fact.isWarning
          ? Theme.of(context).colorScheme.error.withOpacity(0.08)
          : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(fact.icon, size: 32.sp),
            SizedBox(width: 16.w),
            Expanded(
              child: Text(
                fact.text,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(height: 1.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

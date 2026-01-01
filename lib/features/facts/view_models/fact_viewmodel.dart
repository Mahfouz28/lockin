import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:lockin/features/facts/models/facts_model.dart';
import 'package:lockin/features/home/cubit/home_cubit.dart';

class FactsViewModel extends ChangeNotifier {
  final UsagePeriod period;
  final int minutesPerDay;

  int _currentIndex = 0;
  bool _showAllFacts = false;

  late final FactsData factsData;
  late final List<FactItem> facts;
  late final Map<String, String> stats;

  FactsViewModel({required this.period, required this.minutesPerDay}) {
    stats = FactsCalculator.generateStats(minutesPerDay);
    factsData = _generateFacts();
    facts = factsData.facts;
  }

  int get currentIndex => _currentIndex;
  bool get showAllFacts => _showAllFacts;

  void next() {
    if (_currentIndex < facts.length - 1) {
      _currentIndex++;
      notifyListeners();
    } else {
      _showAllFacts = true;
      notifyListeners();
    }
  }

  FactsData _generateFacts() {
    final isHealthy = FactsCalculator.isHealthyUsage(minutesPerDay);

    List<FactItem> factsList = isHealthy
        ? _generatePositiveFacts()
        : _generateWarningFacts();

    return FactsData(facts: factsList, isPositive: isHealthy);
  }

  List<FactItem> _generatePositiveFacts() {
    final periodKey = _getPeriodKey();

    return [
      FactItem(
        icon: Icons.celebration,
        text: tr('facts_positive.$periodKey.great_job', namedArgs: stats),
        isWarning: false,
      ),
      FactItem(
        icon: Icons.psychology,
        text: tr('facts_positive.$periodKey.mental_health'),
        isWarning: false,
      ),
      FactItem(
        icon: Icons.fitness_center,
        text: tr('facts_positive.$periodKey.physical_activity'),
        isWarning: false,
      ),
      FactItem(
        icon: Icons.auto_awesome,
        text: tr('facts_positive.$periodKey.productivity'),
        isWarning: false,
      ),
      FactItem(
        icon: Icons.recommend,
        text: tr('facts_positive.$periodKey.keep_it_up'),
        isWarning: false,
      ),
    ];
  }

  List<FactItem> _generateWarningFacts() {
    final periodKey = _getPeriodKey();

    return [
      FactItem(
        icon: Icons.warning_amber_rounded,
        text: tr('facts_warning.$periodKey.exceeded', namedArgs: stats),
        isWarning: true,
      ),
      FactItem(
        icon: Icons.visibility_off,
        text: tr('facts_warning.$periodKey.eye_strain'),
        isWarning: true,
      ),
      FactItem(
        icon: Icons.bedtime,
        text: tr('facts_warning.$periodKey.sleep_quality'),
        isWarning: true,
      ),
      FactItem(
        icon: Icons.trending_down,
        text: tr('facts_warning.$periodKey.productivity_loss'),
        isWarning: true,
      ),
      FactItem(
        icon: Icons.psychology_outlined,
        text: tr('facts_warning.$periodKey.mental_health'),
        isWarning: true,
      ),
      // Add life impact fact for warning cases
      if (minutesPerDay > 180) // More than 3 hours
        FactItem(
          icon: Icons.hourglass_empty,
          text: tr('facts_warning.$periodKey.life_impact', namedArgs: stats),
          isWarning: true,
        ),
      FactItem(
        icon: Icons.lightbulb_outline,
        text: tr('facts_warning.$periodKey.take_action'),
        isWarning: false,
      ),
    ];
  }

  String _getPeriodKey() {
    switch (period) {
      case UsagePeriod.today:
        return 'today';
      case UsagePeriod.weekly:
        return 'weekly';
      case UsagePeriod.monthly:
        return 'monthly';
    }
  }
}

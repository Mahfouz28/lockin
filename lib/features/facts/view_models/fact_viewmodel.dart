import 'package:flutter/material.dart';
import 'package:lockin/features/facts/models/facts_model.dart';
import 'package:lockin/features/home/cubit/home_cubit.dart';

class FactsViewModel extends ChangeNotifier {
  final UsagePeriod period;
  late final FactsData factsData;
  late final List<FactItem> facts;

  int currentIndex = 0;
  bool showAllFacts = false;

  FactsViewModel({required this.period, required int minutesPerDay}) {
    factsData = FactsCalculator.calculateMonthly(minutesPerDay: minutesPerDay);

    facts = [
      FactItem(icon: Icons.timer_off_rounded, text: factsData.timeReality),
      FactItem(
        icon: Icons.favorite_border_rounded,
        text: factsData.healthReality,
      ),
      FactItem(
        icon: factsData.isPositive
            ? Icons.check_circle_outline
            : Icons.warning_amber_rounded,
        text: factsData.lifeWarning,
        isWarning: !factsData.isPositive,
      ),
    ];
  }

  void next() {
    if (currentIndex < facts.length - 1) {
      currentIndex++;
    } else {
      showAllFacts = true;
    }
    notifyListeners();
  }
}

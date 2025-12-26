import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class FactItem {
  final IconData icon;
  final String text;
  final bool isWarning;

  FactItem({required this.icon, required this.text, this.isWarning = false});
}

class FactsData {
  final String timeReality;
  final String healthReality;
  final String lifeWarning;
  final bool isPositive;

  FactsData({
    required this.timeReality,
    required this.healthReality,
    required this.lifeWarning,
    required this.isPositive,
  });
}

class FactsCalculator {
  static const int daysPerMonth = 30;

  static FactsData calculateMonthly({required int minutesPerDay}) {
    final double monthlyHours = (minutesPerDay * daysPerMonth) / 60;
    final double yearlyDays = (monthlyHours * 12) / 24;
    final double yearsLost = (yearlyDays * 40) / 365;

    if (minutesPerDay <= 120) {
      return FactsData(
        timeReality: 'facts_screen.positive.time_reality'.tr(),
        healthReality: 'facts_screen.positive.health_reality'.tr(),
        lifeWarning: 'facts_screen.positive.life_warning'.tr(),
        isPositive: true,
      );
    }

    return FactsData(
      timeReality: 'facts_screen.negative.time_reality'.tr(
        namedArgs: {'hours': monthlyHours.toStringAsFixed(0)},
      ),
      healthReality: 'facts_screen.negative.health_reality'.tr(),
      lifeWarning: 'facts_screen.negative.life_warning'.tr(
        namedArgs: {'years': yearsLost.toStringAsFixed(1)},
      ),
      isPositive: false,
    );
  }
}

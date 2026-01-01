import 'package:flutter/material.dart';

/// Represents a single fact item to display
class FactItem {
  final IconData icon;
  final String text;
  final bool isWarning;

  FactItem({required this.icon, required this.text, this.isWarning = false});
}

/// Contains a list of facts and whether they're positive or negative
class FactsData {
  final List<FactItem> facts;
  final bool isPositive;

  FactsData({required this.facts, required this.isPositive});
}

/// Helper class for calculating screen time statistics
class FactsCalculator {
  static const int daysPerMonth = 30;
  static const int daysPerWeek = 7;
  static const int healthyMinutesPerDay = 120; // 2 hours

  /// Calculate if usage is healthy
  static bool isHealthyUsage(int minutesPerDay) {
    return minutesPerDay <= healthyMinutesPerDay;
  }

  /// Calculate monthly hours from daily minutes
  static double calculateMonthlyHours(int minutesPerDay) {
    return (minutesPerDay * daysPerMonth) / 60;
  }

  /// Calculate yearly days from daily minutes
  static double calculateYearlyDays(int minutesPerDay) {
    final monthlyHours = calculateMonthlyHours(minutesPerDay);
    return (monthlyHours * 12) / 24;
  }

  /// Calculate potential years lost over 40 years
  static double calculateYearsLost(int minutesPerDay) {
    final yearlyDays = calculateYearlyDays(minutesPerDay);
    return (yearlyDays * 40) / 365;
  }

  /// Calculate excess time over healthy limit
  static int calculateExcessMinutes(int minutesPerDay) {
    return minutesPerDay > healthyMinutesPerDay
        ? minutesPerDay - healthyMinutesPerDay
        : 0;
  }

  /// Convert minutes to hours (as double)
  static double minutesToHours(int minutes) {
    return minutes / 60;
  }

  /// Get healthy limit in hours
  static double get healthyHoursPerDay => healthyMinutesPerDay / 60;

  /// Generate statistics string for display
  static Map<String, String> generateStats(int minutesPerDay) {
    final hours = minutesToHours(minutesPerDay);
    final monthlyHours = calculateMonthlyHours(minutesPerDay);
    final yearlyDays = calculateYearlyDays(minutesPerDay);
    final yearsLost = calculateYearsLost(minutesPerDay);
    final excessMinutes = calculateExcessMinutes(minutesPerDay);
    final excessHours = minutesToHours(excessMinutes);

    return {
      'hours': hours.toStringAsFixed(1),
      'monthlyHours': monthlyHours.toStringAsFixed(0),
      'yearlyDays': yearlyDays.toStringAsFixed(1),
      'yearsLost': yearsLost.toStringAsFixed(1),
      'excessHours': excessHours.toStringAsFixed(1),
      'healthyHours': healthyHoursPerDay.toStringAsFixed(0),
    };
  }
}

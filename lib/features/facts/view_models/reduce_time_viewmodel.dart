import 'dart:async';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:lockin/features/facts/models/reduce_time_model.dart';

class TipsViewModel extends ChangeNotifier {
  final bool isPositive;
  late final List<TipModel> tips;
  late final List<bool> _visibleStates;

  static const _animationDelay = Duration(milliseconds: 500);
  Timer? _animationTimer;

  TipsViewModel({required this.isPositive}) {
    tips = _generateTips();
    _visibleStates = List.generate(_totalAnimatedElements, (_) => false);
    _startAnimationSequence();
  }

  /// Total elements to animate (header + tips + closing message)
  int get _totalAnimatedElements => tips.length + 2;

  /// Public getter for visible states
  List<bool> get visible => List.unmodifiable(_visibleStates);

  /// Generate tips based on positive/negative context
  List<TipModel> _generateTips() {
    if (isPositive) {
      return _positiveTips;
    } else {
      return _negativeTips;
    }
  }

  /// Tips for positive screen time results
  List<TipModel> get _positiveTips => [
    TipModel(icon: Icons.celebration, text: 'tips_screen.positive.tip_1'.tr()),
    TipModel(
      icon: Icons.trending_down,
      text: 'tips_screen.positive.tip_2'.tr(),
    ),
    TipModel(
      icon: Icons.self_improvement,
      text: 'tips_screen.positive.tip_3'.tr(),
    ),
    TipModel(
      icon: Icons.track_changes,
      text: 'tips_screen.positive.tip_4'.tr(),
    ),
    TipModel(icon: Icons.wb_sunny, text: 'tips_screen.positive.tip_5'.tr()),
  ];

  /// Tips for reducing screen time
  List<TipModel> get _negativeTips => [
    TipModel(
      icon: Icons.notifications_off,
      text: 'tips_screen.negative.tip_1'.tr(),
    ),
    TipModel(icon: Icons.timer, text: 'tips_screen.negative.tip_2'.tr()),
    TipModel(icon: Icons.book, text: 'tips_screen.negative.tip_3'.tr()),
    TipModel(icon: Icons.bedtime, text: 'tips_screen.negative.tip_4'.tr()),
    TipModel(
      icon: Icons.directions_walk,
      text: 'tips_screen.negative.tip_5'.tr(),
    ),
    TipModel(
      icon: Icons.phone_disabled,
      text: 'tips_screen.negative.tip_6'.tr(),
    ),
  ];

  /// Start the sequential animation
  Future<void> _startAnimationSequence() async {
    for (int i = 0; i < _visibleStates.length; i++) {
      if (!mounted) break;

      await Future.delayed(_animationDelay);
      _visibleStates[i] = true;
      notifyListeners();
    }
  }

  /// Header text based on context
  String get header {
    return isPositive
        ? 'tips_screen.header_positive'.tr()
        : 'tips_screen.header_negative'.tr();
  }

  /// Closing message based on context
  String get closingMessage {
    return isPositive
        ? 'tips_screen.closing_message_positive'.tr()
        : 'tips_screen.closing_message_negative'.tr();
  }

  /// Check if the ViewModel is still mounted
  bool _mounted = true;
  bool get mounted => _mounted;

  @override
  void dispose() {
    _mounted = false;
    _animationTimer?.cancel();
    super.dispose();
  }
}

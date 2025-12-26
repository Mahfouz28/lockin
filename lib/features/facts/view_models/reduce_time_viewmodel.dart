import 'dart:async';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:lockin/features/facts/models/reduce_time_model.dart';

class TipsViewModel extends ChangeNotifier {
  final bool isPositive;
  final List<bool> visible = [];
  final List<TipModel> tips;

  static const _animationDelay = Duration(milliseconds: 500);

  TipsViewModel({required this.isPositive})
    : tips = [
        TipModel(icon: Icons.notifications_off, text: 'tips_screen.tip_1'.tr()),
        TipModel(icon: Icons.timer, text: 'tips_screen.tip_2'.tr()),
        TipModel(icon: Icons.book, text: 'tips_screen.tip_3'.tr()),
        TipModel(icon: Icons.bedtime, text: 'tips_screen.tip_4'.tr()),
      ] {
    visible.addAll(List.generate(tips.length + 2, (_) => false));
    _startSequence();
  }

  Future<void> _startSequence() async {
    for (int i = 0; i < visible.length; i++) {
      await Future.delayed(_animationDelay);
      visible[i] = true;
      notifyListeners();
    }
  }

  String get header => isPositive
      ? 'tips_screen.header_positive'.tr()
      : 'tips_screen.header_negative'.tr();

  String get closingMessage => 'tips_screen.closing_message'.tr();
}

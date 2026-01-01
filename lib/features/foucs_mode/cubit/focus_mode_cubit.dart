// lib/features/focus_mode/cubit/focus_mode_cubit.dart
// (تأكد إن المجلد focus_mode مش foucs_mode في كل المشروع)

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:equatable/equatable.dart';
import 'package:lockin/core/services/notifcation_service.dart';
import 'package:lockin/core/services/shared_prefs_service.dart';

import 'package:lockin/features/foucs_mode/models/installed_app_model.dart.dart';
import 'package:lockin/features/foucs_mode/services/installed_apps_service.dart';
import 'package:workmanager/workmanager.dart';

part 'focus_mode_state.dart';

class FocusModeCubit extends Cubit<FocusModeState> {
  final SharedPrefsService _prefsService;
  final InstalledAppsService _installedAppsService;
  final NotificationService _notificationService;

  List<InstalledAppModel> _apps = [];
  int? _selectedDuration;
  bool _isExpanded = false;

  Timer? _countdownTimer;
  DateTime? _focusEndTime;

  // مهم جدًا: عشان نتجنب إعادة الـ emit لنفس الحالة بشكل متكرر
  FocusModeActive? _lastEmittedActiveState;

  FocusModeCubit(
    this._prefsService,
    this._installedAppsService,
    this._notificationService,
  ) : super(
        const FocusModeLoaded(
          installedApps: [],
          selectedDuration: null,
          isExpanded: false,
        ),
      );

  // =================================================================
  // Public Getters
  // =================================================================
  int? get selectedDuration => _selectedDuration;
  DateTime? get focusEndTime => _focusEndTime;
  List<InstalledAppModel> get apps => List.unmodifiable(_apps);
  bool get isExpanded => _isExpanded;

  // =================================================================
  // Load Apps & Check Active Session
  // =================================================================

  Future<void> loadApps() async {
    if (state is! FocusModeActive) {
      emit(const FocusModeLoading());
    }

    try {
      final installedApps = await _installedAppsService.getInstalledApps();

      _apps = installedApps
          .map(
            (app) => InstalledAppModel(
              name: app.name,
              packageName: app.packageName,
              icon: app.icon,
              selected: false,
            ),
          )
          .toList();

      _emitLoadedState();
    } catch (e) {
      emit(FocusModeError(message: tr('focus_mode.errors.failed_load_apps')));
      _apps = [];
      _emitLoadedState();
    }
  }

  Future<void> checkActiveFocusMode() async {
    final isEnabled = await _prefsService.isFocusModeEnabled();

    if (!isEnabled) {
      await loadApps();
      return;
    }

    final endTime = await _prefsService.getFocusEndTime();
    if (endTime == null) {
      await _cleanupAndLoadApps();
      return;
    }

    _focusEndTime = endTime;
    final now = DateTime.now();

    if (now.isAfter(_focusEndTime!)) {
      await _handleFocusComplete();
      return;
    }

    await _resumeActiveFocusMode();
  }

  // =================================================================
  // User Interactions
  // =================================================================

  void toggleAppSelection(int index) {
    if (!_isValidIndex(index)) return;

    _apps = List<InstalledAppModel>.from(_apps);
    _apps[index] = _apps[index].copyWith(selected: !_apps[index].selected);
    _emitLoadedState();
  }

  void setDuration(int minutes) {
    _selectedDuration = minutes;
    _emitLoadedState();
  }

  void toggleExpand() {
    _isExpanded = !_isExpanded;
    _emitLoadedState();
  }

  // =================================================================
  // Focus Mode Management
  // =================================================================

  Future<void> startFocusMode() async {
    final validationError = _validateFocusStart();
    if (validationError != null) {
      emit(FocusModeError(message: validationError));
      return;
    }

    try {
      final blockedApps = _getSelectedApps();

      await _saveFocusSettings(blockedApps);
      await _scheduleWorkManagerTask();

      _startCountdownTimer();

      emit(FocusModeStarted(blockedApps: blockedApps));

      if (!isClosed) {
        _emitActiveState(blockedApps);
      }
    } catch (e) {
      emit(FocusModeError(message: tr('focus_mode.errors.failed_start_focus')));
    }
  }

  Future<void> stopFocusMode() async {
    await _cleanupFocusMode();

    if (!isClosed) {
      emit(const FocusModeStopped());
      await loadApps();
    }
  }

  // =================================================================
  // Private Helper Methods
  // =================================================================

  String? _validateFocusStart() {
    final selectedApps = _apps.where((a) => a.selected).toList();

    if (selectedApps.isEmpty) {
      return tr('focus_mode.errors.select_one_app');
    }

    if (_selectedDuration == null) {
      return tr('focus_mode.errors.select_duration');
    }

    return null;
  }

  List<String> _getSelectedApps() {
    return _apps.where((a) => a.selected).map((a) => a.packageName).toList();
  }

  Future<void> _saveFocusSettings(List<String> blockedApps) async {
    await _prefsService.setFocusModeEnabled(true);
    await _prefsService.setBlockedApps(blockedApps);

    _focusEndTime = DateTime.now().add(Duration(minutes: _selectedDuration!));
    await _prefsService.setFocusEndTime(_focusEndTime!);
  }

  Future<void> _scheduleWorkManagerTask() async {
    await Workmanager().registerOneOffTask(
      "focus_complete_${DateTime.now().millisecondsSinceEpoch}",
      "focus_complete",
      initialDelay: Duration(minutes: _selectedDuration!),
    );
  }

  void _startCountdownTimer() {
    _countdownTimer?.cancel();

    _countdownTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _onCountdownTick(),
    );
  }

  Future<void> _onCountdownTick() async {
    if (isClosed || _focusEndTime == null) {
      _countdownTimer?.cancel();
      return;
    }

    final now = DateTime.now();
    final difference = _focusEndTime!.difference(now);

    if (difference.isNegative || difference.inSeconds <= 0) {
      _countdownTimer?.cancel();
      await _handleFocusComplete();
      return;
    }

    final remainingMinutes = difference.inMinutes;
    final remainingSeconds = difference.inSeconds % 60;

    // إشعار قبل 5 دقائق
    if (remainingMinutes == 5 && remainingSeconds == 0) {
      await _notificationService.showFocusEndingSoonNotification();
    }

    final blockedApps = await _prefsService.getBlockedApps();

    // الحل الأساسي: نتجنب إعادة emit لنفس الحالة بالضبط
    final newActiveState = FocusModeActive(
      blockedApps: blockedApps,
      remainingMinutes: remainingMinutes,
      remainingSeconds: remainingSeconds,
    );

    // لو الحالة الجديدة نفس الأخيرة → ما نعملش emit
    if (_lastEmittedActiveState != null &&
        _lastEmittedActiveState!.remainingMinutes == remainingMinutes &&
        _lastEmittedActiveState!.remainingSeconds == remainingSeconds &&
        _lastEmittedActiveState!.blockedApps.length == blockedApps.length) {
      return;
    }

    _lastEmittedActiveState = newActiveState;

    if (!isClosed) {
      emit(newActiveState);
    }
  }

  Future<void> _handleFocusComplete() async {
    await _notificationService.showFocusCompleteNotification();
    await stopFocusMode();
  }

  Future<void> _resumeActiveFocusMode() async {
    _startCountdownTimer();

    final blockedApps = await _prefsService.getBlockedApps();
    final now = DateTime.now();
    final difference = _focusEndTime!.difference(now);

    final remainingMinutes = difference.inMinutes.clamp(
      0,
      _selectedDuration ?? 0,
    );
    final remainingSeconds = difference.inSeconds % 60;

    final activeState = FocusModeActive(
      blockedApps: blockedApps,
      remainingMinutes: remainingMinutes,
      remainingSeconds: remainingSeconds,
    );

    _lastEmittedActiveState = activeState;

    if (!isClosed) {
      emit(activeState);
    }
  }

  Future<void> _cleanupAndLoadApps() async {
    await _cleanupFocusMode();
    await loadApps();
  }

  Future<void> _cleanupFocusMode() async {
    _countdownTimer?.cancel();
    _countdownTimer = null;
    _focusEndTime = null;
    _lastEmittedActiveState = null; // مهم: نعيد تعيينه

    await _prefsService.clearBlockedApps();
    await _prefsService.setFocusModeEnabled(false);
    await _prefsService.clearFocusEndTime();
    await Workmanager().cancelAll();
  }

  void _emitLoadedState() {
    emit(
      FocusModeLoaded(
        installedApps: List<InstalledAppModel>.from(_apps),
        selectedDuration: _selectedDuration,
        isExpanded: _isExpanded,
      ),
    );
  }

  void _emitActiveState(List<String> blockedApps) {
    final difference = _focusEndTime!.difference(DateTime.now());
    final remainingMinutes = difference.inMinutes.clamp(
      0,
      _selectedDuration ?? 0,
    );
    final remainingSeconds = difference.inSeconds % 60;

    final activeState = FocusModeActive(
      blockedApps: blockedApps,
      remainingMinutes: remainingMinutes,
      remainingSeconds: remainingSeconds,
    );

    _lastEmittedActiveState = activeState;

    emit(activeState);
  }

  bool _isValidIndex(int index) {
    return index >= 0 && index < _apps.length;
  }

  @override
  Future<void> close() async {
    _countdownTimer?.cancel();
    await super.close();
  }
}

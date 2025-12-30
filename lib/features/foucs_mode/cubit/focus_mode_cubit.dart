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

  List<InstalledAppModel> _apps = [];
  int? _selectedDuration;
  bool _isExpanded = false;

  Timer? _countdownTimer;
  DateTime? _focusEndTime;

  FocusModeCubit(this._prefsService, this._installedAppsService)
    : super(const FocusModeLoading());

  Future<void> loadApps() async {
    emit(const FocusModeLoading());
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

      emit(
        FocusModeLoaded(
          installedApps: _apps,
          selectedDuration: _selectedDuration,
          isExpanded: _isExpanded,
        ),
      );
    } catch (_) {
      emit(FocusModeError(message: tr('focus_mode.errors.failed_load_apps')));
    }
  }

  void toggleAppSelection(int index) {
    if (index < 0 || index >= _apps.length) return;
    _apps[index] = _apps[index].copyWith(selected: !_apps[index].selected);
    emit(
      FocusModeLoaded(
        installedApps: _apps,
        selectedDuration: _selectedDuration,
        isExpanded: _isExpanded,
      ),
    );
  }

  void setDuration(int minutes) {
    _selectedDuration = minutes;
    emit(
      FocusModeLoaded(
        installedApps: _apps,
        selectedDuration: minutes,
        isExpanded: _isExpanded,
      ),
    );
  }

  void toggleExpand() {
    _isExpanded = !_isExpanded;
    emit(
      FocusModeLoaded(
        installedApps: _apps,
        selectedDuration: _selectedDuration,
        isExpanded: _isExpanded,
      ),
    );
  }

  Future<void> startFocusMode() async {
    final blockedApps = _apps
        .where((a) => a.selected)
        .map((a) => a.packageName)
        .toList();
    if (blockedApps.isEmpty) {
      emit(FocusModeError(message: tr('focus_mode.errors.select_one_app')));
      return;
    }
    if (_selectedDuration == null) {
      emit(FocusModeError(message: tr('focus_mode.errors.select_duration')));
      return;
    }

    try {
      await _prefsService.setFocusModeEnabled(true);
      await _prefsService.setBlockedApps(blockedApps);

      _focusEndTime = DateTime.now().add(Duration(minutes: _selectedDuration!));
      await _prefsService.setFocusEndTime(_focusEndTime!);

      _startCountdownTimer();
      await Workmanager().registerOneOffTask(
        "focus_complete_${DateTime.now().millisecondsSinceEpoch}",
        "focus_complete",
        initialDelay: Duration(minutes: _selectedDuration!),
      );

      emit(FocusModeStarted(blockedApps: blockedApps));
      emit(
        FocusModeActive(
          blockedApps: blockedApps,
          remainingMinutes: _selectedDuration!,
        ),
      );
    } catch (_) {
      emit(FocusModeError(message: tr('focus_mode.errors.failed_start_focus')));
    }
  }

  void _startCountdownTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 60), (_) async {
      if (_focusEndTime == null) return;

      final now = DateTime.now();
      final remaining = _focusEndTime!.difference(now).inMinutes;

      if (remaining <= 0) {
        await stopFocusMode();
        await NotificationService().showFocusCompleteNotification();
        _countdownTimer?.cancel();
      } else {
        // Notify if session about to end (last 5 minutes)
        if (remaining == 5) {
          await NotificationService().showFocusEndingSoonNotification();
        }

        final blockedApps = await _prefsService.getBlockedApps();
        emit(
          FocusModeActive(
            blockedApps: blockedApps,
            remainingMinutes: remaining,
          ),
        );
      }
    });
  }

  Future<void> stopFocusMode() async {
    _countdownTimer?.cancel();
    _focusEndTime = null;
    await _prefsService.clearBlockedApps();
    await _prefsService.setFocusModeEnabled(false);
    await _prefsService.clearFocusEndTime();
    await Workmanager().cancelAll();
    emit(const FocusModeStopped());
  }

  Future<void> checkActiveFocusMode() async {
    final isEnabled = await _prefsService.isFocusModeEnabled();
    if (!isEnabled) {
      await loadApps();
      return;
    }

    final endTime = await _prefsService.getFocusEndTime();
    if (endTime == null) {
      await loadApps();
      return;
    }

    _focusEndTime = endTime;
    final now = DateTime.now();

    if (now.isAfter(_focusEndTime!)) {
      await stopFocusMode();
      await NotificationService().showFocusCompleteNotification();
      await loadApps();
      return;
    }

    _startCountdownTimer();
    final blockedApps = await _prefsService.getBlockedApps();
    final remaining = _focusEndTime!.difference(now).inMinutes;
    emit(
      FocusModeActive(blockedApps: blockedApps, remainingMinutes: remaining),
    );
  }

  @override
  Future<void> close() async {
    _countdownTimer?.cancel();
    return super.close();
  }
}

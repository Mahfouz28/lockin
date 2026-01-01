part of 'focus_mode_cubit.dart';

abstract class FocusModeState extends Equatable {
  const FocusModeState();

  @override
  List<Object?> get props => [];
}

class FocusModeLoading extends FocusModeState {
  const FocusModeLoading();

  @override
  List<Object?> get props => [];
}

class FocusModeLoaded extends FocusModeState {
  final List<InstalledAppModel> installedApps;
  final int? selectedDuration; // in minutes
  final bool isExpanded;

  const FocusModeLoaded({
    required this.installedApps,
    this.selectedDuration,
    this.isExpanded = false,
  });

  @override
  List<Object?> get props => [installedApps, selectedDuration, isExpanded];
}

class FocusModeActive extends FocusModeState {
  final List<String> blockedApps;
  final int remainingMinutes;
  final int remainingSeconds;

  const FocusModeActive({
    required this.blockedApps,
    required this.remainingMinutes,
    this.remainingSeconds = 0,
  });

  @override
  List<Object?> get props => [blockedApps, remainingMinutes, remainingSeconds];

  /// دالة مساعدة للحصول على الوقت المتبقي كنص (مثلاً: 14:37)
  String get formattedRemainingTime {
    final minutesStr = remainingMinutes.toString().padLeft(2, '0');
    final secondsStr = remainingSeconds.toString().padLeft(2, '0');
    return '$minutesStr:$secondsStr';
  }

  /// دالة لحساب الإجمالي بالثواني (مفيدة للـ progress calculation)
  int get totalRemainingSeconds => (remainingMinutes * 60) + remainingSeconds;
}

/// Temporary state to notify the UI that Focus Mode has just been started
/// مفيد لإظهار SnackBar أو تنشيط انيميشن
class FocusModeStarted extends FocusModeState {
  final List<String> blockedApps;

  const FocusModeStarted({required this.blockedApps});

  @override
  List<Object?> get props => [blockedApps];
}

/// State emitted when Focus Mode has been stopped (manually or by timeout)
class FocusModeStopped extends FocusModeState {
  const FocusModeStopped();

  @override
  List<Object?> get props => [];
}

class FocusModeError extends FocusModeState {
  final String message;

  const FocusModeError({required this.message});

  @override
  List<Object?> get props => [message];
}

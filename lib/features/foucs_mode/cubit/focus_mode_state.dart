part of 'focus_mode_cubit.dart';

abstract class FocusModeState extends Equatable {
  const FocusModeState();
}

class FocusModeInitial extends FocusModeState {
  const FocusModeInitial();

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

/// State emitted while Focus Mode is actively running (with timer countdown)
class FocusModeActive extends FocusModeState {
  final List<String> blockedApps;
  final int remainingMinutes; // remaining time in minutes

  const FocusModeActive({
    required this.blockedApps,
    required this.remainingMinutes,
  });

  @override
  List<Object?> get props => [blockedApps, remainingMinutes];
}

/// Temporary state to notify the UI that Focus Mode has just been started
/// (useful for showing a SnackBar and popping the screen)
class FocusModeStarted extends FocusModeState {
  final List<String> blockedApps;

  const FocusModeStarted({required this.blockedApps});

  @override
  List<Object?> get props => [blockedApps];
}

/// State emitted when Focus Mode has been stopped (manually or automatically)
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

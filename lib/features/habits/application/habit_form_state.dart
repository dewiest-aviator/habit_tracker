import 'package:flutter/foundation.dart';

enum HabitFormMode { create, edit }

@immutable
class HabitFormErrors {
  const HabitFormErrors({
    this.name,
    this.emoji,
    this.days,
    this.reminderTime,
    this.limit,
  });

  final String? name;
  final String? emoji;
  final String? days;
  final String? reminderTime;
  final String? limit;

  bool get hasAny =>
      name != null ||
      emoji != null ||
      days != null ||
      reminderTime != null ||
      limit != null;

  HabitFormErrors copyWith({
    String? name,
    bool clearName = false,
    String? emoji,
    bool clearEmoji = false,
    String? days,
    bool clearDays = false,
    String? reminderTime,
    bool clearReminderTime = false,
    String? limit,
    bool clearLimit = false,
  }) {
    return HabitFormErrors(
      name: clearName ? null : (name ?? this.name),
      emoji: clearEmoji ? null : (emoji ?? this.emoji),
      days: clearDays ? null : (days ?? this.days),
      reminderTime: clearReminderTime
          ? null
          : (reminderTime ?? this.reminderTime),
      limit: clearLimit ? null : (limit ?? this.limit),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HabitFormErrors &&
        other.name == name &&
        other.emoji == emoji &&
        other.days == days &&
        other.reminderTime == reminderTime &&
        other.limit == limit;
  }

  @override
  int get hashCode => Object.hash(name, emoji, days, reminderTime, limit);
}

@immutable
class HabitFormState {
  HabitFormState({
    required this.mode,
    this.habitId,
    required this.emoji,
    required this.name,
    required int color,
    required List<int> days,
    required this.reminderEnabled,
    required this.reminderTime,
    this.isLoading = false,
    this.isSaving = false,
    this.isDeleting = false,
    this.errorMessage,
    HabitFormErrors? errors,
    this.hasChanges = false,
  }) : assert(color >= 0 && color <= 0xFFFFFFFF),
       _color = color,
       _days = List<int>.unmodifiable(List<int>.from(days)..sort()),
       errors = errors ?? const HabitFormErrors();

  factory HabitFormState.initial({HabitFormMode mode = HabitFormMode.create}) {
    return HabitFormState(
      mode: mode,
      emoji: '🌱',
      name: '',
      color: 0xFF4F46E5,
      days: List<int>.generate(7, (index) => index),
      reminderEnabled: false,
      reminderTime: '08:00',
      isLoading: mode == HabitFormMode.edit,
    );
  }

  final HabitFormMode mode;
  final String? habitId;
  final String emoji;
  final String name;
  final bool reminderEnabled;
  final String reminderTime;
  final bool isLoading;
  final bool isSaving;
  final bool isDeleting;
  final String? errorMessage;
  final HabitFormErrors errors;
  final bool hasChanges;

  final int _color;
  final List<int> _days;

  int get color => _color;
  List<int> get days => _days;

  bool get canSubmit =>
      !isLoading &&
      !isSaving &&
      !isDeleting &&
      errors.limit == null &&
      _isFormDataValid;

  bool get isEditMode => mode == HabitFormMode.edit;

  bool get showReminderTime => reminderEnabled;

  bool get _isFormDataValid {
    final trimmed = name.trim();
    final hasName = trimmed.length >= 2 && trimmed.length <= 32;
    final hasEmoji = emoji.isNotEmpty;
    final hasDays = days.isNotEmpty;
    final reminderValid = !reminderEnabled || _isValidTime(reminderTime);
    return hasName && hasEmoji && hasDays && reminderValid;
  }

  HabitFormState copyWith({
    HabitFormMode? mode,
    String? habitId,
    String? emoji,
    String? name,
    int? color,
    List<int>? days,
    bool? reminderEnabled,
    String? reminderTime,
    bool? isLoading,
    bool? isSaving,
    bool? isDeleting,
    String? errorMessage,
    HabitFormErrors? errors,
    bool? hasChanges,
    bool clearErrorMessage = false,
  }) {
    return HabitFormState(
      mode: mode ?? this.mode,
      habitId: habitId ?? this.habitId,
      emoji: emoji ?? this.emoji,
      name: name ?? this.name,
      color: color ?? _color,
      days: days ?? _days,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderTime: reminderTime ?? this.reminderTime,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      isDeleting: isDeleting ?? this.isDeleting,
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
      errors: errors ?? this.errors,
      hasChanges: hasChanges ?? this.hasChanges,
    );
  }

  static bool _isValidTime(String value) {
    final parts = value.split(':');
    if (parts.length != 2) return false;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return false;
    return hour >= 0 && hour <= 23 && minute >= 0 && minute <= 59;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HabitFormState &&
        other.mode == mode &&
        other.habitId == habitId &&
        other.emoji == emoji &&
        other.name == name &&
        other._color == _color &&
        listEquals(other._days, _days) &&
        other.reminderEnabled == reminderEnabled &&
        other.reminderTime == reminderTime &&
        other.isLoading == isLoading &&
        other.isSaving == isSaving &&
        other.isDeleting == isDeleting &&
        other.errorMessage == errorMessage &&
        other.errors == errors &&
        other.hasChanges == hasChanges;
  }

  @override
  int get hashCode => Object.hash(
    mode,
    habitId,
    emoji,
    name,
    _color,
    Object.hashAll(_days),
    reminderEnabled,
    reminderTime,
    isLoading,
    isSaving,
    isDeleting,
    errorMessage,
    errors,
    hasChanges,
  );
}

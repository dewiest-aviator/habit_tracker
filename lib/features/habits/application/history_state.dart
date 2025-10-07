import 'dart:collection';

import 'package:flutter/foundation.dart';

import '../domain/domain.dart';

const _unset = Object();

enum HistoryHabitStatus { completed, missed, pending }

@immutable
class HistoryHabitViewData {
  const HistoryHabitViewData({
    required this.habit,
    required this.date,
    required this.status,
  });

  final Habit habit;
  final DateTime date;
  final HistoryHabitStatus status;

  bool get isCompleted => status == HistoryHabitStatus.completed;
  bool get isMissed => status == HistoryHabitStatus.missed;
  bool get isPending => status == HistoryHabitStatus.pending;

  HistoryHabitViewData copyWith({
    Habit? habit,
    DateTime? date,
    HistoryHabitStatus? status,
  }) {
    return HistoryHabitViewData(
      habit: habit ?? this.habit,
      date: date ?? this.date,
      status: status ?? this.status,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HistoryHabitViewData &&
        other.habit == habit &&
        other.date == date &&
        other.status == status;
  }

  @override
  int get hashCode => Object.hash(habit, date, status);
}

@immutable
class HistoryDayViewData {
  HistoryDayViewData({
    required this.date,
    required List<HistoryHabitViewData> habits,
  }) : _habits = List<HistoryHabitViewData>.unmodifiable(habits);

  final DateTime date;
  final List<HistoryHabitViewData> _habits;

  UnmodifiableListView<HistoryHabitViewData> get habits =>
      UnmodifiableListView(_habits);

  int get totalCount => _habits.length;
  int get completedCount => _habits.where((habit) => habit.isCompleted).length;
  double get completionRate =>
      totalCount == 0 ? 0 : completedCount / totalCount;

  bool get hasHabits => totalCount > 0;

  HistoryDayViewData copyWith({
    DateTime? date,
    List<HistoryHabitViewData>? habits,
  }) {
    return HistoryDayViewData(
      date: date ?? this.date,
      habits: habits ?? _habits,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HistoryDayViewData &&
        other.date == date &&
        listEquals(other._habits, _habits);
  }

  @override
  int get hashCode => Object.hash(date, Object.hashAll(_habits));
}

@immutable
class HistoryStreakSummary {
  const HistoryStreakSummary({
    required this.bestStreak,
    required this.currentStreak,
    this.bestHabit,
    this.currentHabit,
  });

  final int bestStreak;
  final int currentStreak;
  final Habit? bestHabit;
  final Habit? currentHabit;

  bool get hasData => bestStreak > 0 || currentStreak > 0;

  HistoryStreakSummary copyWith({
    int? bestStreak,
    int? currentStreak,
    Habit? bestHabit,
    Habit? currentHabit,
  }) {
    return HistoryStreakSummary(
      bestStreak: bestStreak ?? this.bestStreak,
      currentStreak: currentStreak ?? this.currentStreak,
      bestHabit: bestHabit ?? this.bestHabit,
      currentHabit: currentHabit ?? this.currentHabit,
    );
  }
}

@immutable
class HistoryState {
  HistoryState({
    required this.rangeStart,
    required this.rangeEnd,
    required this.selectedDate,
    required List<HistoryDayViewData> days,
    required List<Habit> habits,
    this.filterHabitId,
    this.isLoading = false,
    this.errorMessage,
    HistoryStreakSummary? streakSummary,
  }) : _days = List<HistoryDayViewData>.unmodifiable(days),
       _habits = List<Habit>.unmodifiable(habits),
       streakSummary =
           streakSummary ??
           const HistoryStreakSummary(bestStreak: 0, currentStreak: 0);

  factory HistoryState.initial(
    DateTime referenceDate, {
    required int rangeDays,
  }) {
    final end = DateTime(
      referenceDate.year,
      referenceDate.month,
      referenceDate.day,
    );
    final start = end.subtract(Duration(days: rangeDays - 1));
    return HistoryState(
      rangeStart: start,
      rangeEnd: end,
      selectedDate: end,
      days: const [],
      habits: const [],
      isLoading: true,
    );
  }

  final DateTime rangeStart;
  final DateTime rangeEnd;
  final DateTime selectedDate;
  final String? filterHabitId;
  final bool isLoading;
  final String? errorMessage;
  final HistoryStreakSummary streakSummary;
  final List<HistoryDayViewData> _days;
  final List<Habit> _habits;

  UnmodifiableListView<HistoryDayViewData> get days =>
      UnmodifiableListView(_days);
  UnmodifiableListView<Habit> get habits => UnmodifiableListView(_habits);

  Map<DateTime, HistoryDayViewData> get dayIndex => {
    for (final day in _days) day.date: day,
  };

  Map<DateTime, double> get completionByDate => {
    for (final day in _days) day.date: day.completionRate,
  };

  bool get hasError => errorMessage != null;

  bool get hasHabits => _habits.isNotEmpty;

  bool get isEmpty => !isLoading && _days.every((day) => !day.hasHabits);

  HistoryDayViewData? dayFor(DateTime date) => dayIndex[date];

  HistoryState copyWith({
    DateTime? rangeStart,
    DateTime? rangeEnd,
    DateTime? selectedDate,
    List<HistoryDayViewData>? days,
    List<Habit>? habits,
    Object? filterHabitId = _unset,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    HistoryStreakSummary? streakSummary,
  }) {
    final resolvedFilter = filterHabitId == _unset
        ? this.filterHabitId
        : filterHabitId as String?;
    return HistoryState(
      rangeStart: rangeStart ?? this.rangeStart,
      rangeEnd: rangeEnd ?? this.rangeEnd,
      selectedDate: selectedDate ?? this.selectedDate,
      days: days ?? _days,
      habits: habits ?? _habits,
      filterHabitId: resolvedFilter,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      streakSummary: streakSummary ?? this.streakSummary,
    );
  }
}

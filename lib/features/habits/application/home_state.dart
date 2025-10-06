import 'dart:collection';

import 'package:flutter/foundation.dart';

import '../domain/domain.dart';

@immutable
class HomeHabitViewData {
  const HomeHabitViewData({required this.habit, required this.isCompleted});

  final Habit habit;
  final bool isCompleted;

  HomeHabitViewData copyWith({Habit? habit, bool? isCompleted}) {
    return HomeHabitViewData(
      habit: habit ?? this.habit,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HomeHabitViewData &&
        other.habit == habit &&
        other.isCompleted == isCompleted;
  }

  @override
  int get hashCode => Object.hash(habit, isCompleted);
}

@immutable
class HomeState {
  HomeState({
    required List<HomeHabitViewData> habits,
    required this.currentDate,
    this.isLoading = false,
    this.errorMessage,
  }) : _habits = List<HomeHabitViewData>.unmodifiable(habits);

  factory HomeState.initial(DateTime currentDate) {
    return HomeState(
      habits: const [],
      currentDate: currentDate,
      isLoading: true,
    );
  }

  final List<HomeHabitViewData> _habits;
  final DateTime currentDate;
  final bool isLoading;
  final String? errorMessage;

  static const int maxHabits = 3;

  UnmodifiableListView<HomeHabitViewData> get habits =>
      UnmodifiableListView(_habits);

  int get completedCount => _habits.where((habit) => habit.isCompleted).length;

  bool get canAddHabit => _habits.length < maxHabits;

  bool get isEmpty => !isLoading && _habits.isEmpty;

  HomeState copyWith({
    List<HomeHabitViewData>? habits,
    DateTime? currentDate,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    final resolvedHabits = habits ?? _habits;
    return HomeState(
      habits: resolvedHabits,
      currentDate: currentDate ?? this.currentDate,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

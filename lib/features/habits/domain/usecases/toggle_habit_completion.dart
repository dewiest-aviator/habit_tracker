import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/habit_entries_repository.dart';
import '../../data/repositories/habits_repository.dart';
import '../../domain/domain.dart';
import '../../../../core/utils/date_helpers.dart';
import 'compute_streaks.dart';

class ToggleHabitResult {
  ToggleHabitResult({required this.habit, this.entry});

  final Habit habit;
  final HabitEntry? entry;

  bool get isCompleted => entry?.done ?? false;
}

class ToggleHabitCompletion {
  ToggleHabitCompletion({
    required HabitsRepository habitsRepository,
    required HabitEntriesRepository entriesRepository,
    required ComputeStreaks computeStreaks,
  }) : _habitsRepository = habitsRepository,
       _entriesRepository = entriesRepository,
       _computeStreaks = computeStreaks;

  final HabitsRepository _habitsRepository;
  final HabitEntriesRepository _entriesRepository;
  final ComputeStreaks _computeStreaks;

  Future<ToggleHabitResult> call({
    required String habitId,
    required DateTime date,
  }) async {
    final habit = await _habitsRepository.findById(habitId);
    if (habit == null) {
      throw StateError('Habit $habitId not found');
    }

    final normalizedDate = DateHelpers.startOfDay(date);
    final existingEntry = await _entriesRepository.findEntry(
      habitId,
      normalizedDate,
    );
    final shouldComplete = !(existingEntry?.done ?? false);

    HabitEntry? updatedEntry;
    if (shouldComplete) {
      updatedEntry = HabitEntry(
        habitId: habitId,
        date: normalizedDate,
        done: true,
      );
      await _entriesRepository.saveEntry(updatedEntry);
    } else {
      await _entriesRepository.deleteEntry(habitId, normalizedDate);
    }

    final streaks = await _computeStreaks(habitId);
    final updatedHabit = habit.copyWith(
      currentStreak: streaks.current,
      bestStreak: streaks.best,
      lastChecked: shouldComplete ? normalizedDate : habit.lastChecked,
      clearLastChecked: !shouldComplete,
    );
    await _habitsRepository.saveHabit(updatedHabit);

    return ToggleHabitResult(habit: updatedHabit, entry: updatedEntry);
  }
}

final toggleHabitCompletionProvider = Provider<ToggleHabitCompletion>((ref) {
  final habitsRepository = ref.watch(habitsRepositoryProvider);
  final entriesRepository = ref.watch(habitEntriesRepositoryProvider);
  final computeStreaks = ref.watch(computeStreaksProvider);
  return ToggleHabitCompletion(
    habitsRepository: habitsRepository,
    entriesRepository: entriesRepository,
    computeStreaks: computeStreaks,
  );
});

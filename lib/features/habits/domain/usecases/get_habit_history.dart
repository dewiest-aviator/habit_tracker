import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/date_helpers.dart';
import '../../data/repositories/habit_entries_repository.dart';
import '../../data/repositories/habits_repository.dart';
import '../domain.dart';

@immutable
class HabitHistoryItem {
  const HabitHistoryItem({required this.habit, required this.date, this.entry});

  final Habit habit;
  final DateTime date;
  final HabitEntry? entry;

  bool get isCompleted => entry?.done ?? false;

  HabitHistoryItem copyWith({Habit? habit, DateTime? date, HabitEntry? entry}) {
    return HabitHistoryItem(
      habit: habit ?? this.habit,
      date: date ?? this.date,
      entry: entry ?? this.entry,
    );
  }
}

@immutable
class HabitHistoryDay {
  HabitHistoryDay({required this.date, required List<HabitHistoryItem> items})
    : items = List<HabitHistoryItem>.unmodifiable(items);

  final DateTime date;
  final List<HabitHistoryItem> items;

  int get totalCount => items.length;
  int get completedCount => items.where((item) => item.isCompleted).length;
  double get completionRate =>
      totalCount == 0 ? 0 : completedCount / totalCount;
}

@immutable
class HabitHistorySnapshot {
  HabitHistorySnapshot({
    required this.rangeStart,
    required this.rangeEnd,
    required List<HabitHistoryDay> days,
    required List<Habit> habits,
  }) : days = List<HabitHistoryDay>.unmodifiable(days),
       habits = List<Habit>.unmodifiable(habits);

  final DateTime rangeStart;
  final DateTime rangeEnd;
  final List<HabitHistoryDay> days;
  final List<Habit> habits;

  int get totalHabits => habits.length;
}

class GetHabitHistory {
  GetHabitHistory({
    required HabitsRepository habitsRepository,
    required HabitEntriesRepository entriesRepository,
  }) : _habitsRepository = habitsRepository,
       _entriesRepository = entriesRepository;

  final HabitsRepository _habitsRepository;
  final HabitEntriesRepository _entriesRepository;

  Future<HabitHistorySnapshot> call({
    required DateTime startDate,
    required DateTime endDate,
    String? habitId,
  }) async {
    final normalizedStart = DateHelpers.startOfDay(startDate);
    final normalizedEnd = DateHelpers.startOfDay(endDate);
    final effectiveStart = normalizedStart.isBefore(normalizedEnd)
        ? normalizedStart
        : normalizedEnd;
    final effectiveEnd = normalizedStart.isBefore(normalizedEnd)
        ? normalizedEnd
        : normalizedStart;

    final habits = await _habitsRepository.fetchHabits();
    final habitMap = {for (final habit in habits) habit.id: habit};
    final selectedHabit = habitId != null ? habitMap[habitId] : null;
    final relevantHabits = habitId != null
        ? <Habit>[if (selectedHabit != null) selectedHabit]
        : habits;

    final entries = await _entriesRepository.fetchEntriesInRange(
      effectiveStart,
      effectiveEnd,
      habitId: habitId,
    );

    final entriesByHabit = <String, Map<DateTime, HabitEntry>>{};
    for (final entry in entries) {
      final entryDate = DateHelpers.startOfDay(entry.date);
      final habitEntries = entriesByHabit.putIfAbsent(entry.habitId, () => {});
      habitEntries[entryDate] = entry;
    }

    final creationDates = <String, DateTime>{
      for (final habit in habits)
        habit.id: _resolveCreationDate(
          habit,
          entriesByHabit[habit.id]?.keys,
          effectiveStart,
        ),
    };

    final days = <HabitHistoryDay>[];
    for (final date in DateHelpers.daysInRange(effectiveStart, effectiveEnd)) {
      final dayHabits = habitId == null
          ? _filterHabitsForDate(habits, date, creationDates)
          : relevantHabits
                .where(
                  (habit) => !_createdAfterDate(habit.id, date, creationDates),
                )
                .toList(growable: false);
      final items = <HabitHistoryItem>[];
      for (final habit in dayHabits) {
        if (_createdAfterDate(habit.id, date, creationDates)) {
          continue;
        }
        final entry = entriesByHabit[habit.id]?[DateHelpers.startOfDay(date)];
        items.add(HabitHistoryItem(habit: habit, date: date, entry: entry));
      }
      days.add(HabitHistoryDay(date: date, items: items));
    }

    return HabitHistorySnapshot(
      rangeStart: effectiveStart,
      rangeEnd: effectiveEnd,
      days: days,
      habits: habits,
    );
  }

  List<Habit> _filterHabitsForDate(
    List<Habit> habits,
    DateTime date,
    Map<String, DateTime> creationDates,
  ) {
    if (habits.isEmpty) {
      return const <Habit>[];
    }
    final weekday = DateHelpers.weekdayIndex(date);
    final normalizedDate = DateHelpers.startOfDay(date);
    final filtered = habits
        .where(
          (habit) =>
              (habit.days.isEmpty || habit.days.contains(weekday)) &&
              !_createdAfterDate(habit.id, normalizedDate, creationDates),
        )
        .toList(growable: false);
    if (filtered.length <= HabitsRepository.maxHabitsPerDay) {
      return filtered;
    }
    return filtered
        .take(HabitsRepository.maxHabitsPerDay)
        .toList(growable: false);
  }

  DateTime _resolveCreationDate(
    Habit habit,
    Iterable<DateTime>? entryDates,
    DateTime fallback,
  ) {
    final normalizedCreation = DateHelpers.startOfDay(habit.createdAt);
    var effective = normalizedCreation;

    final normalizedEntries = entryDates == null
        ? const <DateTime>[]
        : entryDates.map(DateHelpers.startOfDay);
    final earliestEntry = normalizedEntries.isEmpty
        ? null
        : normalizedEntries.reduce(
            (previous, element) =>
                element.isBefore(previous) ? element : previous,
          );

    if (!habit.hasExplicitCreationDate && earliestEntry != null) {
      effective = earliestEntry;
    }

    if (!habit.hasExplicitCreationDate && earliestEntry == null) {
      effective = fallback;
    }

    if (earliestEntry != null && earliestEntry.isBefore(effective)) {
      effective = earliestEntry;
    }

    return effective;
  }

  bool _createdAfterDate(
    String habitId,
    DateTime date,
    Map<String, DateTime> creationDates,
  ) {
    final created = creationDates[habitId];
    if (created == null) {
      return false;
    }
    final target = DateHelpers.startOfDay(date);
    return created.isAfter(target);
  }
}

final getHabitHistoryProvider = Provider<GetHabitHistory>((ref) {
  final habitsRepository = ref.watch(habitsRepositoryProvider);
  final entriesRepository = ref.watch(habitEntriesRepositoryProvider);
  return GetHabitHistory(
    habitsRepository: habitsRepository,
    entriesRepository: entriesRepository,
  );
});

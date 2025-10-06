import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../../../../core/database/habit_database.dart';
import '../../../../core/utils/date_helpers.dart';
import '../../domain/domain.dart';
import '../models/habit_record.dart';

class HabitsRepository {
  HabitsRepository(this._database);

  final HabitDatabase _database;
  static const int maxHabitsPerDay = 3;

  Future<List<Habit>> fetchHabits() async {
    final box = _database.habitsBox;
    return _mapHabits(box);
  }

  Future<int> countHabits() async {
    final box = _database.habitsBox;
    return box.length;
  }

  Future<List<Habit>> getTodayHabits(DateTime date) async {
    final habits = await fetchHabits();
    final normalized = DateHelpers.startOfDay(date);
    return _filterHabitsForDate(habits, normalized);
  }

  Future<Habit?> findById(String id) async {
    final box = _database.habitsBox;
    final record = box.get(id);
    return record?.toHabit();
  }

  Future<void> saveHabit(Habit habit) async {
    final box = _database.habitsBox;
    final record = HabitRecord.fromHabit(habit);
    await box.put(record.id, record);
  }

  Future<void> deleteHabit(String id) async {
    final box = _database.habitsBox;
    await box.delete(id);
  }

  Stream<List<Habit>> watchHabits() {
    final box = _database.habitsBox;
    StreamSubscription<BoxEvent>? subscription;
    late final StreamController<List<Habit>> controller;

    void emitSnapshot() {
      if (!controller.isClosed) {
        controller.add(_mapHabits(box));
      }
    }

    controller = StreamController<List<Habit>>.broadcast(
      onListen: () {
        emitSnapshot();
        subscription = box.watch().listen((_) => emitSnapshot());
      },
      onCancel: () async {
        await subscription?.cancel();
        subscription = null;
      },
    );

    return controller.stream;
  }

  Stream<List<Habit>> watchTodayHabits(DateTime date) {
    final normalizedDate = DateHelpers.startOfDay(date);
    return watchHabits().map(
      (habits) => _filterHabitsForDate(habits, normalizedDate),
    );
  }

  List<Habit> _mapHabits(Box<HabitRecord> box) {
    return List<Habit>.unmodifiable(
      box.values.map((record) => record.toHabit()),
    );
  }

  List<Habit> _filterHabitsForDate(List<Habit> habits, DateTime date) {
    final dayIndex = DateHelpers.weekdayIndex(date);
    final filtered = habits
        .where((habit) {
          if (habit.days.isEmpty) {
            return true;
          }
          return habit.days.contains(dayIndex);
        })
        .toList(growable: false);
    if (filtered.length <= maxHabitsPerDay) {
      return filtered;
    }
    return filtered.take(maxHabitsPerDay).toList(growable: false);
  }
}

final habitsRepositoryProvider = Provider<HabitsRepository>((ref) {
  final database = ref.watch(habitDatabaseProvider);
  return HabitsRepository(database);
});

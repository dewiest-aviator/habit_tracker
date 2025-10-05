import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../../../../core/database/habit_database.dart';
import '../../domain/domain.dart';
import '../models/habit_record.dart';

class HabitsRepository {
  HabitsRepository(this._database);

  final HabitDatabase _database;

  Future<List<Habit>> fetchHabits() async {
    final box = _database.habitsBox;
    return _mapHabits(box);
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

  List<Habit> _mapHabits(Box<HabitRecord> box) {
    return List<Habit>.unmodifiable(
      box.values.map((record) => record.toHabit()),
    );
  }
}

final habitsRepositoryProvider = Provider<HabitsRepository>((ref) {
  final database = ref.watch(habitDatabaseProvider);
  return HabitsRepository(database);
});

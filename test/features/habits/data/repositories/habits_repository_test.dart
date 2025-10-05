import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:habit_tracker/core/database/habit_database.dart';
import 'package:habit_tracker/features/habits/data/repositories/habits_repository.dart';
import 'package:habit_tracker/features/habits/domain/domain.dart';

void main() {
  late Directory tempDir;
  late HabitDatabase database;
  late HabitsRepository repository;
  late HiveInterface hive;

  Habit buildHabit(int seed) {
    return Habit(
      id: 'habit_$seed',
      name: 'Habit $seed',
      emoji: '🔥',
      color: 0xFF000000 + seed,
      days: <int>[seed % 7],
      reminderId: 'reminder_$seed',
      reminderTime: '08:0$seed',
      bestStreak: seed,
      currentStreak: seed ~/ 2,
      lastChecked: null,
    );
  }

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('habit_db_test');
    hive = Hive;
    database = HabitDatabase(
      hive: hive,
      initializer: () async {
        hive.init(tempDir.path);
      },
    );
    await database.initialize();
    repository = HabitsRepository(database);
  });

  tearDown(() async {
    await database.close();
    await hive.deleteFromDisk();
    await tempDir.delete(recursive: true);
  });

  test('fetchHabits returns stored habits', () async {
    final habit = buildHabit(1);
    await repository.saveHabit(habit);

    final habits = await repository.fetchHabits();

    expect(habits, <Habit>[habit]);
  });

  test('findById returns the habit when it exists', () async {
    final habit = buildHabit(2);
    await repository.saveHabit(habit);

    final result = await repository.findById(habit.id);

    expect(result, habit);
  });

  test('findById returns null when habit does not exist', () async {
    final result = await repository.findById('missing');

    expect(result, isNull);
  });

  test('deleteHabit removes the habit from storage', () async {
    final habit = buildHabit(3);
    await repository.saveHabit(habit);

    await repository.deleteHabit(habit.id);

    final habits = await repository.fetchHabits();
    expect(habits, isEmpty);
  });

  test('watchHabits emits updates when habits change', () async {
    final habitA = buildHabit(4);
    final habitB = buildHabit(5);

    final expectation = expectLater(
      repository.watchHabits(),
      emitsInOrder(<Object?>[
        <Habit>[],
        <Habit>[habitA],
        <Habit>[habitA, habitB],
        <Habit>[habitB],
      ]),
    );

    await repository.saveHabit(habitA);
    await repository.saveHabit(habitB);
    await repository.deleteHabit(habitA.id);

    await expectation;
  });
}

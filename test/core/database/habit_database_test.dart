import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:habit_tracker/core/database/habit_database.dart';
import 'package:habit_tracker/features/habits/data/models/habit_entry_record.dart';
import 'package:habit_tracker/features/habits/data/models/habit_record.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit_entry.dart';

void main() {
  late Directory tempDir;
  late HabitDatabase database;

  Habit buildHabit() {
    return Habit(
      id: 'habit-123',
      name: 'Read',
      emoji: '📚',
      color: 0xFFAA00AA,
      days: [0, 1, 2],
      reminderId: 'rem-123',
      reminderTime: '20:30',
      bestStreak: 15,
      currentStreak: 4,
      lastChecked: DateTime(2024, 9, 23, 22, 5),
    );
  }

  HabitEntry buildEntry() {
    return HabitEntry(
      habitId: 'habit-123',
      date: DateTime(2024, 9, 24),
      done: true,
    );
  }

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('habit_database_test');
    Hive.init(tempDir.path);
    database = HabitDatabase(hive: Hive, initializer: () async {});
  });

  tearDown(() async {
    await database.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('initialize opens Hive boxes and registers adapters', () async {
    await database.initialize();

    expect(database.isInitialized, isTrue);
    expect(database.habitsBox.isOpen, isTrue);
    expect(database.habitEntriesBox.isOpen, isTrue);

    final habit = buildHabit();
    final record = HabitRecord.fromHabit(habit);
    await database.habitsBox.put(record.id, record);

    final restoredHabit = database.habitsBox.get(record.id);
    expect(restoredHabit?.toHabit(), habit);

    final entry = buildEntry();
    final entryRecord = HabitEntryRecord.fromHabitEntry(entry);
    await database.habitEntriesBox.put(entry.habitId, entryRecord);

    final restoredEntry = database.habitEntriesBox.get(entry.habitId);
    expect(restoredEntry?.toHabitEntry(), entry);
  });

  test('close releases resources and prevents access', () async {
    await database.initialize();
    await database.close();

    expect(database.isInitialized, isFalse);
    expect(() => database.habitsBox, throwsStateError);
    expect(() => database.habitEntriesBox, throwsStateError);
  });

  test('initialize is idempotent', () async {
    await database.initialize();
    await database.initialize();

    expect(database.isInitialized, isTrue);
  });
}

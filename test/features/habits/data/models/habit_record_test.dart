import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:habit_tracker/features/habits/data/models/habit_record.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit.dart';

void main() {
  Habit buildHabit() {
    return Habit(
      id: 'habit-1',
      name: 'Drink Water',
      emoji: '💧',
      color: 0xFF00AAFF,
      days: [1, 3, 5],
      reminderId: 'reminder-1',
      reminderTime: '09:00',
      bestStreak: 7,
      currentStreak: 2,
      lastChecked: DateTime(2024, 10, 1),
    );
  }

  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('habit_record_test');
    Hive.init(tempDir.path);

    final adapter = HabitRecordAdapter();
    if (!Hive.isAdapterRegistered(adapter.typeId)) {
      Hive.registerAdapter(adapter);
    }
  });

  tearDown(() async {
    await Hive.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('fromHabit and toHabit round trip preserves values', () {
    final habit = buildHabit();
    final record = HabitRecord.fromHabit(habit);

    expect(record.toHabit(), habit);
  });

  test('adapter stores and restores record in Hive box', () async {
    final box = await Hive.openBox<HabitRecord>('habits_test');

    final habit = buildHabit();
    final record = HabitRecord.fromHabit(habit);

    await box.put(record.id, record);
    final restored = box.get(record.id);

    expect(restored, record);
    expect(restored?.toHabit(), habit);

    await box.close();
  });
}

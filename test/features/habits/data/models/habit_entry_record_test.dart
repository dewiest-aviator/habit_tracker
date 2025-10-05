import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:habit_tracker/features/habits/data/models/habit_entry_record.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit_entry.dart';

void main() {
  HabitEntry buildEntry() {
    return HabitEntry(
      habitId: 'habit-1',
      date: DateTime(2024, 10, 2),
      done: true,
    );
  }

  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('habit_entry_record_test');
    Hive.init(tempDir.path);

    final adapter = HabitEntryRecordAdapter();
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

  test('fromHabitEntry and toHabitEntry round trip', () {
    final entry = buildEntry();
    final record = HabitEntryRecord.fromHabitEntry(entry);

    expect(record.toHabitEntry(), entry);
  });

  test('adapter persists entry in Hive box', () async {
    final box = await Hive.openBox<HabitEntryRecord>('habit_entries_test');

    final entry = buildEntry();
    final record = HabitEntryRecord.fromHabitEntry(entry);

    await box.put('${entry.habitId}-${entry.date.toIso8601String()}', record);
    final restored = box.get(
      '${entry.habitId}-${entry.date.toIso8601String()}',
    );

    expect(restored, record);
    expect(restored?.toHabitEntry(), entry);

    await box.close();
  });
}

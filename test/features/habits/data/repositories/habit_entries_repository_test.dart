import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:habit_tracker/core/database/habit_database.dart';
import 'package:habit_tracker/features/habits/data/repositories/habit_entries_repository.dart';
import 'package:habit_tracker/features/habits/domain/domain.dart';

void main() {
  late Directory tempDir;
  late HabitDatabase database;
  late HabitEntriesRepository repository;
  late HiveInterface hive;

  HabitEntry buildEntry(String habitId, DateTime date, {bool done = true}) {
    return HabitEntry(habitId: habitId, date: date, done: done);
  }

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('habit_entries_db_test');
    hive = Hive;
    database = HabitDatabase(
      hive: hive,
      initializer: () async {
        hive.init(tempDir.path);
      },
    );
    await database.initialize();
    repository = HabitEntriesRepository(database);
  });

  tearDown(() async {
    await database.close();
    await hive.deleteFromDisk();
    await tempDir.delete(recursive: true);
  });

  test('saveEntry stores the entry and fetchEntries returns it', () async {
    final entry = buildEntry('habit_a', DateTime(2024, 1, 1));

    await repository.saveEntry(entry);

    final entries = await repository.fetchEntries(habitId: 'habit_a');

    expect(entries, <HabitEntry>[entry]);
  });

  test('fetchEntries sorts entries by date ascending', () async {
    final entryOlder = buildEntry('habit_a', DateTime(2024, 1, 1));
    final entryNewer = buildEntry('habit_a', DateTime(2024, 1, 2));

    await repository.saveEntry(entryNewer);
    await repository.saveEntry(entryOlder);

    final entries = await repository.fetchEntries(habitId: 'habit_a');

    expect(entries, <HabitEntry>[entryOlder, entryNewer]);
  });

  test('findEntry returns the entry when present', () async {
    final entry = buildEntry('habit_a', DateTime(2024, 2, 10));
    await repository.saveEntry(entry);

    final result = await repository.findEntry(entry.habitId, entry.date);

    expect(result, entry);
  });

  test('findEntry returns null when entry is missing', () async {
    final result = await repository.findEntry('habit_a', DateTime(2024, 2, 10));

    expect(result, isNull);
  });

  test('deleteEntry removes the stored entry', () async {
    final entry = buildEntry('habit_a', DateTime(2024, 3, 1));
    await repository.saveEntry(entry);

    await repository.deleteEntry(entry.habitId, entry.date);

    final entries = await repository.fetchEntries(habitId: 'habit_a');
    expect(entries, isEmpty);
  });

  test('deleteEntriesForHabit removes only matching entries', () async {
    final entryA1 = buildEntry('habit_a', DateTime(2024, 4, 1));
    final entryA2 = buildEntry('habit_a', DateTime(2024, 4, 2));
    final entryB = buildEntry('habit_b', DateTime(2024, 4, 1));

    await repository.saveEntry(entryA1);
    await repository.saveEntry(entryA2);
    await repository.saveEntry(entryB);

    await repository.deleteEntriesForHabit('habit_a');

    final entriesA = await repository.fetchEntries(habitId: 'habit_a');
    final entriesB = await repository.fetchEntries(habitId: 'habit_b');

    expect(entriesA, isEmpty);
    expect(entriesB, <HabitEntry>[entryB]);
  });

  test('watchEntries emits updates for the specified habit', () async {
    final entryA = buildEntry('habit_watch', DateTime(2024, 5, 1));
    final entryB = buildEntry('habit_watch', DateTime(2024, 5, 2));

    final expectation = expectLater(
      repository.watchEntries(habitId: 'habit_watch'),
      emitsInOrder(<Object?>[
        <HabitEntry>[],
        <HabitEntry>[entryA],
        <HabitEntry>[entryA, entryB],
        <HabitEntry>[entryB],
      ]),
    );

    await repository.saveEntry(entryA);
    await repository.saveEntry(entryB);
    await repository.deleteEntry(entryA.habitId, entryA.date);

    await expectation;
  });
}

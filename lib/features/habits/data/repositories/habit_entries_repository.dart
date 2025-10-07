import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../../../../core/database/habit_database.dart';
import '../../../../core/utils/date_helpers.dart';
import '../../domain/domain.dart';
import '../models/habit_entry_record.dart';

class HabitEntriesRepository {
  HabitEntriesRepository(this._database);

  final HabitDatabase _database;

  Future<HabitEntry?> findEntry(String habitId, DateTime date) async {
    final box = _database.habitEntriesBox;
    final record = box.get(_entryKey(habitId, date));
    return record?.toHabitEntry();
  }

  Future<List<HabitEntry>> fetchEntries({String? habitId}) async {
    final box = _database.habitEntriesBox;
    return _mapEntries(box, habitId: habitId);
  }

  Future<List<HabitEntry>> fetchEntriesForDate(DateTime date) async {
    final entries = await fetchEntries();
    final normalized = DateHelpers.startOfDay(date);
    return entries
        .where((entry) => DateHelpers.isSameDay(entry.date, normalized))
        .toList(growable: false);
  }

  Future<List<HabitEntry>> fetchEntriesInRange(
    DateTime start,
    DateTime end, {
    String? habitId,
  }) async {
    final normalizedStart = DateHelpers.startOfDay(start);
    final normalizedEnd = DateHelpers.startOfDay(end);
    final entries = await fetchEntries(habitId: habitId);
    return entries
        .where((entry) {
          final entryDate = DateHelpers.startOfDay(entry.date);
          return !entryDate.isBefore(normalizedStart) &&
              !entryDate.isAfter(normalizedEnd);
        })
        .toList(growable: false);
  }

  Future<void> saveEntry(HabitEntry entry) async {
    final box = _database.habitEntriesBox;
    final record = HabitEntryRecord.fromHabitEntry(entry);
    await box.put(_entryKey(entry.habitId, entry.date), record);
  }

  Future<void> deleteEntry(String habitId, DateTime date) async {
    final box = _database.habitEntriesBox;
    await box.delete(_entryKey(habitId, date));
  }

  Future<void> deleteEntriesForHabit(String habitId) async {
    final box = _database.habitEntriesBox;
    final keysToRemove = box.keys
        .where((key) {
          return key is String && key.startsWith(_habitPrefix(habitId));
        })
        .toList(growable: false);
    await box.deleteAll(keysToRemove);
  }

  Stream<List<HabitEntry>> watchEntries({String? habitId}) {
    final box = _database.habitEntriesBox;
    StreamSubscription<BoxEvent>? subscription;
    late final StreamController<List<HabitEntry>> controller;

    void emitSnapshot() {
      if (!controller.isClosed) {
        controller.add(_mapEntries(box, habitId: habitId));
      }
    }

    controller = StreamController<List<HabitEntry>>.broadcast(
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

  Stream<List<HabitEntry>> watchEntriesForDate(DateTime date) {
    final normalized = DateHelpers.startOfDay(date);
    return watchEntries().map(
      (entries) => entries
          .where((entry) => DateHelpers.isSameDay(entry.date, normalized))
          .toList(growable: false),
    );
  }

  Stream<List<HabitEntry>> watchEntriesInRange(
    DateTime start,
    DateTime end, {
    String? habitId,
  }) {
    final normalizedStart = DateHelpers.startOfDay(start);
    final normalizedEnd = DateHelpers.startOfDay(end);
    return watchEntries(habitId: habitId).map(
      (entries) => entries
          .where((entry) {
            final entryDate = DateHelpers.startOfDay(entry.date);
            return !entryDate.isBefore(normalizedStart) &&
                !entryDate.isAfter(normalizedEnd);
          })
          .toList(growable: false),
    );
  }

  List<HabitEntry> _mapEntries(Box<HabitEntryRecord> box, {String? habitId}) {
    final entries =
        box.values
            .where((record) => habitId == null || record.habitId == habitId)
            .map((record) => record.toHabitEntry())
            .toList(growable: false)
          ..sort((a, b) => a.date.compareTo(b.date));
    return List<HabitEntry>.unmodifiable(entries);
  }

  static String _entryKey(String habitId, DateTime date) {
    return '${_habitPrefix(habitId)}${date.toIso8601String()}';
  }

  static String _habitPrefix(String habitId) => '$habitId|';
}

final habitEntriesRepositoryProvider = Provider<HabitEntriesRepository>((ref) {
  final database = ref.watch(habitDatabaseProvider);
  return HabitEntriesRepository(database);
});

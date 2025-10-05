import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../features/habits/data/models/habit_entry_record.dart';
import '../../features/habits/data/models/habit_record.dart';

class HabitDatabase {
  HabitDatabase({HiveInterface? hive, Future<void> Function()? initializer})
    : _hive = hive ?? Hive,
      _initializer = initializer ?? Hive.initFlutter;

  static const String habitsBoxName = 'habits';
  static const String habitEntriesBoxName = 'habit_entries';

  final HiveInterface _hive;
  final Future<void> Function() _initializer;

  bool _initialized = false;
  bool _initializerRan = false;

  bool get isInitialized => _initialized;

  Future<void> initialize() async {
    if (_initialized) return;

    if (!_initializerRan) {
      await _initializer();
      _initializerRan = true;
    }

    _registerAdapters();

    await Future.wait([
      _hive.openBox<HabitRecord>(habitsBoxName),
      _hive.openBox<HabitEntryRecord>(habitEntriesBoxName),
    ]);

    _initialized = true;
  }

  Future<void> close() async {
    if (!_initialized) return;

    await _hive.close();
    _initialized = false;
  }

  Box<HabitRecord> get habitsBox {
    _ensureInitialized();
    return _hive.box<HabitRecord>(habitsBoxName);
  }

  Box<HabitEntryRecord> get habitEntriesBox {
    _ensureInitialized();
    return _hive.box<HabitEntryRecord>(habitEntriesBoxName);
  }

  void _registerAdapters() {
    final habitAdapter = HabitRecordAdapter();
    if (!_hive.isAdapterRegistered(habitAdapter.typeId)) {
      _hive.registerAdapter(habitAdapter);
    }

    final entryAdapter = HabitEntryRecordAdapter();
    if (!_hive.isAdapterRegistered(entryAdapter.typeId)) {
      _hive.registerAdapter(entryAdapter);
    }
  }

  void _ensureInitialized() {
    if (!_initialized) {
      throw StateError('HabitDatabase.initialize() must be called before use.');
    }
  }
}

final habitDatabaseProvider = Provider<HabitDatabase>((ref) {
  throw UnimplementedError('habitDatabaseProvider must be overridden');
});

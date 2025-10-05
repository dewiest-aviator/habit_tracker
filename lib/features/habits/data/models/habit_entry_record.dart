import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import '../../domain/domain.dart';

@immutable
class HabitEntryRecord {
  const HabitEntryRecord({
    required this.habitId,
    required this.date,
    required this.done,
  });

  final String habitId;
  final DateTime date;
  final bool done;

  HabitEntry toHabitEntry() {
    return HabitEntry(habitId: habitId, date: date, done: done);
  }

  factory HabitEntryRecord.fromHabitEntry(HabitEntry entry) {
    return HabitEntryRecord(
      habitId: entry.habitId,
      date: entry.date,
      done: entry.done,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HabitEntryRecord &&
        other.habitId == habitId &&
        other.date == date &&
        other.done == done;
  }

  @override
  int get hashCode => Object.hash(habitId, date, done);

  @override
  String toString() =>
      'HabitEntryRecord(habitId: $habitId, date: $date, done: $done)';
}

class HabitEntryRecordAdapter extends TypeAdapter<HabitEntryRecord> {
  @override
  final int typeId = 2;

  @override
  HabitEntryRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    return HabitEntryRecord(
      habitId: fields[0] as String,
      date: fields[1] as DateTime,
      done: fields[2] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, HabitEntryRecord obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.habitId)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.done);
  }
}

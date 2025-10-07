import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import '../../domain/domain.dart';

@immutable
class HabitRecord {
  HabitRecord({
    required this.id,
    required this.name,
    required this.emoji,
    required this.color,
    required List<int> days,
    required this.reminderId,
    required this.reminderTime,
    required this.bestStreak,
    required this.currentStreak,
    this.lastChecked,
    required this.createdAt,
  }) : days = List<int>.unmodifiable(List<int>.from(days));

  final String id;
  final String name;
  final String emoji;
  final int color;
  final List<int> days;
  final String reminderId;
  final String reminderTime;
  final int bestStreak;
  final int currentStreak;
  final DateTime? lastChecked;
  final DateTime createdAt;

  Habit toHabit() {
    return Habit(
      id: id,
      name: name,
      emoji: emoji,
      color: color,
      days: List<int>.from(days),
      reminderId: reminderId,
      reminderTime: reminderTime,
      bestStreak: bestStreak,
      currentStreak: currentStreak,
      createdAt: createdAt,
      lastChecked: lastChecked,
    );
  }

  factory HabitRecord.fromHabit(Habit habit) {
    return HabitRecord(
      id: habit.id,
      name: habit.name,
      emoji: habit.emoji,
      color: habit.color,
      days: habit.days,
      reminderId: habit.reminderId,
      reminderTime: habit.reminderTime,
      bestStreak: habit.bestStreak,
      currentStreak: habit.currentStreak,
      lastChecked: habit.lastChecked,
      createdAt: habit.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HabitRecord &&
        other.id == id &&
        other.name == name &&
        other.emoji == emoji &&
        other.color == color &&
        listEquals(other.days, days) &&
        other.reminderId == reminderId &&
        other.reminderTime == reminderTime &&
        other.bestStreak == bestStreak &&
        other.currentStreak == currentStreak &&
        other.lastChecked == lastChecked &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    emoji,
    color,
    Object.hashAll(days),
    reminderId,
    reminderTime,
    bestStreak,
    currentStreak,
    lastChecked,
    createdAt,
  );

  @override
  String toString() {
    return 'HabitRecord(id: $id, name: $name, streak: $currentStreak/$bestStreak, createdAt: $createdAt)';
  }
}

class HabitRecordAdapter extends TypeAdapter<HabitRecord> {
  @override
  final int typeId = 1;

  @override
  HabitRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    return HabitRecord(
      id: fields[0] as String,
      name: fields[1] as String,
      emoji: fields[2] as String,
      color: fields[3] as int,
      days: (fields[4] as List).cast<int>(),
      reminderId: fields[5] as String,
      reminderTime: fields[6] as String,
      bestStreak: fields[7] as int,
      currentStreak: fields[8] as int,
      lastChecked: fields[9] as DateTime?,
      createdAt:
          (fields[10] as DateTime?) ?? DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  @override
  void write(BinaryWriter writer, HabitRecord obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.emoji)
      ..writeByte(3)
      ..write(obj.color)
      ..writeByte(4)
      ..write(obj.days)
      ..writeByte(5)
      ..write(obj.reminderId)
      ..writeByte(6)
      ..write(obj.reminderTime)
      ..writeByte(7)
      ..write(obj.bestStreak)
      ..writeByte(8)
      ..write(obj.currentStreak)
      ..writeByte(9)
      ..write(obj.lastChecked)
      ..writeByte(10)
      ..write(obj.createdAt);
  }
}

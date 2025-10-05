import 'package:flutter/foundation.dart';

@immutable
class HabitEntry {
  const HabitEntry({
    required this.habitId,
    required this.date,
    required this.done,
  });

  final String habitId;
  final DateTime date;
  final bool done;

  HabitEntry copyWith({String? habitId, DateTime? date, bool? done}) {
    return HabitEntry(
      habitId: habitId ?? this.habitId,
      date: date ?? this.date,
      done: done ?? this.done,
    );
  }

  Map<String, Object?> toMap() {
    return {'habitId': habitId, 'date': date.toIso8601String(), 'done': done};
  }

  static HabitEntry fromMap(Map<String, Object?> map) {
    final habitId = map['habitId'] as String?;
    final dateString = map['date'] as String?;
    final done = map['done'] as bool?;

    if (habitId == null || dateString == null || done == null) {
      throw ArgumentError('Missing required HabitEntry fields');
    }

    final parsedDate = DateTime.tryParse(dateString);
    if (parsedDate == null) {
      throw ArgumentError.value(dateString, 'date', 'Invalid ISO date string');
    }

    return HabitEntry(habitId: habitId, date: parsedDate, done: done);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HabitEntry &&
        other.habitId == habitId &&
        other.date == date &&
        other.done == done;
  }

  @override
  int get hashCode => Object.hash(habitId, date, done);

  @override
  String toString() =>
      'HabitEntry(habitId: $habitId, date: $date, done: $done)';
}

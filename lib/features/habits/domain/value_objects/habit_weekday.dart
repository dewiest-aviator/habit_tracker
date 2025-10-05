import 'dart:collection';

import 'package:flutter/foundation.dart';

/// Represents a weekday in the habit recurrence schedule.
///
/// The [index] value follows ISO weekday ordering where Monday = 0 and
/// Sunday = 6. Persist the index to keep storage lightweight.
@immutable
class HabitWeekday {
  const HabitWeekday._(this.index, this.label);

  final int index;
  final String label;

  static const monday = HabitWeekday._(0, 'Monday');
  static const tuesday = HabitWeekday._(1, 'Tuesday');
  static const wednesday = HabitWeekday._(2, 'Wednesday');
  static const thursday = HabitWeekday._(3, 'Thursday');
  static const friday = HabitWeekday._(4, 'Friday');
  static const saturday = HabitWeekday._(5, 'Saturday');
  static const sunday = HabitWeekday._(6, 'Sunday');

  static const values = <HabitWeekday>[
    monday,
    tuesday,
    wednesday,
    thursday,
    friday,
    saturday,
    sunday,
  ];

  static HabitWeekday fromIndex(int index) {
    return values.firstWhere(
      (day) => day.index == index,
      orElse: () =>
          throw ArgumentError.value(index, 'index', 'Unknown weekday'),
    );
  }

  static UnmodifiableListView<int> toIndexList(
    Iterable<HabitWeekday> weekdays,
  ) {
    final sorted = weekdays.map((day) => day.index).toSet().toList()..sort();
    return UnmodifiableListView(sorted);
  }

  static List<HabitWeekday> fromIndexList(Iterable<int> indexes) {
    final unique = indexes.toSet().toList()..sort();
    return unique.map(fromIndex).toList();
  }

  @override
  String toString() => label;
}

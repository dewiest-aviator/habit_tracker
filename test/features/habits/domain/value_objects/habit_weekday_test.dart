import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/features/habits/domain/value_objects/habit_weekday.dart';

void main() {
  test('fromIndex returns correct weekday', () {
    expect(HabitWeekday.fromIndex(0), HabitWeekday.monday);
    expect(HabitWeekday.fromIndex(6), HabitWeekday.sunday);
  });

  test('toIndexList produces sorted unique values', () {
    final indexes = HabitWeekday.toIndexList([
      HabitWeekday.friday,
      HabitWeekday.monday,
      HabitWeekday.friday,
    ]);

    expect(indexes, [0, 4]);
  });

  test('fromIndexList discards invalids and preserves order', () {
    final weekdays = HabitWeekday.fromIndexList([4, 2, 2, 1]);

    expect(weekdays, [
      HabitWeekday.tuesday,
      HabitWeekday.wednesday,
      HabitWeekday.friday,
    ]);
  });
}

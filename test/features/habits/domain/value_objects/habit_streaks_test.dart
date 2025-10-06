import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/features/habits/domain/value_objects/habit_streaks.dart';

void main() {
  test('copyWith preserves existing values by default', () {
    const streaks = HabitStreaks(current: 2, best: 5);
    final updated = streaks.copyWith(best: 6);

    expect(updated.current, 2);
    expect(updated.best, 6);
  });

  test('supports equality comparison', () {
    const first = HabitStreaks(current: 1, best: 3);
    const second = HabitStreaks(current: 1, best: 3);

    expect(first, equals(second));
    expect(first.hashCode, equals(second.hashCode));
    expect(first.toString(), contains('current: 1'));
  });
}

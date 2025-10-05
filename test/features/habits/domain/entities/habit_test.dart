import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit.dart';

void main() {
  Habit buildHabit() {
    return Habit(
      id: 'habit-1',
      name: 'Morning Run',
      emoji: '🏃',
      color: 0xFFAA5500,
      days: [0, 2, 4],
      reminderId: 'rem-1',
      reminderTime: '07:30',
      bestStreak: 10,
      currentStreak: 3,
      lastChecked: null,
    );
  }

  test('copyWith updates provided values only', () {
    final habit = buildHabit();
    final updated = habit.copyWith(name: 'Evening Run', days: [1, 3]);

    expect(updated.name, 'Evening Run');
    expect(updated.days, [1, 3]);
    expect(updated.color, habit.color);
  });

  test('toMap and fromMap roundtrip', () {
    final habit = buildHabit().copyWith(lastChecked: DateTime(2024, 10, 5));

    final map = habit.toMap();
    final restored = Habit.fromMap(map);

    expect(restored, habit);
  });

  test('fromMap throws on missing fields', () {
    expect(() => Habit.fromMap({'name': 'oops'}), throwsArgumentError);
  });
}

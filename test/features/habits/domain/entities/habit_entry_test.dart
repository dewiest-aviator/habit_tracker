import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit_entry.dart';

void main() {
  test('copyWith updates desired fields', () {
    final entry = HabitEntry(
      habitId: 'habit-1',
      date: DateTime(2024, 10, 5),
      done: false,
    );

    final updated = entry.copyWith(done: true);
    expect(updated.done, isTrue);
    expect(updated.habitId, entry.habitId);
  });

  test('toMap and fromMap roundtrip', () {
    final entry = HabitEntry(
      habitId: 'habit-1',
      date: DateTime(2024, 10, 5),
      done: true,
    );

    final restored = HabitEntry.fromMap(entry.toMap());
    expect(restored, entry);
  });

  test('fromMap throws for invalid payloads', () {
    expect(
      () => HabitEntry.fromMap({'habitId': 'missing fields'}),
      throwsArgumentError,
    );
  });
}

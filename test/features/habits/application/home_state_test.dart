import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/features/habits/application/home_state.dart';
import 'package:habit_tracker/features/habits/domain/domain.dart';

void main() {
  group('HomeHabitViewData', () {
    test('supports value equality and copyWith', () {
      final view = HomeHabitViewData(habit: nullHabit, isCompleted: false);
      final updated = view.copyWith(isCompleted: true);

      expect(updated.habit, nullHabit);
      expect(updated.isCompleted, isTrue);
      expect(updated, updated.copyWith());
    });
  });

  group('HomeState', () {
    test('initial factory sets loading state', () {
      final state = HomeState.initial(DateTime(2024, 1, 1));

      expect(state.isLoading, isTrue);
      expect(state.habits, isEmpty);
      expect(state.currentDate, DateTime(2024, 1, 1));
    });

    test('computed properties reflect habits state', () {
      final state = HomeState(
        habits: [
          HomeHabitViewData(habit: nullHabit, isCompleted: true),
          HomeHabitViewData(habit: nullHabit, isCompleted: false),
        ],
        currentDate: DateTime(2024, 6, 10),
        isLoading: false,
      );

      expect(state.completedCount, 1);
      expect(state.canAddHabit, isTrue);
      expect(state.isEmpty, isFalse);
    });

    test('copyWith updates fields and clears errors when requested', () {
      final base = HomeState(
        habits: [HomeHabitViewData(habit: nullHabit, isCompleted: false)],
        currentDate: DateTime(2024, 6, 10),
        isLoading: false,
        errorMessage: 'error',
      );

      final updated = base.copyWith(
        habits: [HomeHabitViewData(habit: nullHabit, isCompleted: true)],
        isLoading: true,
        clearError: true,
      );

      expect(updated.habits.first.isCompleted, isTrue);
      expect(updated.isLoading, isTrue);
      expect(updated.errorMessage, isNull);
    });

    test('isEmpty is true when not loading and no habits', () {
      final state = HomeState(
        habits: const [],
        currentDate: DateTime(2024, 6, 10),
        isLoading: false,
      );

      expect(state.isEmpty, isTrue);
    });
  });
}

final nullHabit = Habit(
  id: 'habit-1',
  name: 'Meditate',
  emoji: '🧘',
  color: 0xFF123456,
  days: const [0, 1, 2, 3, 4, 5, 6],
  reminderId: 'reminder',
  reminderTime: '07:00',
  bestStreak: 5,
  currentStreak: 2,
);

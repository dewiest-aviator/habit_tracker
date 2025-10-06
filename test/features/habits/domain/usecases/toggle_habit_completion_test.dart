import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/features/habits/data/repositories/habit_entries_repository.dart';
import 'package:habit_tracker/features/habits/data/repositories/habits_repository.dart';
import 'package:habit_tracker/features/habits/domain/domain.dart';
import 'package:habit_tracker/features/habits/domain/usecases/compute_streaks.dart';
import 'package:habit_tracker/features/habits/domain/usecases/toggle_habit_completion.dart';
import 'package:mocktail/mocktail.dart';

class _MockHabitsRepository extends Mock implements HabitsRepository {}

class _MockEntriesRepository extends Mock implements HabitEntriesRepository {}

class _MockComputeStreaks extends Mock implements ComputeStreaks {}

void main() {
  late _MockHabitsRepository habitsRepository;
  late _MockEntriesRepository entriesRepository;
  late _MockComputeStreaks computeStreaks;
  late ToggleHabitCompletion toggleHabitCompletion;
  late Habit habit;

  setUpAll(() {
    registerFallbackValue(
      Habit(
        id: 'habit',
        name: 'Read',
        emoji: '📚',
        color: 0xFF123456,
        days: const [0, 1, 2, 3, 4, 5, 6],
        reminderId: 'reminder',
        reminderTime: '08:00',
        bestStreak: 0,
        currentStreak: 0,
      ),
    );
    registerFallbackValue(
      HabitEntry(habitId: 'habit', date: DateTime(2024), done: true),
    );
  });

  setUp(() {
    habitsRepository = _MockHabitsRepository();
    entriesRepository = _MockEntriesRepository();
    computeStreaks = _MockComputeStreaks();
    toggleHabitCompletion = ToggleHabitCompletion(
      habitsRepository: habitsRepository,
      entriesRepository: entriesRepository,
      computeStreaks: computeStreaks,
    );

    habit = Habit(
      id: 'habit',
      name: 'Read',
      emoji: '📚',
      color: 0xFF654321,
      days: const [0, 1, 2, 3, 4, 5, 6],
      reminderId: 'reminder',
      reminderTime: '21:00',
      bestStreak: 1,
      currentStreak: 1,
      lastChecked: DateTime(2024, 6, 9),
    );
  });

  test('throws when habit cannot be found', () async {
    when(() => habitsRepository.findById(any())).thenAnswer((_) async => null);

    await expectLater(
      () => toggleHabitCompletion(
        habitId: 'missing',
        date: DateTime(2024, 6, 10, 8),
      ),
      throwsStateError,
    );
  });

  test('completes a habit when no entry exists', () async {
    final date = DateTime(2024, 6, 10, 8, 30);
    when(
      () => habitsRepository.findById(habit.id),
    ).thenAnswer((_) async => habit);
    when(
      () => entriesRepository.findEntry(habit.id, any()),
    ).thenAnswer((_) async => null);
    when(() => entriesRepository.saveEntry(any())).thenAnswer((_) async {});
    when(
      () => entriesRepository.deleteEntry(any(), any()),
    ).thenAnswer((_) async {});
    when(() => habitsRepository.saveHabit(any())).thenAnswer((_) async {});
    when(
      () => computeStreaks.call(habit.id),
    ).thenAnswer((_) async => const HabitStreaks(current: 2, best: 5));

    final result = await toggleHabitCompletion(habitId: habit.id, date: date);

    expect(result.isCompleted, isTrue);
    expect(result.entry, isNotNull);
    expect(result.entry!.date, DateTime(2024, 6, 10));

    verify(() => entriesRepository.saveEntry(any())).called(1);

    final savedHabit =
        verify(() => habitsRepository.saveHabit(captureAny())).captured.single
            as Habit;
    expect(savedHabit.currentStreak, 2);
    expect(savedHabit.bestStreak, 5);
    expect(savedHabit.lastChecked, DateTime(2024, 6, 10));
  });

  test('undoes a habit when an entry already exists', () async {
    final date = DateTime(2024, 6, 10, 20);
    final entry = HabitEntry(
      habitId: habit.id,
      date: DateTime(2024, 6, 10, 6),
      done: true,
    );

    when(
      () => habitsRepository.findById(habit.id),
    ).thenAnswer((_) async => habit);
    when(
      () => entriesRepository.findEntry(habit.id, any()),
    ).thenAnswer((_) async => entry);
    when(
      () => entriesRepository.deleteEntry(habit.id, any()),
    ).thenAnswer((_) async {});
    when(() => habitsRepository.saveHabit(any())).thenAnswer((_) async {});
    when(
      () => computeStreaks.call(habit.id),
    ).thenAnswer((_) async => const HabitStreaks(current: 0, best: 3));

    final result = await toggleHabitCompletion(habitId: habit.id, date: date);

    expect(result.isCompleted, isFalse);
    expect(result.entry, isNull);

    verify(
      () => entriesRepository.deleteEntry(habit.id, DateTime(2024, 6, 10)),
    ).called(1);

    final savedHabit =
        verify(() => habitsRepository.saveHabit(captureAny())).captured.single
            as Habit;
    expect(savedHabit.currentStreak, 0);
    expect(savedHabit.bestStreak, 3);
    expect(savedHabit.lastChecked, isNull);
  });
}

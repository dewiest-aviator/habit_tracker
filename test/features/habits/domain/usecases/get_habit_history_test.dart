import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:habit_tracker/features/habits/data/repositories/habit_entries_repository.dart';
import 'package:habit_tracker/features/habits/data/repositories/habits_repository.dart';
import 'package:habit_tracker/features/habits/domain/domain.dart';
import 'package:habit_tracker/features/habits/domain/usecases/get_habit_history.dart';

class _MockHabitsRepository extends Mock implements HabitsRepository {}

class _MockHabitEntriesRepository extends Mock
    implements HabitEntriesRepository {}

void main() {
  late _MockHabitsRepository habitsRepository;
  late _MockHabitEntriesRepository entriesRepository;
  late GetHabitHistory usecase;
  late Habit habitA;
  late Habit habitB;
  late HabitEntry entryA;

  setUpAll(() {
    registerFallbackValue(DateTime(2024));
  });

  setUp(() {
    habitsRepository = _MockHabitsRepository();
    entriesRepository = _MockHabitEntriesRepository();
    usecase = GetHabitHistory(
      habitsRepository: habitsRepository,
      entriesRepository: entriesRepository,
    );

    habitA = Habit(
      id: 'habit-a',
      name: 'Read',
      emoji: '📚',
      color: 0xFF4F46E5,
      days: const [0, 1, 2, 3, 4, 5, 6],
      reminderId: '',
      reminderTime: '',
      bestStreak: 5,
      currentStreak: 2,
      createdAt: DateTime(2024, 6, 5),
    );
    habitB = Habit(
      id: 'habit-b',
      name: 'Meditate',
      emoji: '🧘',
      color: 0xFF22C55E,
      days: const [0, 2, 4],
      reminderId: '',
      reminderTime: '',
      bestStreak: 3,
      currentStreak: 1,
      createdAt: DateTime(2024, 6, 10),
    );

    entryA = HabitEntry(
      habitId: habitA.id,
      date: DateTime(2024, 6, 10),
      done: true,
    );
  });

  test('builds history snapshot for given range', () async {
    when(
      () => habitsRepository.fetchHabits(),
    ).thenAnswer((_) async => [habitA, habitB]);
    when(
      () => entriesRepository.fetchEntriesInRange(
        any(),
        any(),
        habitId: any(named: 'habitId'),
      ),
    ).thenAnswer((_) async => [entryA]);

    final snapshot = await usecase(
      startDate: DateTime(2024, 6, 9),
      endDate: DateTime(2024, 6, 11),
    );

    expect(snapshot.rangeStart, DateTime(2024, 6, 9));
    expect(snapshot.rangeEnd, DateTime(2024, 6, 11));
    expect(snapshot.days.length, 3);
    final targetDay = snapshot.days.firstWhere(
      (day) => day.date == DateTime(2024, 6, 10),
    );
    expect(targetDay.items.length, 2);
    final completed = targetDay.items
        .where((item) => item.isCompleted)
        .toList();
    expect(completed.length, 1);
    expect(completed.first.habit.id, habitA.id);

    final beforeCreation = snapshot.days.firstWhere(
      (day) => day.date == DateTime(2024, 6, 9),
    );
    expect(beforeCreation.items.length, 1);
    expect(beforeCreation.items.single.habit.id, habitA.id);
  });

  test('filters snapshot when habitId provided', () async {
    when(
      () => habitsRepository.fetchHabits(),
    ).thenAnswer((_) async => [habitA, habitB]);
    when(
      () => entriesRepository.fetchEntriesInRange(
        any(),
        any(),
        habitId: any(named: 'habitId'),
      ),
    ).thenAnswer((invocation) async {
      final habitId = invocation.namedArguments[#habitId] as String?;
      if (habitId == habitA.id) return [entryA];
      return const <HabitEntry>[];
    });

    final snapshot = await usecase(
      startDate: DateTime(2024, 6, 9),
      endDate: DateTime(2024, 6, 11),
      habitId: habitA.id,
    );

    expect(snapshot.days.length, 3);
    for (final day in snapshot.days) {
      expect(day.items.length, lessThanOrEqualTo(1));
      if (day.date == DateTime(2024, 6, 10)) {
        expect(day.items.single.isCompleted, isTrue);
      }
    }
  });

  test('excludes habits from days before they were created', () async {
    when(
      () => habitsRepository.fetchHabits(),
    ).thenAnswer((_) async => [habitA, habitB]);
    when(
      () => entriesRepository.fetchEntriesInRange(
        any(),
        any(),
        habitId: any(named: 'habitId'),
      ),
    ).thenAnswer((_) async => const <HabitEntry>[]);

    final snapshot = await usecase(
      startDate: DateTime(2024, 6, 8),
      endDate: DateTime(2024, 6, 11),
    );

    final beforeCreation = snapshot.days.firstWhere(
      (day) => day.date == DateTime(2024, 6, 8),
    );
    expect(beforeCreation.items.length, 1);
    expect(beforeCreation.items.single.habit.id, habitA.id);

    final creationDay = snapshot.days.firstWhere(
      (day) => day.date == DateTime(2024, 6, 10),
    );
    expect(
      creationDay.items.map((item) => item.habit.id),
      containsAll([habitA.id, habitB.id]),
    );
  });
}

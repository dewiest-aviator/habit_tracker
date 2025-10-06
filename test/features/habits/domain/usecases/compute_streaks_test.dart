import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/features/habits/data/repositories/habit_entries_repository.dart';
import 'package:habit_tracker/features/habits/domain/domain.dart';
import 'package:habit_tracker/features/habits/domain/usecases/compute_streaks.dart';
import 'package:mocktail/mocktail.dart';

class _MockHabitEntriesRepository extends Mock
    implements HabitEntriesRepository {}

void main() {
  late _MockHabitEntriesRepository repository;
  late ComputeStreaks useCase;

  setUp(() {
    repository = _MockHabitEntriesRepository();
    useCase = ComputeStreaks(
      habitEntriesRepository: repository,
      clock: () => DateTime(2024, 6, 10),
    );
  });

  test('returns zero streaks when there are no entries', () async {
    when(
      () => repository.fetchEntries(habitId: any(named: 'habitId')),
    ).thenAnswer((_) async => <HabitEntry>[]);

    final result = await useCase('habit');

    expect(result.current, 0);
    expect(result.best, 0);
  });

  test('computes current and best streaks', () async {
    final entries = <HabitEntry>[
      HabitEntry(habitId: 'habit', date: DateTime(2024, 6, 8), done: true),
      HabitEntry(habitId: 'habit', date: DateTime(2024, 6, 9), done: true),
      HabitEntry(habitId: 'habit', date: DateTime(2024, 6, 10), done: true),
      HabitEntry(habitId: 'habit', date: DateTime(2024, 5, 1), done: true),
      HabitEntry(habitId: 'habit', date: DateTime(2024, 5, 2), done: true),
      HabitEntry(habitId: 'habit', date: DateTime(2024, 5, 3), done: true),
      HabitEntry(habitId: 'habit', date: DateTime(2024, 5, 4), done: true),
    ];

    when(
      () => repository.fetchEntries(habitId: any(named: 'habitId')),
    ).thenAnswer((_) async => entries);

    final result = await useCase('habit');

    expect(result.current, 3);
    expect(result.best, 4);
  });
}

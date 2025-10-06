import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/features/habits/application/home_controller.dart';
import 'package:habit_tracker/features/habits/data/repositories/habit_entries_repository.dart';
import 'package:habit_tracker/features/habits/data/repositories/habits_repository.dart';
import 'package:habit_tracker/features/habits/domain/domain.dart';
import 'package:habit_tracker/features/habits/domain/usecases/toggle_habit_completion.dart';
import 'package:mocktail/mocktail.dart';

class _MockHabitsRepository extends Mock implements HabitsRepository {}

class _MockHabitEntriesRepository extends Mock
    implements HabitEntriesRepository {}

class _MockToggleHabitCompletion extends Mock
    implements ToggleHabitCompletion {}

void main() {
  late _MockHabitsRepository habitsRepository;
  late _MockHabitEntriesRepository habitEntriesRepository;
  late _MockToggleHabitCompletion toggleHabitCompletion;
  late StreamController<List<Habit>> habitsStream;
  late StreamController<List<HabitEntry>> entriesStream;
  late Habit habit;
  late HomeController controller;

  setUpAll(() {
    registerFallbackValue(DateTime(2024));
  });

  setUp(() {
    habitsRepository = _MockHabitsRepository();
    habitEntriesRepository = _MockHabitEntriesRepository();
    toggleHabitCompletion = _MockToggleHabitCompletion();
    habitsStream = StreamController<List<Habit>>.broadcast();
    entriesStream = StreamController<List<HabitEntry>>.broadcast();

    habit = Habit(
      id: 'habit-1',
      name: 'Read',
      emoji: '📚',
      color: 0xFF7E57C2,
      days: List<int>.generate(7, (index) => index),
      reminderId: 'reminder-1',
      reminderTime: '21:00',
      bestStreak: 0,
      currentStreak: 0,
    );

    when(
      () => habitsRepository.getTodayHabits(any()),
    ).thenAnswer((_) async => [habit]);
    when(
      () => habitsRepository.watchTodayHabits(any()),
    ).thenAnswer((_) => habitsStream.stream);
    when(
      () => habitEntriesRepository.fetchEntriesForDate(any()),
    ).thenAnswer((_) async => <HabitEntry>[]);
    when(
      () => habitEntriesRepository.watchEntriesForDate(any()),
    ).thenAnswer((_) => entriesStream.stream);

    controller = HomeController(
      habitsRepository: habitsRepository,
      habitEntriesRepository: habitEntriesRepository,
      toggleHabitCompletion: toggleHabitCompletion,
      clock: () => DateTime(2024, 6, 10, 8, 0),
      timerFactory: (duration, callback) =>
          Timer(const Duration(days: 1), () {}),
    );
  });

  tearDown(() async {
    controller.dispose();
    await habitsStream.close();
    await entriesStream.close();
  });

  test('loads today\'s habits on initialization', () async {
    habitsStream.add([habit]);
    entriesStream.add([]);

    await Future<void>.delayed(Duration.zero);

    expect(controller.state.isLoading, isFalse);
    expect(controller.state.habits, isNotEmpty);
    expect(controller.state.habits.first.habit, habit);
  });

  test('toggleHabit updates completion state and streaks', () async {
    habitsStream.add([habit]);
    entriesStream.add([]);
    await Future<void>.delayed(Duration.zero);

    final updatedHabit = habit.copyWith(currentStreak: 1, bestStreak: 2);
    final entry = HabitEntry(
      habitId: habit.id,
      date: DateTime(2024, 6, 10),
      done: true,
    );

    when(
      () => toggleHabitCompletion.call(
        habitId: habit.id,
        date: any(named: 'date'),
      ),
    ).thenAnswer(
      (_) async => ToggleHabitResult(habit: updatedHabit, entry: entry),
    );

    final result = await controller.toggleHabit(habit.id);
    expect(result, isTrue);

    final state = controller.state;
    expect(state.completedCount, 1);
    expect(state.habits.first.habit.currentStreak, 1);
    expect(state.habits.first.isCompleted, isTrue);
  });

  test('toggleHabit restores previous state when failing', () async {
    habitsStream.add([habit]);
    entriesStream.add([]);
    await Future<void>.delayed(Duration.zero);

    when(
      () => toggleHabitCompletion.call(
        habitId: habit.id,
        date: any(named: 'date'),
      ),
    ).thenThrow(Exception('failure'));

    final result = await controller.toggleHabit(habit.id);

    expect(result, isNull);
    expect(controller.state.habits.first.isCompleted, isFalse);
    expect(controller.state.errorMessage, contains('failure'));
  });
}

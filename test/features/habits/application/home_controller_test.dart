import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:habit_tracker/features/habits/application/home_controller.dart';
import 'package:habit_tracker/features/habits/application/home_state.dart';
import 'package:habit_tracker/features/habits/data/repositories/habit_entries_repository.dart';
import 'package:habit_tracker/features/habits/data/repositories/habits_repository.dart';
import 'package:habit_tracker/features/habits/domain/domain.dart';
import 'package:habit_tracker/features/habits/domain/usecases/toggle_habit_completion.dart';

class _MockHabitsRepository extends Mock implements HabitsRepository {}

class _MockHabitEntriesRepository extends Mock
    implements HabitEntriesRepository {}

class _MockToggleHabitCompletion extends Mock
    implements ToggleHabitCompletion {}

void main() {
  late ProviderContainer container;
  late _MockHabitsRepository habitsRepository;
  late _MockHabitEntriesRepository habitEntriesRepository;
  late _MockToggleHabitCompletion toggleHabitCompletion;
  late StreamController<List<Habit>> habitsStream;
  late StreamController<List<HabitEntry>> entriesStream;
  late Habit habit;
  late ProviderSubscription<HomeState> subscription;

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

    when(() => habitsRepository.getTodayHabits(any()))
        .thenAnswer((_) async => [habit]);
    when(() => habitsRepository.watchTodayHabits(any()))
        .thenAnswer((_) => habitsStream.stream);
    when(() => habitEntriesRepository.fetchEntriesForDate(any()))
        .thenAnswer((_) async => <HabitEntry>[]);
    when(() => habitEntriesRepository.watchEntriesForDate(any()))
        .thenAnswer((_) => entriesStream.stream);

    container = ProviderContainer(
      overrides: [
        habitsRepositoryProvider.overrideWithValue(habitsRepository),
        habitEntriesRepositoryProvider.overrideWithValue(
          habitEntriesRepository,
        ),
        toggleHabitCompletionProvider.overrideWithValue(toggleHabitCompletion),
        homeControllerClockProvider.overrideWithValue(
          () => DateTime(2024, 6, 10, 8, 0),
        ),
        homeControllerTimerProvider.overrideWithValue(
          (duration, callback) => Timer(const Duration(days: 1), () {}),
        ),
      ],
    );
    subscription = container.listen(homeControllerProvider, (previous, next) {});
  });

  tearDown(() async {
    await habitsStream.close();
    await entriesStream.close();
    subscription.close();
    container.dispose();
  });

  HomeController controller() => container.read(homeControllerProvider.notifier);

  Future<void> pumpMicrotasks() => Future<void>.delayed(Duration.zero);

  Future<HomeState> waitForState(bool Function(HomeState) predicate) async {
    for (var i = 0; i < 500; i += 1) {
      final state = container.read(homeControllerProvider);
      if (predicate(state)) return state;
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
    throw StateError('HomeController state did not reach expected condition');
  }

  test('loads today\'s habits on initialization', () async {
    controller();

    habitsStream.add([habit]);
    entriesStream.add([]);

    await pumpMicrotasks();

    final state = await waitForState(
      (value) => !value.isLoading && value.habits.isNotEmpty,
    );
    expect(state.isLoading, isFalse);
    expect(state.habits, isNotEmpty);
    expect(state.habits.first.habit, habit);

  });

  test('toggleHabit updates completion state and streaks', () async {
    final ctrl = controller();
    habitsStream.add([habit]);
    entriesStream.add([]);
    await pumpMicrotasks();

    await waitForState((value) => !value.isLoading);

    final updatedHabit = habit.copyWith(currentStreak: 1, bestStreak: 2);
    final entry = HabitEntry(
      habitId: habit.id,
      date: DateTime(2024, 6, 10),
      done: true,
    );

    when(() => toggleHabitCompletion.call(
          habitId: habit.id,
          date: any(named: 'date'),
        )).thenAnswer(
      (_) async => ToggleHabitResult(habit: updatedHabit, entry: entry),
    );

    final result = await ctrl.toggleHabit(habit.id);
    expect(result, isTrue);

    final state = await waitForState(
      (value) => value.habits.first.isCompleted,
    );
    expect(state.completedCount, 1);
    expect(state.habits.first.habit.currentStreak, 1);
    expect(state.habits.first.isCompleted, isTrue);

  });

  test('toggleHabit restores previous state when failing', () async {
    final ctrl = controller();
    habitsStream.add([habit]);
    entriesStream.add([]);
    await pumpMicrotasks();

    await waitForState((value) => !value.isLoading);

    when(() => toggleHabitCompletion.call(
          habitId: habit.id,
          date: any(named: 'date'),
        )).thenThrow(Exception('failure'));

    final result = await ctrl.toggleHabit(habit.id);

    expect(result, isNull);
    final state = await waitForState(
      (value) => value.errorMessage != null,
    );
    expect(state.habits.first.isCompleted, isFalse);
    expect(state.errorMessage, contains('failure'));

  });
}

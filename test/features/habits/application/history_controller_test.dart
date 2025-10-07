import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:habit_tracker/features/habits/application/history_analytics.dart';
import 'package:habit_tracker/features/habits/application/history_controller.dart';
import 'package:habit_tracker/features/habits/application/history_state.dart';
import 'package:habit_tracker/features/habits/data/repositories/habit_entries_repository.dart';
import 'package:habit_tracker/features/habits/data/repositories/habits_repository.dart';
import 'package:habit_tracker/features/habits/domain/domain.dart';
import 'package:habit_tracker/features/habits/domain/usecases/get_habit_history.dart';

class _MockGetHabitHistory extends Mock implements GetHabitHistory {}

class _MockHabitsRepository extends Mock implements HabitsRepository {}

class _MockHabitEntriesRepository extends Mock
    implements HabitEntriesRepository {}

class _Counter {
  int value = 0;
  void increment() => value += 1;
}

class _RecordingHistoryAnalytics extends HistoryAnalytics {
  _RecordingHistoryAnalytics()
    : _viewCalls = _Counter(),
      _emptyStateCalls = _Counter(),
      _streakCalls = _Counter();

  final _Counter _viewCalls;
  final _Counter _emptyStateCalls;
  final _Counter _streakCalls;
  final List<Map<String, Object?>> daySelectEvents = [];
  final List<String> filterHabitIds = [];
  final List<Map<String, Object?>> scrollEvents = [];

  int get viewCalls => _viewCalls.value;
  int get emptyStateCalls => _emptyStateCalls.value;
  int get streakCalls => _streakCalls.value;

  @override
  Future<void> logView({
    required int dateRangeDays,
    required int totalHabits,
  }) async {
    _viewCalls.increment();
  }

  @override
  Future<void> logEmptyState({required int totalHabits}) async {
    _emptyStateCalls.increment();
  }

  @override
  Future<void> logDaySelect({
    required DateTime date,
    required double completionRate,
    int? streakOnDate,
  }) async {
    daySelectEvents.add({
      'date': date,
      'rate': completionRate,
      'streak': streakOnDate,
    });
  }

  @override
  Future<void> logFilterToggle(Habit habit) async {
    filterHabitIds.add(habit.id);
  }

  @override
  Future<void> logScrollRange({
    required int daysLoaded,
    required String direction,
  }) async {
    scrollEvents.add({'days': daysLoaded, 'direction': direction});
  }

  @override
  Future<void> logStreakSummary({
    required int bestStreak,
    required int currentStreak,
  }) async {
    _streakCalls.increment();
  }
}

class _NoopTimer implements Timer {
  _NoopTimer();

  @override
  void cancel() {}

  @override
  bool get isActive => false;

  @override
  int get tick => 0;
}

void main() {
  late ProviderContainer container;
  late ProviderSubscription<HistoryState> subscription;
  late _MockGetHabitHistory getHabitHistory;
  late _MockHabitsRepository habitsRepository;
  late _MockHabitEntriesRepository entriesRepository;
  late _RecordingHistoryAnalytics analytics;
  late Habit habit;
  late Habit otherHabit;
  late HabitHistorySnapshot allSnapshot;
  late HabitHistorySnapshot filteredSnapshot;

  setUpAll(() {
    registerFallbackValue(DateTime(2024));
  });

  setUp(() {
    getHabitHistory = _MockGetHabitHistory();
    habitsRepository = _MockHabitsRepository();
    entriesRepository = _MockHabitEntriesRepository();
    analytics = _RecordingHistoryAnalytics();

    habit = Habit(
      id: 'habit-1',
      name: 'Read',
      emoji: '📚',
      color: 0xFF7C3AED,
      days: const [0, 1, 2, 3, 4, 5, 6],
      reminderId: '',
      reminderTime: '',
      bestStreak: 4,
      currentStreak: 2,
      createdAt: DateTime(2024, 6, 9),
    );

    otherHabit = Habit(
      id: 'habit-2',
      name: 'Meditate',
      emoji: '🧘',
      color: 0xFF22C55E,
      days: const [0, 2, 4],
      reminderId: 'reminder-2',
      reminderTime: '08:00',
      bestStreak: 1,
      currentStreak: 0,
      createdAt: DateTime(2024, 6, 8),
    );

    final date = DateTime(2024, 6, 10);
    final prior = date.subtract(const Duration(days: 1));

    allSnapshot = HabitHistorySnapshot(
      rangeStart: prior,
      rangeEnd: date,
      days: [
        HabitHistoryDay(
          date: prior,
          items: [
            HabitHistoryItem(
              habit: habit,
              date: prior,
              entry: HabitEntry(habitId: habit.id, date: prior, done: true),
            ),
            HabitHistoryItem(habit: otherHabit, date: prior, entry: null),
          ],
        ),
        HabitHistoryDay(
          date: date,
          items: [
            HabitHistoryItem(habit: habit, date: date, entry: null),
            HabitHistoryItem(habit: otherHabit, date: date, entry: null),
          ],
        ),
      ],
      habits: [habit, otherHabit],
    );

    filteredSnapshot = HabitHistorySnapshot(
      rangeStart: prior,
      rangeEnd: date,
      days: [
        HabitHistoryDay(
          date: prior,
          items: [
            HabitHistoryItem(
              habit: habit,
              date: prior,
              entry: HabitEntry(habitId: habit.id, date: prior, done: true),
            ),
          ],
        ),
        HabitHistoryDay(
          date: date,
          items: [HabitHistoryItem(habit: habit, date: date, entry: null)],
        ),
      ],
      habits: [habit, otherHabit],
    );

    when(
      () => habitsRepository.watchHabits(),
    ).thenAnswer((_) => const Stream<List<Habit>>.empty());
    when(
      () => entriesRepository.watchEntriesInRange(
        any(),
        any(),
        habitId: any(named: 'habitId'),
      ),
    ).thenAnswer((_) => const Stream<List<HabitEntry>>.empty());
    when(
      () => getHabitHistory(
        startDate: any(named: 'startDate'),
        endDate: any(named: 'endDate'),
        habitId: any(named: 'habitId'),
      ),
    ).thenAnswer((invocation) async {
      final filter = invocation.namedArguments[#habitId] as String?;
      if (filter == habit.id) {
        return filteredSnapshot;
      }
      return allSnapshot;
    });

    container = ProviderContainer(
      overrides: [
        getHabitHistoryProvider.overrideWithValue(getHabitHistory),
        historyAnalyticsProvider.overrideWithValue(analytics),
        habitsRepositoryProvider.overrideWithValue(habitsRepository),
        habitEntriesRepositoryProvider.overrideWithValue(entriesRepository),
        historyControllerClockProvider.overrideWithValue(
          () => DateTime(2024, 6, 10),
        ),
        historyControllerTimerProvider.overrideWithValue(
          (duration, callback) => _NoopTimer(),
        ),
      ],
    );
    subscription = container.listen(
      historyControllerProvider,
      (previous, next) {},
      fireImmediately: true,
    );
  });

  tearDown(() {
    subscription.close();
    container.dispose();
  });

  Future<void> pumpController() async {
    container.read(historyControllerProvider);
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(const Duration(milliseconds: 20));
  }

  HistoryController controller() =>
      container.read(historyControllerProvider.notifier);

  HistoryState state() => container.read(historyControllerProvider);
  Future<HistoryState> waitFor(bool Function(HistoryState) matcher) async {
    for (var i = 0; i < 50; i += 1) {
      final current = state();
      if (matcher(current)) {
        return current;
      }
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
    throw StateError(
      'HistoryController state did not reach expected condition',
    );
  }

  test('initial load populates history and logs view', () async {
    await pumpController();

    final current = await waitFor((value) => value.days.isNotEmpty);
    expect(current.days, isNotEmpty);
    expect(current.selectedDate, allSnapshot.rangeEnd);
    final today = allSnapshot.rangeEnd;
    final todayDay = current.dayFor(today);
    expect(todayDay?.habits.length, 2);
    expect(current.streakSummary.bestStreak, habit.bestStreak);
    expect(analytics.viewCalls, 1);
    expect(analytics.streakCalls, 1);
  });

  test('selectDate updates state and logs analytics', () async {
    await pumpController();

    final previous = allSnapshot.days.first.date;
    await controller().selectDate(previous);

    final current = await waitFor((value) => value.selectedDate == previous);
    expect(current.selectedDate, previous);
    expect(analytics.daySelectEvents, isNotEmpty);
    final event = analytics.daySelectEvents.last;
    expect(event['date'], previous);
  });

  test('applyHabitFilter updates filter and logs event', () async {
    await pumpController();

    await controller().applyHabitFilter(habit.id);
    await Future<void>.delayed(const Duration(milliseconds: 10));

    final current = await waitFor((value) => value.filterHabitId == habit.id);
    expect(current.filterHabitId, habit.id);
    final firstDay = current.days.first;
    expect(firstDay.habits.length, 1);
    expect(analytics.filterHabitIds, contains(habit.id));
  });

  test('applyHabitFilter resets to all habits when selecting null', () async {
    await pumpController();

    await controller().applyHabitFilter(habit.id);
    await waitFor((value) => value.filterHabitId == habit.id);

    await controller().applyHabitFilter(null);
    final current = await waitFor((value) => value.filterHabitId == null);

    final today = allSnapshot.rangeEnd;
    final day = current.dayFor(today);
    expect(day?.habits.length, 2);
  });

  test('reportScroll logs only once per direction', () async {
    await pumpController();

    await controller().reportScroll(HistoryScrollDirection.backward);
    await controller().reportScroll(HistoryScrollDirection.backward);

    expect(analytics.scrollEvents.length, 1);
    expect(analytics.scrollEvents.first['direction'], 'backward');
  });
}

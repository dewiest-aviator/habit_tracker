import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/date_helpers.dart';
import '../data/repositories/habit_entries_repository.dart';
import '../data/repositories/habits_repository.dart';
import '../domain/domain.dart';
import '../domain/usecases/get_habit_history.dart';
import 'history_analytics.dart';
import 'history_state.dart';

class HistoryController extends Notifier<HistoryState> {
  HistoryController({
    GetHabitHistory? getHabitHistory,
    HistoryAnalytics? analytics,
    HabitsRepository? habitsRepository,
    HabitEntriesRepository? entriesRepository,
    DateTime Function()? clock,
    Timer Function(Duration, void Function())? timerFactory,
  }) : _getHabitHistoryOverride = getHabitHistory,
       _analyticsOverride = analytics,
       _habitsRepositoryOverride = habitsRepository,
       _entriesRepositoryOverride = entriesRepository,
       _clockOverride = clock,
       _timerFactoryOverride = timerFactory;

  static const int _rangeDays = 30;

  final GetHabitHistory? _getHabitHistoryOverride;
  final HistoryAnalytics? _analyticsOverride;
  final HabitsRepository? _habitsRepositoryOverride;
  final HabitEntriesRepository? _entriesRepositoryOverride;
  final DateTime Function()? _clockOverride;
  final Timer Function(Duration, void Function())? _timerFactoryOverride;

  late final GetHabitHistory _getHabitHistory;
  late final HistoryAnalytics _analytics;
  late final HabitsRepository _habitsRepository;
  late final HabitEntriesRepository _entriesRepository;
  late DateTime Function() _clock;
  late Timer Function(Duration, void Function()) _timerFactory;

  Timer? _midnightTimer;
  StreamSubscription<List<Habit>>? _habitsSubscription;
  StreamSubscription<List<HabitEntry>>? _entriesSubscription;
  bool _viewLogged = false;
  bool _emptyLogged = false;
  bool _streakLogged = false;
  final Set<HistoryScrollDirection> _loggedScrollDirections = {};

  @override
  HistoryState build() {
    _getHabitHistory =
        _getHabitHistoryOverride ?? ref.read(getHabitHistoryProvider);
    _analytics = _analyticsOverride ?? ref.read(historyAnalyticsProvider);
    _habitsRepository =
        _habitsRepositoryOverride ?? ref.read(habitsRepositoryProvider);
    _entriesRepository =
        _entriesRepositoryOverride ?? ref.read(habitEntriesRepositoryProvider);
    _clock = _clockOverride ?? ref.read(historyControllerClockProvider);
    _timerFactory =
        _timerFactoryOverride ?? ref.read(historyControllerTimerProvider);

    final today = DateHelpers.startOfDay(_clock());
    final initialState = HistoryState.initial(today, rangeDays: _rangeDays);

    Future<void>.microtask(() {
      if (!ref.mounted) return;
      _initialize();
    });

    ref.onDispose(() {
      _midnightTimer?.cancel();
      unawaited(_habitsSubscription?.cancel());
      unawaited(_entriesSubscription?.cancel());
    });

    return initialState;
  }

  Future<void> _initialize() async {
    _scheduleMidnightRefresh();
    await _loadRange(showLoading: true);
    _subscribeToHabits();
    _subscribeToEntries();
  }

  Future<void> refresh() => _loadRange(showLoading: true);

  Future<void> selectDate(DateTime date) async {
    final normalized = DateHelpers.startOfDay(date);
    final clamped = _clampToRange(normalized);
    if (state.selectedDate == clamped) {
      return;
    }
    state = state.copyWith(selectedDate: clamped, clearError: true);
    final completionRate = state.dayFor(clamped)?.completionRate ?? 0;
    final streak = _computeStreakOnDate(clamped);
    await _analytics.logDaySelect(
      date: clamped,
      completionRate: completionRate,
      streakOnDate: streak > 0 ? streak : null,
    );
  }

  Future<void> applyHabitFilter(String? habitId) async {
    if (state.filterHabitId == habitId) {
      return;
    }
    final previousFilter = state.filterHabitId;
    state = state.copyWith(
      filterHabitId: habitId,
      selectedDate: state.rangeEnd,
      isLoading: true,
    );
    _loggedScrollDirections.clear();
    await _loadRange(showLoading: false);
    if (habitId != null && habitId != previousFilter) {
      final habit = _findHabit(habitId);
      if (habit != null) {
        await _analytics.logFilterToggle(habit);
      }
    }
    _subscribeToEntries();
  }

  Future<void> reportScroll(HistoryScrollDirection direction) {
    if (_loggedScrollDirections.contains(direction)) {
      return Future<void>.value();
    }
    _loggedScrollDirections.add(direction);
    final label = direction == HistoryScrollDirection.backward
        ? 'backward'
        : 'forward';
    return _analytics.logScrollRange(
      daysLoaded: state.days.length,
      direction: label,
    );
  }

  Future<void> _loadRange({required bool showLoading}) async {
    if (showLoading) {
      state = state.copyWith(isLoading: true, clearError: true);
    }
    try {
      final snapshot = await _getHabitHistory(
        startDate: state.rangeStart,
        endDate: state.rangeEnd,
        habitId: state.filterHabitId,
      );

      final days = snapshot.days
          .map(
            (day) => HistoryDayViewData(
              date: day.date,
              habits: day.items
                  .map(
                    (item) => HistoryHabitViewData(
                      habit: item.habit,
                      date: day.date,
                      status: _resolveHabitStatus(day.date, item),
                    ),
                  )
                  .toList(growable: false),
            ),
          )
          .toList(growable: false);

      final selected = _resolveSelectedDate(days);
      final streakSummary = _buildStreakSummary(
        habits: snapshot.habits,
        filterHabitId: state.filterHabitId,
      );

      state = state.copyWith(
        days: days,
        habits: snapshot.habits,
        selectedDate: selected,
        isLoading: false,
        clearError: true,
        streakSummary: streakSummary,
      );

      _maybeLogView(snapshot);
      _maybeLogEmptyState(snapshot);
      _maybeLogStreakSummary(streakSummary);
    } catch (error) {
      state = state.copyWith(isLoading: false, errorMessage: error.toString());
    }
  }

  void _maybeLogView(HabitHistorySnapshot snapshot) {
    if (_viewLogged) return;
    unawaited(
      _analytics.logView(
        dateRangeDays: _rangeDays,
        totalHabits: snapshot.habits.length,
      ),
    );
    _viewLogged = true;
  }

  void _maybeLogEmptyState(HabitHistorySnapshot snapshot) {
    if (_emptyLogged || !state.isEmpty) {
      return;
    }
    unawaited(_analytics.logEmptyState(totalHabits: snapshot.habits.length));
    _emptyLogged = true;
  }

  void _maybeLogStreakSummary(HistoryStreakSummary summary) {
    if (_streakLogged || !summary.hasData) {
      return;
    }
    unawaited(
      _analytics.logStreakSummary(
        bestStreak: summary.bestStreak,
        currentStreak: summary.currentStreak,
      ),
    );
    _streakLogged = true;
  }

  HistoryStreakSummary _buildStreakSummary({
    required List<Habit> habits,
    String? filterHabitId,
  }) {
    if (habits.isEmpty) {
      return const HistoryStreakSummary(bestStreak: 0, currentStreak: 0);
    }
    if (filterHabitId != null) {
      final habit = _findHabitIn(habits, filterHabitId);
      if (habit != null) {
        return HistoryStreakSummary(
          bestStreak: habit.bestStreak,
          currentStreak: habit.currentStreak,
          bestHabit: habit,
          currentHabit: habit,
        );
      }
    }

    Habit? bestHabit;
    Habit? currentHabit;
    var bestStreak = 0;
    var currentStreak = 0;

    for (final habit in habits) {
      if (habit.bestStreak > bestStreak) {
        bestStreak = habit.bestStreak;
        bestHabit = habit;
      }
      if (habit.currentStreak > currentStreak) {
        currentStreak = habit.currentStreak;
        currentHabit = habit;
      }
    }

    return HistoryStreakSummary(
      bestStreak: bestStreak,
      currentStreak: currentStreak,
      bestHabit: bestHabit,
      currentHabit: currentHabit,
    );
  }

  DateTime _resolveSelectedDate(List<HistoryDayViewData> days) {
    if (days.isEmpty) {
      return state.rangeEnd;
    }
    final desired = DateHelpers.startOfDay(state.selectedDate);
    final available = {for (final day in days) day.date: day};
    if (available.containsKey(desired)) {
      return desired;
    }
    return days.last.date;
  }

  int _computeStreakOnDate(DateTime date) {
    if (state.days.isEmpty) return 0;
    final target = DateHelpers.startOfDay(date);
    final relevantDays =
        state.days.where((day) => !day.date.isAfter(target)).toList()
          ..sort((a, b) => b.date.compareTo(a.date));
    var streak = 0;
    for (final day in relevantDays) {
      if (day.totalCount == 0) {
        continue;
      }
      final completed = state.filterHabitId == null
          ? (day.totalCount > 0 && day.completedCount == day.totalCount)
          : day.habits.any(
              (habit) =>
                  habit.habit.id == state.filterHabitId && habit.isCompleted,
            );
      if (completed) {
        streak += 1;
      } else {
        break;
      }
    }
    return streak;
  }

  HistoryHabitStatus _resolveHabitStatus(DateTime day, HabitHistoryItem item) {
    if (item.isCompleted) {
      return HistoryHabitStatus.completed;
    }
    final today = DateHelpers.startOfDay(_clock());
    final target = DateHelpers.startOfDay(day);
    if (target.isBefore(today)) {
      return HistoryHabitStatus.missed;
    }
    return HistoryHabitStatus.pending;
  }

  Habit? _findHabit(String habitId) {
    for (final habit in state.habits) {
      if (habit.id == habitId) {
        return habit;
      }
    }
    return null;
  }

  Habit? _findHabitIn(List<Habit> habits, String habitId) {
    for (final habit in habits) {
      if (habit.id == habitId) {
        return habit;
      }
    }
    return null;
  }

  void _subscribeToHabits() {
    _habitsSubscription?.cancel();
    _habitsSubscription = _habitsRepository.watchHabits().listen(
      (_) => unawaited(_loadRange(showLoading: false)),
      onError: (error, _) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: error.toString(),
        );
      },
    );
  }

  void _subscribeToEntries() {
    _entriesSubscription?.cancel();
    _entriesSubscription = _entriesRepository
        .watchEntriesInRange(
          state.rangeStart,
          state.rangeEnd,
          habitId: state.filterHabitId,
        )
        .listen(
          (_) => unawaited(_loadRange(showLoading: false)),
          onError: (error, _) {
            state = state.copyWith(
              isLoading: false,
              errorMessage: error.toString(),
            );
          },
        );
  }

  void _scheduleMidnightRefresh() {
    _midnightTimer?.cancel();
    final delay = DateHelpers.timeUntilNextDay(_clock());
    _midnightTimer = _timerFactory(delay, _handleMidnightTick);
  }

  void _handleMidnightTick() {
    _midnightTimer = null;
    final today = DateHelpers.startOfDay(_clock());
    final start = today.subtract(const Duration(days: _rangeDays - 1));
    state = state.copyWith(rangeStart: start, rangeEnd: today);
    _loggedScrollDirections.clear();
    _scheduleMidnightRefresh();
    _subscribeToEntries();
    unawaited(_loadRange(showLoading: true));
  }

  DateTime _clampToRange(DateTime date) {
    if (date.isBefore(state.rangeStart)) {
      return state.rangeStart;
    }
    if (date.isAfter(state.rangeEnd)) {
      return state.rangeEnd;
    }
    return date;
  }
}

enum HistoryScrollDirection { forward, backward }

final historyControllerClockProvider = Provider<DateTime Function()>((ref) {
  return DateTime.now;
});

final historyControllerTimerProvider =
    Provider<Timer Function(Duration, void Function())>((ref) {
      return (duration, callback) => Timer(duration, callback);
    });

final historyControllerProvider =
    NotifierProvider.autoDispose<HistoryController, HistoryState>(
      HistoryController.new,
    );

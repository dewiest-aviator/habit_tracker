import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/date_helpers.dart';
import '../data/repositories/habit_entries_repository.dart';
import '../data/repositories/habits_repository.dart';
import '../domain/domain.dart';
import '../domain/usecases/toggle_habit_completion.dart';
import 'home_state.dart';

class HomeController extends StateNotifier<HomeState> {
  HomeController({
    required HabitsRepository habitsRepository,
    required HabitEntriesRepository habitEntriesRepository,
    required ToggleHabitCompletion toggleHabitCompletion,
    DateTime Function()? clock,
    Timer Function(Duration, void Function())? timerFactory,
  }) : _habitsRepository = habitsRepository,
       _habitEntriesRepository = habitEntriesRepository,
       _toggleHabitCompletion = toggleHabitCompletion,
       _clock = clock ?? DateTime.now,
       _timerFactory =
           timerFactory ?? ((duration, callback) => Timer(duration, callback)),
       _currentDay = DateHelpers.startOfDay((clock ?? DateTime.now)()),
       super(
         HomeState.initial(DateHelpers.startOfDay((clock ?? DateTime.now)())),
       ) {
    _init();
  }

  final HabitsRepository _habitsRepository;
  final HabitEntriesRepository _habitEntriesRepository;
  final ToggleHabitCompletion _toggleHabitCompletion;
  final DateTime Function() _clock;
  final Timer Function(Duration, void Function()) _timerFactory;

  late DateTime _currentDay;
  Timer? _midnightTimer;
  StreamSubscription<List<Habit>>? _habitsSubscription;
  StreamSubscription<List<HabitEntry>>? _entriesSubscription;
  List<Habit> _latestHabits = const <Habit>[];
  List<HabitEntry> _latestEntries = const <HabitEntry>[];

  void _init() {
    _scheduleMidnightRefresh();
    unawaited(_loadCurrentDay());
  }

  Future<void> refresh() => _loadCurrentDay();

  Future<bool?> toggleHabit(String habitId) async {
    final index = state.habits.indexWhere((item) => item.habit.id == habitId);
    if (index == -1) {
      return null;
    }

    final previousState = state;
    final toggled = !state.habits[index].isCompleted;
    final optimisticHabits = <HomeHabitViewData>[...state.habits];
    optimisticHabits[index] = optimisticHabits[index].copyWith(
      isCompleted: toggled,
    );
    state = state.copyWith(habits: optimisticHabits, clearError: true);

    try {
      final result = await _toggleHabitCompletion(
        habitId: habitId,
        date: _currentDay,
      );
      _latestHabits = [
        for (final habit in _latestHabits)
          if (habit.id == result.habit.id) result.habit else habit,
      ];
      _latestEntries = _updateEntriesCache(result);
      final updatedHabits = [
        for (final item in state.habits)
          if (item.habit.id == result.habit.id)
            item.copyWith(habit: result.habit, isCompleted: result.isCompleted)
          else
            item,
      ];
      state = state.copyWith(habits: updatedHabits, clearError: true);
      return result.isCompleted;
    } catch (error) {
      state = previousState.copyWith(errorMessage: error.toString());
      return null;
    }
  }

  Future<void> _loadCurrentDay() async {
    state = state.copyWith(isLoading: true, clearError: true);

    await _cancelSubscriptions();

    _currentDay = DateHelpers.startOfDay(_clock());

    try {
      _latestHabits = await _habitsRepository.getTodayHabits(_currentDay);
      _latestEntries = await _habitEntriesRepository.fetchEntriesForDate(
        _currentDay,
      );
      _emitSnapshot();
      _habitsSubscription = _habitsRepository
          .watchTodayHabits(_currentDay)
          .listen(_handleHabitUpdate, onError: _handleError);
      _entriesSubscription = _habitEntriesRepository
          .watchEntriesForDate(_currentDay)
          .listen(_handleEntriesUpdate, onError: _handleError);
    } catch (error) {
      state = state.copyWith(isLoading: false, errorMessage: error.toString());
    }
  }

  void _handleHabitUpdate(List<Habit> habits) {
    _latestHabits = habits;
    _emitSnapshot();
  }

  void _handleEntriesUpdate(List<HabitEntry> entries) {
    _latestEntries = entries;
    _emitSnapshot();
  }

  void _emitSnapshot() {
    final items = _latestHabits
        .take(HomeState.maxHabits)
        .map(
          (habit) => HomeHabitViewData(
            habit: habit,
            isCompleted: _latestEntries.any(
              (entry) =>
                  entry.habitId == habit.id &&
                  entry.done &&
                  DateHelpers.isSameDay(entry.date, _currentDay),
            ),
          ),
        )
        .toList(growable: false);

    state = state.copyWith(
      habits: items,
      currentDate: _currentDay,
      isLoading: false,
      clearError: true,
    );
  }

  List<HabitEntry> _updateEntriesCache(ToggleHabitResult result) {
    final updatedEntries = _latestEntries
        .where(
          (entry) =>
              !(entry.habitId == result.habit.id &&
                  DateHelpers.isSameDay(entry.date, _currentDay)),
        )
        .toList(growable: true);
    if (result.entry != null) {
      updatedEntries.add(result.entry!);
    }
    return List<HabitEntry>.unmodifiable(updatedEntries);
  }

  void _handleError(Object error, [StackTrace? stackTrace]) {
    state = state.copyWith(errorMessage: error.toString(), isLoading: false);
  }

  Future<void> _cancelSubscriptions() async {
    await _habitsSubscription?.cancel();
    await _entriesSubscription?.cancel();
    _habitsSubscription = null;
    _entriesSubscription = null;
  }

  void _scheduleMidnightRefresh() {
    _midnightTimer?.cancel();
    final duration = DateHelpers.timeUntilNextDay(_clock());
    _midnightTimer = _timerFactory(duration, _handleMidnightTick);
  }

  void _handleMidnightTick() {
    _midnightTimer = null;
    unawaited(_loadCurrentDay());
    _scheduleMidnightRefresh();
  }

  @override
  void dispose() {
    _midnightTimer?.cancel();
    unawaited(_cancelSubscriptions());
    super.dispose();
  }
}

final homeControllerProvider =
    StateNotifierProvider.autoDispose<HomeController, HomeState>((ref) {
      final habitsRepository = ref.watch(habitsRepositoryProvider);
      final habitEntriesRepository = ref.watch(habitEntriesRepositoryProvider);
      final toggleHabitCompletion = ref.watch(toggleHabitCompletionProvider);

      return HomeController(
        habitsRepository: habitsRepository,
        habitEntriesRepository: habitEntriesRepository,
        toggleHabitCompletion: toggleHabitCompletion,
      );
    });

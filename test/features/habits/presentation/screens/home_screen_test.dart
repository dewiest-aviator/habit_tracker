import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:habit_tracker/features/habits/application/home_analytics.dart';
import 'package:habit_tracker/features/habits/application/home_controller.dart';
import 'package:habit_tracker/features/habits/application/home_state.dart';
import 'package:habit_tracker/features/habits/data/repositories/habit_entries_repository.dart';
import 'package:habit_tracker/features/habits/data/repositories/habits_repository.dart';
import 'package:habit_tracker/features/habits/domain/domain.dart';
import 'package:habit_tracker/features/habits/domain/usecases/toggle_habit_completion.dart';
import 'package:habit_tracker/features/habits/presentation/screens/home_screen.dart';
import 'package:habit_tracker/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

class _MockHabitsRepository extends Mock implements HabitsRepository {}

class _MockHabitEntriesRepository extends Mock
    implements HabitEntriesRepository {}

class _MockToggleHabitCompletion extends Mock
    implements ToggleHabitCompletion {}

class _StubHomeAnalytics extends HomeAnalytics {
  const _StubHomeAnalytics();

  @override
  Future<void> logView({
    required int totalHabits,
    required int completedHabits,
    required bool isEmpty,
  }) async {}

  @override
  Future<void> logToggle(Habit habit, bool completed) async {}

  @override
  Future<void> logRefresh(HomeState state) async {}

  @override
  Future<void> logAddHabitTap() async {}

  @override
  Future<void> logAddHabitLimitReached(int totalHabits) async {}

  @override
  Future<void> logHabitActionsOpen(Habit habit) async {}

  @override
  Future<void> logHabitActionSelected(
    Habit habit, {
    required String action,
  }) async {}
}

GoRouter _createRouter() {
  final rootKey = GlobalKey<NavigatorState>();
  return GoRouter(
    navigatorKey: rootKey,
    initialLocation: '/',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => navigationShell,
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/history',
                builder: (context, state) => const SizedBox.shrink(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SizedBox.shrink(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        parentNavigatorKey: rootKey,
        path: '/habit_form',
        builder: (context, state) => const SizedBox(),
      ),
    ],
  );
}

void main() {
  setUpAll(() {
    registerFallbackValue(DateTime(2024));
    registerFallbackValue(
      Habit(
        id: 'fallback',
        name: 'Fallback',
        emoji: '✅',
        color: 0xFF000000,
        days: const [0, 1, 2, 3, 4, 5, 6],
        reminderId: 'reminder',
        reminderTime: '08:00',
        bestStreak: 0,
        currentStreak: 0,
      ),
    );
    registerFallbackValue(
      HabitEntry(habitId: 'fallback', date: DateTime(2024), done: true),
    );
  });

  late _MockHabitsRepository habitsRepository;
  late _MockHabitEntriesRepository habitEntriesRepository;
  late _MockToggleHabitCompletion toggleHabitCompletion;
  late StreamController<List<Habit>> habitsStream;
  late StreamController<List<HabitEntry>> entriesStream;

  setUp(() {
    habitsRepository = _MockHabitsRepository();
    habitEntriesRepository = _MockHabitEntriesRepository();
    toggleHabitCompletion = _MockToggleHabitCompletion();
    habitsStream = StreamController<List<Habit>>.broadcast();
    entriesStream = StreamController<List<HabitEntry>>.broadcast();

    when(
      () => habitsRepository.watchTodayHabits(any()),
    ).thenAnswer((_) => habitsStream.stream);
    when(
      () => habitEntriesRepository.watchEntriesForDate(any()),
    ).thenAnswer((_) => entriesStream.stream);
    when(() => habitsRepository.saveHabit(any())).thenAnswer((_) async {});
  });

  tearDown(() async {
    await habitsStream.close();
    await entriesStream.close();
  });

  Future<void> pumpHome(WidgetTester tester, HomeController controller) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          homeControllerProvider.overrideWith(() => controller),
          homeAnalyticsProvider.overrideWithValue(const _StubHomeAnalytics()),
        ],
        child: MaterialApp.router(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: _createRouter(),
        ),
      ),
    );
  }

  testWidgets('shows loading indicator then empty state', (tester) async {
    final habitsCompleter = Completer<List<Habit>>();
    final entriesCompleter = Completer<List<HabitEntry>>();

    when(
      () => habitsRepository.getTodayHabits(any()),
    ).thenAnswer((_) => habitsCompleter.future);
    when(
      () => habitEntriesRepository.fetchEntriesForDate(any()),
    ).thenAnswer((_) => entriesCompleter.future);

    final controller = HomeController(
      habitsRepository: habitsRepository,
      habitEntriesRepository: habitEntriesRepository,
      toggleHabitCompletion: toggleHabitCompletion,
      clock: () => DateTime(2024, 6, 10, 8),
      timerFactory: (duration, callback) =>
          Timer(const Duration(days: 1), () {}),
    );

    await pumpHome(tester, controller);
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    habitsCompleter.complete(const []);
    entriesCompleter.complete(const []);
    habitsStream.add(const []);
    entriesStream.add(const []);

    await tester.pumpAndSettle();
    expect(find.text('Add your first habit'), findsOneWidget);
  });

  testWidgets('displays habits and toggles completion', (tester) async {
    final habit = Habit(
      id: 'habit-1',
      name: 'Read',
      emoji: '📚',
      color: 0xFF009688,
      days: const [0, 1, 2, 3, 4, 5, 6],
      reminderId: 'reminder-1',
      reminderTime: '21:00',
      bestStreak: 1,
      currentStreak: 0,
    );

    when(
      () => habitsRepository.getTodayHabits(any()),
    ).thenAnswer((_) async => [habit]);
    when(
      () => habitEntriesRepository.fetchEntriesForDate(any()),
    ).thenAnswer((_) async => const []);

    habitsStream.add([habit]);
    entriesStream.add(const []);

    final controller = HomeController(
      habitsRepository: habitsRepository,
      habitEntriesRepository: habitEntriesRepository,
      toggleHabitCompletion: toggleHabitCompletion,
      clock: () => DateTime(2024, 6, 10, 8),
      timerFactory: (duration, callback) =>
          Timer(const Duration(days: 1), () {}),
    );

    final updatedHabit = habit.copyWith(currentStreak: 1, bestStreak: 2);
    when(
      () => toggleHabitCompletion.call(
        habitId: habit.id,
        date: any(named: 'date'),
      ),
    ).thenAnswer(
      (_) async => ToggleHabitResult(
        habit: updatedHabit,
        entry: HabitEntry(
          habitId: habit.id,
          date: DateTime(2024, 6, 10),
          done: true,
        ),
      ),
    );

    await pumpHome(tester, controller);
    await tester.pumpAndSettle();

    expect(find.text("Today's habits"), findsOneWidget);
    expect(find.text('Read'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.radio_button_unchecked));
    await tester.pump();
    await tester.pump();

    verify(
      () => toggleHabitCompletion.call(
        habitId: habit.id,
        date: any(named: 'date'),
      ),
    ).called(1);

    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('Marked Read as done.'), findsOneWidget);
  });

  testWidgets('shows habit actions sheet with undo option', (tester) async {
    final habit = Habit(
      id: 'habit-1',
      name: 'Read',
      emoji: '📚',
      color: 0xFF009688,
      days: const [0, 1, 2, 3, 4, 5, 6],
      reminderId: 'reminder-1',
      reminderTime: '21:00',
      bestStreak: 1,
      currentStreak: 1,
    );
    final entry = HabitEntry(
      habitId: habit.id,
      date: DateTime(2024, 6, 10),
      done: true,
    );

    when(
      () => habitsRepository.getTodayHabits(any()),
    ).thenAnswer((_) async => [habit]);
    when(
      () => habitEntriesRepository.fetchEntriesForDate(any()),
    ).thenAnswer((_) async => [entry]);

    habitsStream.add([habit]);
    entriesStream.add([entry]);

    final controller = HomeController(
      habitsRepository: habitsRepository,
      habitEntriesRepository: habitEntriesRepository,
      toggleHabitCompletion: toggleHabitCompletion,
      clock: () => DateTime(2024, 6, 10, 8),
      timerFactory: (duration, callback) =>
          Timer(const Duration(days: 1), () {}),
    );

    when(
      () => toggleHabitCompletion.call(
        habitId: habit.id,
        date: any(named: 'date'),
      ),
    ).thenAnswer((_) async => ToggleHabitResult(habit: habit, entry: null));

    await pumpHome(tester, controller);
    await tester.pumpAndSettle();

    await tester.longPress(find.byKey(const Key('habit_card_habit-1')));
    await tester.pumpAndSettle();

    expect(find.text('Edit Read'), findsOneWidget);
    expect(find.text('Undo completion for Read'), findsOneWidget);

    await tester.tap(find.text('Undo completion for Read'));
    await tester.pumpAndSettle();

    verify(
      () => toggleHabitCompletion.call(
        habitId: habit.id,
        date: any(named: 'date'),
      ),
    ).called(1);
  });
}

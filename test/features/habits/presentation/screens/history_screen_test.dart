import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:habit_tracker/features/habits/application/history_controller.dart';
import 'package:habit_tracker/features/habits/application/history_state.dart';
import 'package:habit_tracker/features/habits/domain/domain.dart';
import 'package:habit_tracker/features/habits/presentation/screens/history_screen.dart';
import 'package:habit_tracker/l10n/app_localizations.dart';

void main() {
  final baseDate = DateTime(2024, 6, 10);

  HistoryState emptyState() {
    return HistoryState(
      rangeStart: baseDate.subtract(const Duration(days: 29)),
      rangeEnd: baseDate,
      selectedDate: baseDate,
      days: const [],
      habits: const [],
      isLoading: false,
    );
  }

  HistoryState populatedState() {
    final habitView = HistoryHabitViewData(
      habit: HabitStub('habit-1', 'Read', '📚', 0xFF4F46E5),
      date: baseDate,
      status: HistoryHabitStatus.completed,
    );
    return HistoryState(
      rangeStart: baseDate.subtract(const Duration(days: 1)),
      rangeEnd: baseDate,
      selectedDate: baseDate,
      days: [
        HistoryDayViewData(date: baseDate, habits: [habitView]),
      ],
      habits: [habitView.habit],
      isLoading: false,
      streakSummary: const HistoryStreakSummary(
        bestStreak: 5,
        currentStreak: 2,
      ),
    );
  }

  testWidgets('shows empty state when no history exists', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          historyControllerProvider.overrideWith(
            () => _StaticHistoryController(emptyState()),
          ),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const HistoryScreen(),
        ),
      ),
    );

    expect(find.text('History'), findsOneWidget);
    expect(find.text('No history yet'), findsOneWidget);
    expect(find.text('Start tracking today!'), findsOneWidget);
  });

  testWidgets('renders summary and habit day list when data present', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          historyControllerProvider.overrideWith(
            () => _StaticHistoryController(populatedState()),
          ),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const HistoryScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Streak summary'), findsOneWidget);
    expect(find.text('5'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.textContaining('Read'), findsWidgets);
  });
}

class HabitStub extends Habit {
  HabitStub(String id, String name, String emoji, int color)
    : super(
        id: id,
        name: name,
        emoji: emoji,
        color: color,
        days: const [0, 1, 2, 3, 4, 5, 6],
        reminderId: '',
        reminderTime: '',
        bestStreak: 0,
        currentStreak: 0,
        createdAt: DateTime(2024, 6, 1),
      );
}

class _StaticHistoryController extends HistoryController {
  _StaticHistoryController(this._state) : super();

  final HistoryState _state;

  @override
  HistoryState build() => _state;
}

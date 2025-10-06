import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/features/habits/application/home_state.dart';
import 'package:habit_tracker/features/habits/domain/domain.dart';
import 'package:habit_tracker/features/habits/presentation/widgets/habit_card.dart';
import 'package:habit_tracker/l10n/app_localizations.dart';

Future<void> _pumpCard(
  WidgetTester tester,
  HomeHabitViewData data, {
  VoidCallback? onToggle,
  VoidCallback? onLongPress,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: HabitCard(
          data: data,
          onToggle: onToggle ?? () {},
          onLongPress: onLongPress,
        ),
      ),
    ),
  );
}

void main() {
  final habit = Habit(
    id: 'habit-1',
    name: 'Read',
    emoji: '📚',
    color: 0xFF009688,
    days: const [0, 1, 2, 3, 4, 5, 6],
    reminderId: 'reminder-1',
    reminderTime: '21:00',
    bestStreak: 4,
    currentStreak: 2,
  );

  testWidgets('renders habit details and triggers callbacks', (tester) async {
    var toggled = false;
    var longPressed = false;

    await _pumpCard(
      tester,
      HomeHabitViewData(habit: habit, isCompleted: false),
      onToggle: () => toggled = true,
      onLongPress: () => longPressed = true,
    );

    expect(find.text('Read'), findsOneWidget);
    expect(find.textContaining('2'), findsWidgets);

    await tester.tap(find.byKey(const Key('habit_card_habit-1')));
    await tester.pump();
    expect(toggled, isTrue);

    await tester.longPress(find.byKey(const Key('habit_card_habit-1')));
    expect(longPressed, isTrue);
  });

  testWidgets('shows completed state icon and tooltip', (tester) async {
    await _pumpCard(tester, HomeHabitViewData(habit: habit, isCompleted: true));

    expect(find.byIcon(Icons.check_circle), findsOneWidget);
    final tooltipFinder = find.byType(Tooltip);
    expect(tooltipFinder, findsOneWidget);
  });
}

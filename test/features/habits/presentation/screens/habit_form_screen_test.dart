import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/features/habits/presentation/screens/habit_form_screen.dart';
import 'package:habit_tracker/l10n/app_localizations.dart';

void main() {
  testWidgets('shows create messaging by default', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const HabitFormScreen(),
      ),
    );

    expect(find.text('Create habit'), findsOneWidget);
    expect(
      find.text('The habit form will live here in a future update.'),
      findsOneWidget,
    );
  });

  testWidgets('shows edit messaging when habit id is provided', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const HabitFormScreen(habitId: 'habit-1'),
      ),
    );

    expect(find.text('Edit habit'), findsOneWidget);
    expect(find.text('Editing habits is coming soon.'), findsOneWidget);
  });
}

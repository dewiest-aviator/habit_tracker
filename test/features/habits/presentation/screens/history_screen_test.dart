import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/features/habits/presentation/screens/history_screen.dart';
import 'package:habit_tracker/l10n/app_localizations.dart';

void main() {
  testWidgets('renders history placeholder copy', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const HistoryScreen(),
      ),
    );

    expect(
      find.descendant(of: find.byType(AppBar), matching: find.text('History')),
      findsOneWidget,
    );
    expect(
      find.text('Your streak history will appear here soon.'),
      findsOneWidget,
    );
  });
}

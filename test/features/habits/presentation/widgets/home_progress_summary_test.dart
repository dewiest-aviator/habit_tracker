import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/features/habits/presentation/widgets/home_progress_summary.dart';
import 'package:habit_tracker/l10n/app_localizations.dart';

void main() {
  testWidgets('displays localized progress text', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(body: HomeProgressSummary(completed: 2, total: 3)),
      ),
    );

    expect(find.text("Today's habits"), findsOneWidget);
    expect(find.text("You've completed 2 of 3 habits today"), findsOneWidget);
  });
}

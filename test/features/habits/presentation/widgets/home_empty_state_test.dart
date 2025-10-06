import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/features/habits/presentation/widgets/home_empty_state.dart';
import 'package:habit_tracker/l10n/app_localizations.dart';

void main() {
  testWidgets('renders copy and invokes callback', (tester) async {
    var pressed = false;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: HomeEmptyState(onAdd: () => pressed = true)),
      ),
    );

    expect(find.text('Add your first habit'), findsOneWidget);
    expect(find.text('Create a habit'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Create a habit'));
    expect(pressed, isTrue);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/app_router.dart';
import 'package:habit_tracker/theme/app_theme.dart';

void main() {
  testWidgets('navigates from Home to Settings', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp.router(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        routerConfig: createAppRouter(),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('Habits'), findsOneWidget);

    final settingsButton = find.byKey(const Key('btn_settings'));
    expect(settingsButton, findsOneWidget);
    await tester.tap(settingsButton);
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsOneWidget);

    final backButton = find.byTooltip('Back');
    await tester.tap(backButton);
    await tester.pumpAndSettle();

    final fab = find.byType(FloatingActionButton);
    expect(fab, findsOneWidget);
    await tester.tap(fab);
    await tester.pump();
  });

  testWidgets('shows not found page for unknown routes', (
    WidgetTester tester,
  ) async {
    final router = createAppRouter();

    await tester.pumpWidget(
      MaterialApp.router(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        routerConfig: router,
      ),
    );

    router.go('/missing');
    await tester.pumpAndSettle();

    expect(find.text('Not found'), findsOneWidget);
  });
}

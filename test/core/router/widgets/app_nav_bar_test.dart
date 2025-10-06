import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:habit_tracker/core/router/widgets/app_nav_bar.dart';
import 'package:habit_tracker/l10n/app_localizations.dart';

class _NavPage extends StatelessWidget {
  const _NavPage({required this.index, required this.title});

  final int index;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title, key: ValueKey('app_bar_$index'))),
      body: Center(child: Text(title, key: ValueKey('body_$index'))),
      bottomNavigationBar: AppNavBar(currentIndex: index),
    );
  }
}

void main() {
  late GoRouter router;

  setUp(() {
    router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) =>
              const _NavPage(index: 0, title: 'Home screen'),
        ),
        GoRoute(
          path: '/history',
          builder: (context, state) =>
              const _NavPage(index: 1, title: 'History screen'),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) =>
              const _NavPage(index: 2, title: 'Settings screen'),
        ),
      ],
    );
  });

  testWidgets('navigates to destinations when tapped', (tester) async {
    await tester.pumpWidget(
      MaterialApp.router(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
      ),
    );

    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('body_0')), findsOneWidget);

    await tester.tap(find.text('History'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('body_1')), findsOneWidget);

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('body_2')), findsOneWidget);
  });
}

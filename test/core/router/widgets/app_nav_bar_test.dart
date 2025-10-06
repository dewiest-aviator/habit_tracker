import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:habit_tracker/core/router/widgets/app_nav_bar.dart';
import 'package:habit_tracker/l10n/app_localizations.dart';

class _NavPage extends StatelessWidget {
  const _NavPage({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title, key: ValueKey('app_bar_$title'))),
      body: Center(child: Text(title, key: ValueKey('body_$title'))),
    );
  }
}

void main() {
  late GoRouter router;

  setUp(() {
    router = GoRouter(
      initialLocation: '/',
      routes: [
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) => Scaffold(
            body: navigationShell,
            bottomNavigationBar: AppNavBar(navigationShell: navigationShell),
          ),
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/',
                  builder: (context, state) =>
                      const _NavPage(title: 'Home screen'),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/history',
                  builder: (context, state) =>
                      const _NavPage(title: 'History screen'),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/settings',
                  builder: (context, state) =>
                      const _NavPage(title: 'Settings screen'),
                ),
              ],
            ),
          ],
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
    expect(find.byKey(const ValueKey('body_Home screen')), findsOneWidget);

    await tester.tap(find.text('History'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('body_History screen')), findsOneWidget);

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('body_Settings screen')), findsOneWidget);
  });
}

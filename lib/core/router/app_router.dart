import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:habit_tracker/core/router/widgets/app_nav_bar.dart';
import 'package:habit_tracker/features/habits/presentation/screens/habit_form_screen.dart';
import 'package:habit_tracker/features/habits/presentation/screens/history_screen.dart';
import 'package:habit_tracker/features/habits/presentation/screens/home_screen.dart';
import 'package:habit_tracker/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:habit_tracker/features/settings/presentation/screens/settings_screen.dart';

GoRouter createAppRouter({
  List<NavigatorObserver> observers = const [],
  GlobalKey<NavigatorState>? navigatorKey,
  bool hasCompletedOnboarding = true,
}) {
  final rootKey = navigatorKey ?? GlobalKey<NavigatorState>();

  return GoRouter(
    navigatorKey: rootKey,
    initialLocation: hasCompletedOnboarding ? '/' : '/onboarding',
    observers: observers,
    routes: [
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => _AppShell(
          navigationShell: navigationShell,
        ),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                name: 'home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/history',
                name: 'history',
                builder: (context, state) => const HistoryScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                name: 'settings',
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        parentNavigatorKey: rootKey,
        path: '/habit_form',
        name: 'habit_form',
        builder: (context, state) {
          final habitId =
              state.extra as String? ?? state.uri.queryParameters['habitId'];
          return HabitFormScreen(habitId: habitId);
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Not found')),
      body: Center(child: Text(state.error.toString())),
    ),
  );
}

class _AppShell extends StatelessWidget {
  const _AppShell({required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: AppNavBar(navigationShell: navigationShell),
    );
  }
}

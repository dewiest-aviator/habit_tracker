import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
  return GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: hasCompletedOnboarding ? '/' : '/onboarding',
    observers: observers,
    routes: [
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/history',
        name: 'history',
        builder: (context, state) => const HistoryScreen(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
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

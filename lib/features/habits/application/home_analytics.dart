import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/analytics_service.dart';
import '../domain/domain.dart';
import 'home_state.dart';

@immutable
class HomeAnalytics {
  const HomeAnalytics();

  Future<void> logView({
    required int totalHabits,
    required int completedHabits,
    required bool isEmpty,
  }) {
    return AnalyticsService.logEvent(
      'home_view',
      parameters: {
        'total_habits': totalHabits,
        'completed_habits': completedHabits,
        'is_empty': isEmpty ? 1 : 0,
      },
    );
  }

  Future<void> logToggle(Habit habit, bool completed) {
    return AnalyticsService.logEvent(
      'home_toggle_habit',
      parameters: {
        'habit_hash': _hashId(habit.id),
        'completed': completed ? 1 : 0,
      },
    );
  }

  Future<void> logRefresh(HomeState state) {
    return AnalyticsService.logEvent(
      'home_refresh',
      parameters: {
        'total_habits': state.habits.length,
        'completed_habits': state.completedCount,
      },
    );
  }

  Future<void> logAddHabitTap() {
    return AnalyticsService.logEvent('home_add_habit_tap');
  }

  Future<void> logAddHabitLimitReached(int totalHabits) {
    return AnalyticsService.logEvent(
      'home_add_habit_limit',
      parameters: {'total_habits': totalHabits},
    );
  }

  Future<void> logHabitActionsOpen(Habit habit) {
    return AnalyticsService.logEvent(
      'home_habit_actions_open',
      parameters: {'habit_hash': _hashId(habit.id)},
    );
  }

  Future<void> logHabitActionSelected(
    Habit habit, {
    required String action,
  }) {
    return AnalyticsService.logEvent(
      'home_habit_action_select',
      parameters: {
        'habit_hash': _hashId(habit.id),
        'action': action,
      },
    );
  }

  String _hashId(String id) {
    final digest = sha1.convert(utf8.encode(id));
    return digest.toString().substring(0, 12);
  }
}

final homeAnalyticsProvider = Provider<HomeAnalytics>((ref) {
  return const HomeAnalytics();
});

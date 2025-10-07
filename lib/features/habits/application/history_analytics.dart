import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/analytics_service.dart';
import '../domain/domain.dart';

@immutable
class HistoryAnalytics {
  const HistoryAnalytics();

  Future<void> logView({required int dateRangeDays, required int totalHabits}) {
    return AnalyticsService.logEvent(
      'history_view',
      parameters: {
        'date_range_days': dateRangeDays,
        'total_habits': totalHabits,
      },
    );
  }

  Future<void> logEmptyState({required int totalHabits}) {
    return AnalyticsService.logEvent(
      'history_empty_state_shown',
      parameters: {'total_habits': totalHabits},
    );
  }

  Future<void> logDaySelect({
    required DateTime date,
    required double completionRate,
    int? streakOnDate,
  }) {
    return AnalyticsService.logEvent(
      'history_day_select',
      parameters: {
        'date': date.toIso8601String().substring(0, 10),
        'completion_rate': completionRate,
        if (streakOnDate != null) 'streak_on_date': streakOnDate,
      },
    );
  }

  Future<void> logScrollRange({
    required int daysLoaded,
    required String direction,
  }) {
    return AnalyticsService.logEvent(
      'history_scroll_range',
      parameters: {'days_loaded': daysLoaded, 'direction': direction},
    );
  }

  Future<void> logFilterToggle(Habit habit) {
    return AnalyticsService.logEvent(
      'history_filter_toggle',
      parameters: {
        'habit_hash': _hashHabitId(habit.id),
        'emoji': habit.emoji,
        'color_hex': _colorHex(habit.color),
      },
    );
  }

  Future<void> logStreakSummary({
    required int bestStreak,
    required int currentStreak,
  }) {
    return AnalyticsService.logEvent(
      'history_streak_summary_shown',
      parameters: {'best_streak': bestStreak, 'current_streak': currentStreak},
    );
  }

  static String _hashHabitId(String id) {
    final digest = sha1.convert(utf8.encode(id));
    return digest.toString().substring(0, 12);
  }

  static String _colorHex(int color) {
    return color.toRadixString(16).padLeft(8, '0');
  }
}

final historyAnalyticsProvider = Provider<HistoryAnalytics>((ref) {
  return const HistoryAnalytics();
});

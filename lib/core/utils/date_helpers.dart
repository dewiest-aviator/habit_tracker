import 'package:flutter/foundation.dart';

/// Utility helpers for working with dates in the application.
@immutable
class DateHelpers {
  const DateHelpers._();

  /// Normalizes the provided [date] to the start of the day in the local
  /// timezone.
  static DateTime startOfDay(DateTime date) {
    final local = date.toLocal();
    return DateTime(local.year, local.month, local.day);
  }

  /// Returns the exclusive start of the next day from [date].
  static DateTime nextDayStart(DateTime date) {
    return startOfDay(date).add(const Duration(days: 1));
  }

  /// Returns `true` when [a] and [b] fall on the same calendar day.
  static bool isSameDay(DateTime a, DateTime b) {
    final first = startOfDay(a);
    final second = startOfDay(b);
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }

  /// Maps the provided [date] to the app's weekday index where Monday = 0 and
  /// Sunday = 6.
  static int weekdayIndex(DateTime date) {
    final weekday = startOfDay(date).weekday; // Monday = 1, Sunday = 7
    return (weekday + 6) % 7;
  }

  /// Returns the duration until the next day begins relative to [date].
  static Duration timeUntilNextDay(DateTime date) {
    final now = date.toLocal();
    final nextDay = nextDayStart(now);
    return nextDay.difference(now);
  }
}

import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/core/utils/date_helpers.dart';

void main() {
  group('DateHelpers', () {
    test('startOfDay normalizes to midnight', () {
      final date = DateTime(2024, 4, 12, 18, 30, 45);
      final normalized = DateHelpers.startOfDay(date);

      expect(normalized.hour, 0);
      expect(normalized.minute, 0);
      expect(normalized.second, 0);
      expect(normalized.millisecond, 0);
    });

    test('isSameDay compares only date components', () {
      final first = DateTime(2024, 5, 1, 8, 0);
      final second = DateTime(2024, 5, 1, 23, 59, 59);
      final third = DateTime(2024, 5, 2);

      expect(DateHelpers.isSameDay(first, second), isTrue);
      expect(DateHelpers.isSameDay(first, third), isFalse);
    });

    test('weekdayIndex maps Monday to 0 and Sunday to 6', () {
      expect(DateHelpers.weekdayIndex(DateTime(2024, 6, 3)), 0); // Monday
      expect(DateHelpers.weekdayIndex(DateTime(2024, 6, 9)), 6); // Sunday
    });

    test('timeUntilNextDay returns duration until midnight', () {
      final now = DateTime(2024, 8, 20, 22, 30);
      final remaining = DateHelpers.timeUntilNextDay(now);

      expect(remaining, const Duration(hours: 1, minutes: 30));
    });

    test('nextDayStart returns the following midnight', () {
      final date = DateTime(2024, 1, 15, 23, 59);
      final next = DateHelpers.nextDayStart(date);

      expect(next, DateTime(2024, 1, 16));
    });
  });
}

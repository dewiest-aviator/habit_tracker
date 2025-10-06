import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/habit_entries_repository.dart';
import '../domain.dart';
import '../../../../core/utils/date_helpers.dart';

class ComputeStreaks {
  ComputeStreaks({
    required HabitEntriesRepository habitEntriesRepository,
    DateTime Function()? clock,
  }) : _habitEntriesRepository = habitEntriesRepository,
       _clock = clock ?? DateTime.now;

  final HabitEntriesRepository _habitEntriesRepository;
  final DateTime Function() _clock;

  Future<HabitStreaks> call(String habitId) async {
    final entries = await _habitEntriesRepository.fetchEntries(
      habitId: habitId,
    );
    if (entries.isEmpty) {
      return const HabitStreaks(current: 0, best: 0);
    }

    final doneDates = entries
        .where((entry) => entry.done)
        .map((entry) => DateHelpers.startOfDay(entry.date))
        .toSet();

    if (doneDates.isEmpty) {
      return const HabitStreaks(current: 0, best: 0);
    }

    final today = DateHelpers.startOfDay(_clock());

    var current = 0;
    final remainingDates = Set<DateTime>.from(doneDates);
    var cursor = today;
    while (remainingDates.remove(cursor)) {
      current += 1;
      cursor = cursor.subtract(const Duration(days: 1));
    }

    final orderedDates = doneDates.toList()..sort();
    var best = 0;
    var streak = 0;
    DateTime? previous;

    for (final date in orderedDates) {
      if (previous == null) {
        streak = 1;
      } else {
        final difference = date.difference(previous).inDays;
        if (difference == 0) {
          // Ignore duplicates on the same day.
          continue;
        }
        if (difference == 1) {
          streak += 1;
        } else {
          streak = 1;
        }
      }
      best = math.max(best, streak);
      previous = date;
    }

    return HabitStreaks(current: current, best: best);
  }
}

final computeStreaksProvider = Provider<ComputeStreaks>((ref) {
  final entriesRepository = ref.watch(habitEntriesRepositoryProvider);
  return ComputeStreaks(habitEntriesRepository: entriesRepository);
});

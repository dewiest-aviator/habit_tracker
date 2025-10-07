import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/l10n_extensions.dart';
import '../../../../core/utils/date_helpers.dart';
import '../../application/history_controller.dart';
import '../../application/history_state.dart';
import '../widgets/habit_day_list.dart';
import '../widgets/history_empty_state.dart';
import '../widgets/week_strip.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<HistoryState>(historyControllerProvider, (previous, next) {
      if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(next.errorMessage!)));
      }
    });

    final state = ref.watch(historyControllerProvider);
    final controller = ref.read(historyControllerProvider.notifier);
    final l10n = context.l10n;

    final selectedDay = state.dayFor(state.selectedDate);
    final accentColor = _resolveAccentColor(state);

    if (state.isLoading && state.days.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.historyTitle)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (state.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.historyTitle)),
        body: const HistoryEmptyState(),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.historyTitle),
        bottom: state.isLoading
            ? const PreferredSize(
                preferredSize: Size.fromHeight(2),
                child: LinearProgressIndicator(minHeight: 2),
              )
            : null,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.historyStreakHeading,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                _HistoryStreakCard(summary: state.streakSummary),
                if (state.habits.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _HistoryFilter(
                    state: state,
                    onChanged: (value) => controller.applyHabitFilter(value),
                  ),
                ],
              ],
            ),
          ),
          WeekStrip(
            days: state.days,
            selectedDate: state.selectedDate,
            accentColor: accentColor,
            onSelect: (date) {
              HapticFeedback.lightImpact();
              controller.selectDate(date);
              final difference = state.rangeEnd
                  .difference(DateHelpers.startOfDay(date))
                  .inDays;
              if (difference >= 7) {
                controller.reportScroll(HistoryScrollDirection.backward);
              }
            },
          ),
          const SizedBox(height: 16),
          Expanded(
            child: HabitDayList(
              date: state.selectedDate,
              day: selectedDay,
              isLoading: state.isLoading,
            ),
          ),
        ],
      ),
    );
  }

  Color? _resolveAccentColor(HistoryState state) {
    final filterId = state.filterHabitId;
    if (filterId == null) {
      return null;
    }
    for (final habit in state.habits) {
      if (habit.id == filterId) {
        return Color(habit.color);
      }
    }
    return null;
  }
}

class _HistoryStreakCard extends StatelessWidget {
  const _HistoryStreakCard({required this.summary});

  final HistoryStreakSummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            _StreakMetric(
              label: l10n.historyStreakBest,
              value: summary.bestStreak,
              habitName: summary.bestHabit?.name,
            ),
            const SizedBox(width: 24),
            _StreakMetric(
              label: l10n.historyStreakCurrent,
              value: summary.currentStreak,
              habitName: summary.currentHabit?.name,
            ),
          ],
        ),
      ),
    );
  }
}

class _StreakMetric extends StatelessWidget {
  const _StreakMetric({
    required this.label,
    required this.value,
    required this.habitName,
  });

  final String label;
  final int value;
  final String? habitName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtitle = habitName ?? '';

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value.toString(),
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _HistoryFilter extends StatelessWidget {
  const _HistoryFilter({required this.state, required this.onChanged});

  final HistoryState state;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final options = <DropdownMenuItem<String?>>[
      DropdownMenuItem<String?>(
        value: null,
        child: Text(l10n.historyFilterAll),
      ),
      ...state.habits.map(
        (habit) => DropdownMenuItem<String?>(
          value: habit.id,
          child: Text('${habit.emoji} ${habit.name}'),
        ),
      ),
    ];

    return DropdownButtonFormField<String?>(
      key: ValueKey(state.filterHabitId ?? 'all'),
      initialValue: state.filterHabitId,
      decoration: InputDecoration(
        labelText: l10n.historyFilterLabel,
        border: const OutlineInputBorder(),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
      ),
      items: options,
      onChanged: onChanged,
    );
  }
}

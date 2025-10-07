import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/localization/l10n_extensions.dart';
import '../../application/history_state.dart';

class HabitDayList extends StatelessWidget {
  const HabitDayList({
    super.key,
    required this.date,
    required this.day,
    required this.isLoading,
  });

  final DateTime date;
  final HistoryDayViewData? day;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final dateLabel = DateFormat.yMMMMEEEEd(l10n.localeName).format(date);
    final completed = day?.completedCount ?? 0;
    final total = day?.totalCount ?? 0;
    final habits = day?.habits ?? const <HistoryHabitViewData>[];
    final children = <Widget>[
      _HistoryDayHeader(
        dateLabel: dateLabel,
        summary: l10n.historyCompletionLabel(completed, total),
      ),
      const SizedBox(height: 16),
    ];

    if (isLoading && habits.isEmpty) {
      children.add(const Center(child: CircularProgressIndicator()));
    } else if (habits.isEmpty) {
      children.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: Text(
            l10n.historyNoHabitsForDay,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    } else {
      for (var i = 0; i < habits.length; i += 1) {
        final habit = habits[i];
        children.add(_HistoryHabitTile(data: habit));
        if (i != habits.length - 1) {
          children.add(const SizedBox(height: 12));
        }
      }
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      children: children,
    );
  }
}

class _HistoryDayHeader extends StatelessWidget {
  const _HistoryDayHeader({required this.dateLabel, required this.summary});

  final String dateLabel;
  final String summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          dateLabel,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          summary,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _HistoryHabitTile extends StatelessWidget {
  const _HistoryHabitTile({required this.data});

  final HistoryHabitViewData data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = data.status;

    IconData icon;
    Color color;

    switch (status) {
      case HistoryHabitStatus.completed:
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      case HistoryHabitStatus.missed:
        icon = Icons.cancel_rounded;
        color = theme.colorScheme.error;
        break;
      case HistoryHabitStatus.pending:
        icon = Icons.schedule_rounded;
        color = theme.colorScheme.primary;
        break;
    }

    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      child: ListTile(
        leading: Text(data.habit.emoji, style: theme.textTheme.headlineMedium),
        title: Text(
          data.habit.name,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: Icon(icon, color: color),
      ),
    );
  }
}

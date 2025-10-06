import 'package:flutter/material.dart';
import 'package:habit_tracker/core/localization/l10n_extensions.dart';

class HomeProgressSummary extends StatelessWidget {
  const HomeProgressSummary({
    super.key,
    required this.completed,
    required this.total,
  });

  final int completed;
  final int total;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.homeTodayHeadline, style: theme.textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text(
          l10n.homeProgressSummary(completed, total),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

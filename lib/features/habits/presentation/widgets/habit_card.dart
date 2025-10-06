import 'package:flutter/material.dart';
import 'package:habit_tracker/core/localization/l10n_extensions.dart';

import '../../application/home_state.dart';

class HabitCard extends StatelessWidget {
  const HabitCard({
    super.key,
    required this.data,
    required this.onToggle,
    this.onLongPress,
  });

  final HomeHabitViewData data;
  final VoidCallback onToggle;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseColor = Color(data.habit.color);
    final backgroundColor = baseColor.withValues(alpha: 0.12);
    final completedColor = baseColor.withValues(alpha: 0.22);
    final textTheme = theme.textTheme;
    final isCompleted = data.isCompleted;
    final tintColor = isCompleted ? baseColor : theme.colorScheme.outline;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: Key('habit_card_${data.habit.id}'),
        borderRadius: BorderRadius.circular(16),
        onTap: onToggle,
        onLongPress: onLongPress,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: isCompleted ? completedColor : backgroundColor,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(data.habit.emoji, style: textTheme.headlineMedium),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      data.habit.name,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  Tooltip(
                    message: isCompleted
                        ? context.l10n.homeMarkIncompleteTooltip
                        : context.l10n.homeMarkCompleteTooltip,
                    child: IconButton(
                      icon: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 150),
                        child: Icon(
                          isCompleted
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          key: ValueKey<bool>(isCompleted),
                          color: tintColor,
                          size: 28,
                        ),
                      ),
                      onPressed: onToggle,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _StreakRow(
                current: data.habit.currentStreak,
                best: data.habit.bestStreak,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StreakRow extends StatelessWidget {
  const _StreakRow({required this.current, required this.best});

  final int current;
  final int best;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Row(
      children: [
        _StreakChip(
          icon: Icons.local_fire_department,
          label: l10n.homeCurrentStreakLabel(current),
        ),
        const SizedBox(width: 12),
        _StreakChip(
          icon: Icons.emoji_events_outlined,
          label: l10n.homeBestStreakLabel(best),
        ),
      ],
    );
  }
}

class _StreakChip extends StatelessWidget {
  const _StreakChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.primaryContainer.withValues(alpha: 0.4);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Text(label, style: theme.textTheme.labelLarge),
        ],
      ),
    );
  }
}

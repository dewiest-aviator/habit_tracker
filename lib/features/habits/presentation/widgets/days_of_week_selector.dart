import 'package:flutter/material.dart';

typedef DaysChangedCallback = void Function(List<int> days);

class DaysOfWeekSelector extends StatelessWidget {
  const DaysOfWeekSelector({
    super.key,
    required this.label,
    required this.selectedDays,
    required this.onChanged,
    this.helperText,
    this.errorText,
  });

  final String label;
  final List<int> selectedDays;
  final DaysChangedCallback onChanged;
  final String? helperText;
  final String? errorText;

  static const List<int> _dayOrder = <int>[0, 1, 2, 3, 4, 5, 6];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = MaterialLocalizations.of(context);
    final narrowWeekdays = localizations.narrowWeekdays;

    String labelForDay(int index) {
      final weekday = index + 1;
      final localizationIndex = weekday == DateTime.sunday ? 0 : weekday;
      return narrowWeekdays[localizationIndex];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.titleMedium),
        if (helperText != null) ...[
          const SizedBox(height: 4),
          Text(helperText!, style: theme.textTheme.bodySmall),
        ],
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: [
            for (final day in _dayOrder)
              FilterChip(
                label: Text(labelForDay(day)),
                selected: selectedDays.contains(day),
                onSelected: (selected) {
                  final updated = selected
                      ? {...selectedDays, day}
                      : selectedDays.where((element) => element != day).toSet();
                  onChanged(updated.toList()..sort());
                },
              ),
          ],
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              errorText!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
      ],
    );
  }
}

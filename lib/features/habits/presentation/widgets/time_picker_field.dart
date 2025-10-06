import 'package:flutter/material.dart';

typedef TimeChangedCallback = void Function(String time);

class TimePickerField extends StatelessWidget {
  const TimePickerField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.helperText,
    this.errorText,
    this.onPickerOpened,
  });

  final String label;
  final String value;
  final TimeChangedCallback onChanged;
  final String? helperText;
  final String? errorText;
  final VoidCallback? onPickerOpened;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = MaterialLocalizations.of(context);
    final parsed = _parseTime(value) ?? const TimeOfDay(hour: 8, minute: 0);
    final formatted = localizations.formatTimeOfDay(parsed);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.titleMedium),
        if (helperText != null) ...[
          const SizedBox(height: 4),
          Text(helperText!, style: theme.textTheme.bodySmall),
        ],
        const SizedBox(height: 8),
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(56),
          ),
          onPressed: () => _pickTime(context),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(formatted, style: theme.textTheme.titleMedium),
          ),
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

  Future<void> _pickTime(BuildContext context) async {
    onPickerOpened?.call();
    final initial = _parseTime(value) ?? const TimeOfDay(hour: 8, minute: 0);
    final selected = await showTimePicker(
      context: context,
      initialTime: initial,
    );
    if (selected != null) {
      onChanged(_formatTime(selected));
    }
  }

  static TimeOfDay? _parseTime(String value) {
    final parts = value.split(':');
    if (parts.length != 2) {
      return null;
    }
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) {
      return null;
    }
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) {
      return null;
    }
    return TimeOfDay(hour: hour, minute: minute);
  }

  static String _formatTime(TimeOfDay time) {
    final hours = time.hour.toString().padLeft(2, '0');
    final minutes = time.minute.toString().padLeft(2, '0');
    return '$hours:$minutes';
  }
}

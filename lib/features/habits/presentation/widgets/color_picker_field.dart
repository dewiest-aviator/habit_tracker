import 'package:flutter/material.dart';

typedef ColorSelectedCallback = void Function(int color);

class ColorPickerField extends StatelessWidget {
  const ColorPickerField({
    super.key,
    required this.label,
    required this.value,
    required this.colors,
    required this.onChanged,
    this.errorText,
    this.description,
    this.onPickerOpened,
  });

  final String label;
  final int value;
  final List<int> colors;
  final ColorSelectedCallback onChanged;
  final String? errorText;
  final String? description;
  final VoidCallback? onPickerOpened;

  Future<void> _openPicker(BuildContext context) async {
    onPickerOpened?.call();
    final selected = await showModalBottomSheet<int>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        final theme = Theme.of(context);
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                for (final color in colors)
                  _ColorOption(
                    color: color,
                    isSelected: color == value,
                    onTap: () => Navigator.of(context).pop(color),
                    theme: theme,
                  ),
              ],
            ),
          ),
        );
      },
    );

    if (selected != null) {
      onChanged(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.titleMedium),
        if (description != null) ...[
          const SizedBox(height: 4),
          Text(description!, style: theme.textTheme.bodySmall),
        ],
        const SizedBox(height: 8),
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(56),
          ),
          onPressed: () => _openPicker(context),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _ColorDot(color: Color(value)),
              const SizedBox(width: 12),
              Text('#${value.toRadixString(16).padLeft(8, '0').toUpperCase()}'),
            ],
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
}

class _ColorOption extends StatelessWidget {
  const _ColorOption({
    required this.color,
    required this.isSelected,
    required this.onTap,
    required this.theme,
  });

  final int color;
  final bool isSelected;
  final VoidCallback onTap;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isSelected,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Color(color),
            border: Border.all(
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.surfaceContainerHighest,
              width: isSelected ? 3 : 1,
            ),
          ),
        ),
      ),
    );
  }
}

class _ColorDot extends StatelessWidget {
  const _ColorDot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        border: Border.all(color: theme.dividerColor),
      ),
    );
  }
}

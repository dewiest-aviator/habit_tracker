import 'package:flutter/material.dart';

typedef EmojiSelectedCallback = void Function(String emoji);

class EmojiPickerField extends StatelessWidget {
  const EmojiPickerField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.errorText,
    this.placeholder,
    this.onPickerOpened,
  });

  final String label;
  final String value;
  final EmojiSelectedCallback onChanged;
  final String? errorText;
  final String? placeholder;
  final VoidCallback? onPickerOpened;

  static const List<String> _defaultEmojis = <String>[
    '🌱',
    '💧',
    '🏃',
    '🧘',
    '📚',
    '✍️',
    '💤',
    '🍎',
    '💪',
    '🎧',
    '🪴',
    '😊',
  ];

  Future<void> _showPicker(BuildContext context) async {
    onPickerOpened?.call();
    final theme = Theme.of(context);
    final selected = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: GridView.builder(
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: _defaultEmojis.length,
              itemBuilder: (context, index) {
                final emoji = _defaultEmojis[index];
                final isSelected = emoji == value;
                return Semantics(
                  button: true,
                  selected: isSelected,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => Navigator.of(context).pop(emoji),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? theme.colorScheme.primary.withAlpha(
                                (0.12 * 255).round(),
                              )
                            : theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.dividerColor,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(emoji, style: const TextStyle(fontSize: 28)),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );

    if (selected != null && selected.isNotEmpty) {
      onChanged(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayValue = value.isEmpty ? (placeholder ?? '') : value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(56),
          ),
          onPressed: () => _showPicker(context),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              displayValue.isEmpty ? '🙂' : displayValue,
              style: const TextStyle(fontSize: 28),
            ),
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

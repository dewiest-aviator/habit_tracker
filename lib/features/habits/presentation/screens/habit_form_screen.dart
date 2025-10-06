import 'package:flutter/material.dart';
import 'package:habit_tracker/core/localization/l10n_extensions.dart';

class HabitFormScreen extends StatelessWidget {
  const HabitFormScreen({super.key, this.habitId});

  final String? habitId;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isEditing = habitId != null && habitId!.isNotEmpty;

    final title = isEditing
        ? l10n.habitFormEditTitle
        : l10n.habitFormCreateTitle;
    final message = isEditing
        ? l10n.habitFormEditPlaceholder
        : l10n.habitFormCreatePlaceholder;

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            message,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

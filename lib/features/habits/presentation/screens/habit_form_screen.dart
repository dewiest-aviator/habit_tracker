import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/l10n_extensions.dart';
import '../../application/habit_form_controller.dart';
import '../../application/habit_form_state.dart';
import '../widgets/color_picker_field.dart';
import '../widgets/days_of_week_selector.dart';
import '../widgets/emoji_picker_field.dart';
import '../widgets/time_picker_field.dart';

class HabitFormScreen extends ConsumerStatefulWidget {
  const HabitFormScreen({super.key, this.habitId});

  final String? habitId;

  @override
  ConsumerState<HabitFormScreen> createState() => _HabitFormScreenState();
}

class _HabitFormScreenState extends ConsumerState<HabitFormScreen> {
  late final TextEditingController _nameController;

  static const List<int> _colorOptions = <int>[
    0xFF4F46E5,
    0xFF0EA5E9,
    0xFFF97316,
    0xFF10B981,
    0xFFE11D48,
    0xFFF59E0B,
    0xFF8B5CF6,
    0xFF2DD4BF,
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final habitId = widget.habitId;
    final provider = habitFormControllerProvider(habitId);
    final state = ref.watch(provider);
    final notifier = ref.read(provider.notifier);

    ref.listen<HabitFormState>(provider, (previous, next) {
      if (previous?.name != next.name && _nameController.text != next.name) {
        _nameController.value = TextEditingValue(
          text: next.name,
          selection: TextSelection.collapsed(offset: next.name.length),
        );
      }

      final previousError = previous?.errorMessage;
      final nextError = next.errorMessage;
      if (nextError != null && nextError != previousError) {
        final message = _mapErrorMessage(context, nextError);
        if (message != null) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(message)));
        }
      }
    });

    final canNavigateBack =
        !state.hasChanges || state.isSaving || state.isDeleting;

    return PopScope(
      canPop: canNavigateBack,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop || canNavigateBack) {
          return;
        }
        final shouldLeave = await _confirmExit(context, state);
        if (shouldLeave && context.mounted) {
          Navigator.of(context).pop(result);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            state.isEditMode
                ? l10n.habitFormEditTitle
                : l10n.habitFormCreateTitle,
          ),
          actions: [
            if (state.isEditMode && !state.isLoading)
              IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: l10n.habitFormDeleteTooltip,
                onPressed: state.isDeleting
                    ? null
                    : () => _confirmDelete(context, notifier, state),
              ),
          ],
        ),
        body: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : SafeArea(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    EmojiPickerField(
                      label: l10n.habitFormEmojiLabel,
                      placeholder: l10n.habitFormEmojiPlaceholder,
                      value: state.emoji,
                      errorText: _validationMessage(
                        context,
                        'emoji',
                        state.errors.emoji,
                      ),
                      onPickerOpened: notifier.recordEmojiPickerOpen,
                      onChanged: notifier.setEmoji,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _nameController,
                      textInputAction: TextInputAction.next,
                      maxLength: 32,
                      maxLengthEnforcement: MaxLengthEnforcement.enforced,
                      decoration: InputDecoration(
                        labelText: l10n.habitFormNameLabel,
                        helperText: l10n.habitFormNameHelper,
                        errorText: _validationMessage(
                          context,
                          'name',
                          state.errors.name,
                        ),
                        counterText: '',
                      ),
                      onChanged: notifier.setName,
                    ),
                    const SizedBox(height: 16),
                    ColorPickerField(
                      label: l10n.habitFormColorLabel,
                      description: l10n.habitFormColorDescription,
                      value: state.color,
                      colors: _colorOptions,
                      onChanged: notifier.setColor,
                      onPickerOpened: notifier.recordColorPickerOpen,
                    ),
                    const SizedBox(height: 16),
                    DaysOfWeekSelector(
                      label: l10n.habitFormDaysLabel,
                      helperText: l10n.habitFormDaysHelper,
                      selectedDays: state.days,
                      errorText: _validationMessage(
                        context,
                        'days',
                        state.errors.days,
                      ),
                      onChanged: notifier.setDays,
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile.adaptive(
                      value: state.reminderEnabled,
                      onChanged: state.isSaving || state.isDeleting
                          ? null
                          : (value) => notifier.setReminderEnabled(value),
                      title: Text(l10n.habitFormReminderLabel),
                      subtitle: Text(l10n.habitFormReminderSubtitle),
                    ),
                    if (state.showReminderTime) ...[
                      const SizedBox(height: 8),
                      TimePickerField(
                        label: l10n.habitFormReminderTimeLabel,
                        helperText: l10n.habitFormReminderTimeHelper,
                        value: state.reminderTime,
                        errorText: _validationMessage(
                          context,
                          'reminder_time',
                          state.errors.reminderTime,
                        ),
                        onChanged: notifier.setReminderTime,
                      ),
                    ],
                    const SizedBox(height: 24),
                    if (state.errors.limit != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          _validationMessage(
                                context,
                                'limit',
                                state.errors.limit,
                              ) ??
                              '',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.error,
                              ),
                        ),
                      ),
                    FilledButton(
                      onPressed:
                          state.isSaving || state.isDeleting || !state.canSubmit
                          ? null
                          : () => _handleSave(context, notifier, state),
                      child: state.isSaving
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                            )
                          : Text(
                              state.isEditMode
                                  ? l10n.habitFormSaveChanges
                                  : l10n.habitFormCreateHabit,
                            ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Future<void> _handleSave(
    BuildContext context,
    HabitFormController notifier,
    HabitFormState state,
  ) async {
    FocusScope.of(context).unfocus();
    final result = await notifier.submit(
      reminderStrings: _buildReminderStrings(context, state),
    );

    switch (result.status) {
      case HabitFormSaveStatus.success:
        if (!context.mounted) return;
        Navigator.of(context).pop(result);
        break;
      case HabitFormSaveStatus.limitReached:
      case HabitFormSaveStatus.validationFailed:
        break;
      case HabitFormSaveStatus.failure:
        if (!context.mounted) return;
        if (result.message != null) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(result.message!)));
        }
        break;
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    HabitFormController notifier,
    HabitFormState state,
  ) async {
    notifier.recordDeleteTap();
    final l10n = context.l10n;
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.habitFormDeleteConfirmTitle),
          content: Text(l10n.habitFormDeleteConfirmMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.habitFormDeleteCancel),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.habitFormDeleteConfirmAction),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) {
      return;
    }

    final result = await notifier.deleteHabit();
    if (!context.mounted) return;
    switch (result.status) {
      case HabitFormDeleteStatus.deleted:
        Navigator.of(context).pop(result);
        break;
      case HabitFormDeleteStatus.notAllowed:
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(l10n.habitFormDeleteError)));
        break;
      case HabitFormDeleteStatus.failure:
        final message = result.message ?? l10n.habitFormDeleteError;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(message)));
        break;
    }
  }

  Future<bool> _confirmExit(BuildContext context, HabitFormState state) async {
    if (!state.hasChanges || state.isSaving || state.isDeleting) {
      return true;
    }

    final l10n = context.l10n;
    final shouldDiscard = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.habitFormDiscardTitle),
          content: Text(l10n.habitFormDiscardMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.habitFormDiscardCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.habitFormDiscardConfirm),
            ),
          ],
        );
      },
    );

    return shouldDiscard ?? false;
  }

  HabitReminderStrings _buildReminderStrings(
    BuildContext context,
    HabitFormState state,
  ) {
    final l10n = context.l10n;
    final emoji = state.emoji.isEmpty ? '🌱' : state.emoji;
    final name = state.name.trim().isEmpty
        ? l10n.habitFormReminderFallbackName
        : state.name.trim();
    return HabitReminderStrings(
      title: l10n.habitFormReminderTitle(emoji, name),
      body: l10n.habitFormReminderBody(name),
    );
  }

  String? _validationMessage(BuildContext context, String field, String? code) {
    if (code == null) return null;
    final l10n = context.l10n;
    switch (field) {
      case 'name':
        if (code == 'required') return l10n.habitFormNameRequiredError;
        if (code == 'length') return l10n.habitFormNameLengthError;
        return null;
      case 'emoji':
        return l10n.habitFormEmojiRequiredError;
      case 'days':
        return l10n.habitFormDaysError;
      case 'reminder_time':
        return l10n.habitFormReminderTimeError;
      case 'limit':
        return l10n.habitFormLimitError;
    }
    return null;
  }

  String? _mapErrorMessage(BuildContext context, String code) {
    final l10n = context.l10n;
    switch (code) {
      case 'notifications_denied':
        return l10n.habitFormReminderPermissionDenied;
      default:
        return code;
    }
  }
}

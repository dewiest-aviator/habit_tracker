import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/services/analytics_service.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/utils/date_helpers.dart';
import '../data/repositories/habit_entries_repository.dart';
import '../data/repositories/habits_repository.dart';
import '../domain/domain.dart';
import 'habit_form_state.dart';

class HabitReminderStrings {
  const HabitReminderStrings({required this.title, required this.body});

  final String title;
  final String body;
}

class HabitFormAnalytics {
  const HabitFormAnalytics();

  Future<void> logView({required HabitFormMode mode, required bool prefilled}) {
    return AnalyticsService.logEvent(
      'habit_form_view',
      parameters: {'mode': mode.name, 'prefilled': prefilled ? 1 : 0},
    );
  }

  Future<void> logPrefill({
    required Habit habit,
    required bool reminderEnabled,
  }) {
    return AnalyticsService.logEvent(
      'habit_form_prefill',
      parameters: {
        'habit_hash': _hashHabitId(habit.id),
        'emoji': habit.emoji,
        'color_hex': _colorHex(habit.color),
        'days_count': habit.days.length,
        'reminder_enabled': reminderEnabled ? 1 : 0,
      },
    );
  }

  Future<void> logFieldChange({
    required String field,
    String? valueLength,
    int? daysCount,
    bool? reminderEnabled,
  }) {
    return AnalyticsService.logEvent(
      'habit_form_field_change',
      parameters: {
        'field': field,
        if (valueLength != null) 'value_len': valueLength,
        if (daysCount != null) 'days_count': daysCount,
        if (reminderEnabled != null)
          'reminder_enabled': reminderEnabled ? 1 : 0,
      },
    );
  }

  Future<void> logValidationError({
    required String field,
    required String code,
  }) {
    return AnalyticsService.logEvent(
      'habit_form_validation_error',
      parameters: {'field': field, 'code': code},
    );
  }

  Future<void> logSaveTap({
    required HabitFormMode mode,
    required bool hasChanges,
  }) {
    return AnalyticsService.logEvent(
      'habit_form_save_tap',
      parameters: {'mode': mode.name, 'has_changes': hasChanges ? 1 : 0},
    );
  }

  Future<void> logSaveSuccess({
    required Habit habit,
    required HabitFormMode mode,
    required bool reminderEnabled,
  }) {
    return AnalyticsService.logEvent(
      'habit_form_save_success',
      parameters: {
        'mode': mode.name,
        'habit_hash': _hashHabitId(habit.id),
        'emoji': habit.emoji,
        'color_hex': _colorHex(habit.color),
        'days_count': habit.days.length,
        'reminder_enabled': reminderEnabled ? 1 : 0,
      },
    );
  }

  Future<void> logSaveFail({
    required HabitFormMode mode,
    required String errorCode,
  }) {
    return AnalyticsService.logEvent(
      'habit_form_save_fail',
      parameters: {'mode': mode.name, 'error_code': errorCode},
    );
  }

  Future<void> logDeleteTap(String habitId) {
    return AnalyticsService.logEvent(
      'habit_form_delete_tap',
      parameters: {'habit_hash': _hashHabitId(habitId)},
    );
  }

  Future<void> logDeleteConfirm(String habitId) {
    return AnalyticsService.logEvent(
      'habit_form_delete_confirm',
      parameters: {'habit_hash': _hashHabitId(habitId)},
    );
  }

  Future<void> logReminderPermissionPrompt() {
    return AnalyticsService.logEvent(
      'habit_form_reminder_permission_prompt',
      parameters: {'flow': 'from_form'},
    );
  }

  Future<void> logReminderPermissionResult({required bool granted}) {
    return AnalyticsService.logEvent(
      'habit_form_reminder_permission_result',
      parameters: {'granted': granted ? 1 : 0},
    );
  }

  Future<void> logColorPickerOpen() {
    return AnalyticsService.logEvent('habit_form_color_picker_open');
  }

  Future<void> logEmojiPickerOpen() {
    return AnalyticsService.logEvent('habit_form_emoji_picker_open');
  }

  static String _hashHabitId(String id) {
    final digest = sha1.convert(utf8.encode(id));
    return digest.toString().substring(0, 12);
  }

  static String _colorHex(int color) {
    return color.toRadixString(16).padLeft(8, '0');
  }
}

final habitFormAnalyticsProvider = Provider<HabitFormAnalytics>((ref) {
  return const HabitFormAnalytics();
});

class HabitFormController extends Notifier<HabitFormState> {
  HabitFormController(this._habitId);

  final String? _habitId;

  late final HabitsRepository _habitsRepository;
  late final HabitEntriesRepository _habitEntriesRepository;
  late final NotificationService _notificationService;
  late final HabitFormAnalytics _analytics;
  late final DateTime Function() _clock;
  late final Uuid _uuid;

  Habit? _loadedHabit;
  _HabitFormSnapshot _baseline = _HabitFormSnapshot();

  @override
  HabitFormState build() {
    _habitsRepository = ref.read(habitsRepositoryProvider);
    _habitEntriesRepository = ref.read(habitEntriesRepositoryProvider);
    _notificationService = ref.read(notificationServiceProvider);
    _analytics = ref.read(habitFormAnalyticsProvider);
    _clock = ref.read(habitFormClockProvider);
    _uuid = ref.read(habitFormUuidProvider);

    final mode = _habitId == null ? HabitFormMode.create : HabitFormMode.edit;
    final initialState = HabitFormState.initial(
      mode: mode,
    ).copyWith(habitId: _habitId);
    _baseline = _snapshotFromState(initialState);

    if (_habitId == null) {
      Future<void>.microtask(() {
        if (!ref.mounted) return;
        unawaited(
          _analytics.logView(mode: HabitFormMode.create, prefilled: false),
        );
      });
    } else {
      Future<void>.microtask(() {
        // _habitId is non-null in this branch.
        // ignore: unnecessary_non_null_assertion
        final habitId = _habitId!;
        if (!ref.mounted) return;
        unawaited(_loadHabit(habitId));
      });
    }

    return initialState;
  }

  void setEmoji(String value) {
    final trimmed = value.trim();
    if (trimmed == state.emoji) return;
    _analytics.logFieldChange(field: 'emoji');
    _emit(
      state.copyWith(
        emoji: trimmed,
        errors: state.errors.copyWith(clearEmoji: true),
      ),
    );
  }

  void setName(String value) {
    if (value == state.name) return;
    _analytics.logFieldChange(
      field: 'name',
      valueLength: value.trim().length.toString(),
    );
    _emit(
      state.copyWith(
        name: value,
        errors: state.errors.copyWith(clearName: true),
      ),
    );
  }

  void setColor(int value) {
    if (value == state.color) return;
    _analytics.logFieldChange(field: 'color');
    _emit(state.copyWith(color: value));
  }

  void setDays(List<int> value) {
    final normalized = (value.toSet().toList()..sort());
    if (listEquals(normalized, state.days)) return;
    _analytics.logFieldChange(field: 'days', daysCount: normalized.length);
    _emit(
      state.copyWith(
        days: normalized,
        errors: state.errors.copyWith(clearDays: true),
      ),
    );
  }

  Future<void> setReminderEnabled(bool value) async {
    if (value == state.reminderEnabled) return;
    if (value) {
      await _analytics.logReminderPermissionPrompt();
      final granted = await _notificationService.requestPermission();
      await _analytics.logReminderPermissionResult(granted: granted);
      if (!granted) {
        _emit(
          state.copyWith(
            errors: state.errors.copyWith(reminderTime: null),
            errorMessage: 'notifications_denied',
            hasChanges: state.hasChanges,
          ),
        );
        return;
      }
    }

    _analytics.logFieldChange(
      field: 'reminder_enabled',
      reminderEnabled: value,
    );
    _emit(
      state.copyWith(
        reminderEnabled: value,
        errors: state.errors.copyWith(clearReminderTime: !value),
        clearErrorMessage: true,
      ),
    );
  }

  void setReminderTime(String value) {
    if (value == state.reminderTime) return;
    _analytics.logFieldChange(field: 'reminder_time');
    _emit(
      state.copyWith(
        reminderTime: value,
        errors: state.errors.copyWith(clearReminderTime: true),
      ),
    );
  }

  Future<HabitFormSaveResult> submit({
    required HabitReminderStrings reminderStrings,
  }) async {
    await _analytics.logSaveTap(mode: state.mode, hasChanges: state.hasChanges);

    final validation = _validateInputs();
    if (validation.hasAny) {
      _emit(state.copyWith(errors: validation));
      for (final entry in _mapValidationCodes(validation).entries) {
        await _analytics.logValidationError(
          field: entry.key,
          code: entry.value,
        );
      }
      return HabitFormSaveResult.validationFailed();
    }

    if (state.mode == HabitFormMode.create) {
      final total = await _habitsRepository.countHabits();
      if (total >= HabitsRepository.maxHabitsPerDay) {
        final updatedErrors = state.errors.copyWith(limit: 'habit_limit');
        _emit(state.copyWith(errors: updatedErrors));
        await _analytics.logValidationError(
          field: 'limit',
          code: 'limit_reached',
        );
        return HabitFormSaveResult.limitReached();
      }
    }

    final previousMode = state.mode;
    final previousReminderEnabled = state.reminderEnabled;

    _emit(state.copyWith(isSaving: true, clearErrorMessage: true));

    try {
      final habit = await _persistHabit();
      await _handleNotifications(
        habit: habit,
        reminderStrings: reminderStrings,
      );
      _baseline = _snapshotFromHabit(
        habit,
        reminderEnabled: state.reminderEnabled,
      );
      _emit(
        state.copyWith(
          mode: HabitFormMode.edit,
          isSaving: false,
          errors: const HabitFormErrors(),
          hasChanges: false,
          habitId: habit.id,
        ),
      );
      await _analytics.logSaveSuccess(
        habit: habit,
        mode: previousMode,
        reminderEnabled: previousReminderEnabled,
      );
      return HabitFormSaveResult.success(
        habit: habit,
        isNew: previousMode == HabitFormMode.create,
      );
    } catch (error) {
      await _analytics.logSaveFail(mode: previousMode, errorCode: 'exception');
      _emit(state.copyWith(isSaving: false, errorMessage: error.toString()));
      return HabitFormSaveResult.failure(message: error.toString());
    }
  }

  Future<HabitFormDeleteResult> deleteHabit() async {
    final habitId = state.habitId;
    if (habitId == null) {
      return HabitFormDeleteResult.notAllowed();
    }

    _emit(state.copyWith(isDeleting: true, clearErrorMessage: true));
    try {
      await _habitsRepository.deleteHabit(habitId);
      await _habitEntriesRepository.deleteEntriesForHabit(habitId);
      await _notificationService.cancelHabitReminder(habitId);
      await _analytics.logDeleteConfirm(habitId);
      return HabitFormDeleteResult.deleted();
    } catch (error) {
      _emit(state.copyWith(isDeleting: false, errorMessage: error.toString()));
      return HabitFormDeleteResult.failure(message: error.toString());
    }
  }

  void recordDeleteTap() {
    final habitId = state.habitId;
    if (habitId == null) return;
    unawaited(_analytics.logDeleteTap(habitId));
  }

  void recordColorPickerOpen() {
    unawaited(_analytics.logColorPickerOpen());
  }

  void recordEmojiPickerOpen() {
    unawaited(_analytics.logEmojiPickerOpen());
  }

  HabitFormErrors _validateInputs() {
    HabitFormErrors errors = const HabitFormErrors();

    final trimmedName = state.name.trim();
    if (trimmedName.isEmpty) {
      errors = errors.copyWith(name: 'required');
    } else if (trimmedName.length < 2 || trimmedName.length > 32) {
      errors = errors.copyWith(name: 'length');
    }

    if (state.emoji.trim().isEmpty) {
      errors = errors.copyWith(emoji: 'required');
    }

    if (state.days.isEmpty) {
      errors = errors.copyWith(days: 'empty_days');
    }

    if (state.reminderEnabled && !_isValidTime(state.reminderTime)) {
      errors = errors.copyWith(reminderTime: 'invalid_time');
    }

    return errors;
  }

  Future<Habit> _persistHabit() async {
    final id = _habitId ?? _loadedHabit?.id ?? _generateHabitId();
    final reminderId = _loadedHabit?.reminderId;
    final existing = _loadedHabit;
    final habit = Habit(
      id: id,
      name: state.name.trim(),
      emoji: state.emoji.trim(),
      color: state.color,
      days: state.days,
      reminderId: reminderId ?? id,
      reminderTime: state.reminderEnabled ? state.reminderTime : '',
      bestStreak: existing?.bestStreak ?? 0,
      currentStreak: existing?.currentStreak ?? 0,
      createdAt: existing?.createdAt ?? DateHelpers.startOfDay(_clock()),
      lastChecked: existing?.lastChecked,
    );

    await _habitsRepository.saveHabit(habit);
    _loadedHabit = habit;
    return habit;
  }

  Future<void> _handleNotifications({
    required Habit habit,
    required HabitReminderStrings reminderStrings,
  }) async {
    final shouldSchedule =
        state.reminderEnabled && state.reminderTime.isNotEmpty;
    final reminderChanged =
        _baseline.reminderTime != state.reminderTime ||
        _baseline.reminderEnabled != state.reminderEnabled ||
        !listEquals(_baseline.days, state.days);
    final hadScheduledReminder =
        _baseline.reminderEnabled && _baseline.reminderTime.isNotEmpty;

    if (!shouldSchedule) {
      if (hadScheduledReminder) {
        await _notificationService.cancelHabitReminder(habit.reminderId);
      }
      return;
    }

    if (!reminderChanged && state.mode == HabitFormMode.edit) {
      return;
    }

    if (reminderChanged && hadScheduledReminder) {
      await _notificationService.cancelHabitReminder(habit.reminderId);
    }

    await _notificationService.scheduleHabitReminder(
      habitId: habit.reminderId,
      title: reminderStrings.title,
      body: reminderStrings.body,
      days: state.days,
      time: state.reminderTime,
    );
  }

  Future<void> _loadHabit(String habitId) async {
    try {
      final habit = await _habitsRepository.findById(habitId);
      _loadedHabit = habit;
      if (habit == null) {
        _emit(state.copyWith(isLoading: false));
        await _analytics.logView(mode: HabitFormMode.edit, prefilled: false);
        return;
      }

      final reminderEnabled = habit.reminderTime.isNotEmpty;
      final newState = HabitFormState(
        mode: HabitFormMode.edit,
        habitId: habit.id,
        emoji: habit.emoji,
        name: habit.name,
        color: habit.color,
        days: habit.days,
        reminderEnabled: reminderEnabled,
        reminderTime: reminderEnabled ? habit.reminderTime : '08:00',
        isLoading: false,
      );
      _baseline = _snapshotFromHabit(habit, reminderEnabled: reminderEnabled);
      _emit(newState);
      await _analytics.logView(mode: HabitFormMode.edit, prefilled: true);
      await _analytics.logPrefill(
        habit: habit,
        reminderEnabled: reminderEnabled,
      );
    } catch (error) {
      _emit(state.copyWith(isLoading: false, errorMessage: error.toString()));
    }
  }

  Map<String, String> _mapValidationCodes(HabitFormErrors errors) {
    final entries = <String, String>{};
    if (errors.name != null) {
      entries['name'] = errors.name!;
    }
    if (errors.emoji != null) {
      entries['emoji'] = errors.emoji!;
    }
    if (errors.days != null) {
      entries['days'] = errors.days!;
    }
    if (errors.reminderTime != null) {
      entries['reminder_time'] = errors.reminderTime!;
    }
    if (errors.limit != null) {
      entries['limit'] = errors.limit!;
    }
    return entries;
  }

  String _generateHabitId() {
    final timestamp = _clock().microsecondsSinceEpoch;
    return 'habit_${timestamp}_${_uuid.v4()}';
  }

  void _emit(HabitFormState newState) {
    final snapshot = _snapshotFromState(newState);
    state = newState.copyWith(hasChanges: snapshot != _baseline);
  }

  _HabitFormSnapshot _snapshotFromState(HabitFormState state) {
    return _HabitFormSnapshot(
      emoji: state.emoji,
      name: state.name,
      color: state.color,
      days: state.days,
      reminderTime: state.reminderTime,
      reminderEnabled: state.reminderEnabled,
    );
  }

  _HabitFormSnapshot _snapshotFromHabit(
    Habit habit, {
    required bool reminderEnabled,
  }) {
    return _HabitFormSnapshot(
      emoji: habit.emoji,
      name: habit.name,
      color: habit.color,
      days: habit.days,
      reminderTime: reminderEnabled ? habit.reminderTime : '08:00',
      reminderEnabled: reminderEnabled,
    );
  }

  bool _isValidTime(String value) {
    final parts = value.split(':');
    if (parts.length != 2) return false;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return false;
    return hour >= 0 && hour <= 23 && minute >= 0 && minute <= 59;
  }
}

class HabitFormSaveResult {
  const HabitFormSaveResult._({
    required this.status,
    this.habit,
    this.isNew = false,
    this.message,
  });

  final HabitFormSaveStatus status;
  final Habit? habit;
  final bool isNew;
  final String? message;

  static HabitFormSaveResult success({
    required Habit habit,
    required bool isNew,
  }) {
    return HabitFormSaveResult._(
      status: HabitFormSaveStatus.success,
      habit: habit,
      isNew: isNew,
    );
  }

  static HabitFormSaveResult validationFailed() {
    return const HabitFormSaveResult._(
      status: HabitFormSaveStatus.validationFailed,
    );
  }

  static HabitFormSaveResult limitReached() {
    return const HabitFormSaveResult._(
      status: HabitFormSaveStatus.limitReached,
    );
  }

  static HabitFormSaveResult failure({String? message}) {
    return HabitFormSaveResult._(
      status: HabitFormSaveStatus.failure,
      message: message,
    );
  }
}

enum HabitFormSaveStatus { success, validationFailed, limitReached, failure }

class HabitFormDeleteResult {
  const HabitFormDeleteResult._(this.status, {this.message});

  final HabitFormDeleteStatus status;
  final String? message;

  static HabitFormDeleteResult deleted() {
    return const HabitFormDeleteResult._(HabitFormDeleteStatus.deleted);
  }

  static HabitFormDeleteResult notAllowed() {
    return const HabitFormDeleteResult._(HabitFormDeleteStatus.notAllowed);
  }

  static HabitFormDeleteResult failure({String? message}) {
    return HabitFormDeleteResult._(
      HabitFormDeleteStatus.failure,
      message: message,
    );
  }
}

enum HabitFormDeleteStatus { deleted, notAllowed, failure }

class _HabitFormSnapshot {
  _HabitFormSnapshot({
    this.emoji = '🌱',
    this.name = '',
    this.color = 0xFF4F46E5,
    List<int>? days,
    this.reminderTime = '08:00',
    this.reminderEnabled = false,
  }) : days = List<int>.unmodifiable(() {
         final values = List<int>.from(
           days ?? List<int>.generate(7, (index) => index),
         );
         values.sort();
         return values;
       }());

  final String emoji;
  final String name;
  final int color;
  final List<int> days;
  final String reminderTime;
  final bool reminderEnabled;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is _HabitFormSnapshot &&
        other.emoji == emoji &&
        other.name == name &&
        other.color == color &&
        listEquals(other.days, days) &&
        other.reminderTime == reminderTime &&
        other.reminderEnabled == reminderEnabled;
  }

  @override
  int get hashCode => Object.hash(
    emoji,
    name,
    color,
    Object.hashAll(days),
    reminderTime,
    reminderEnabled,
  );
}

final habitFormClockProvider = Provider<DateTime Function()>((ref) {
  return DateTime.now;
});

final habitFormUuidProvider = Provider<Uuid>((ref) {
  return const Uuid();
});

final habitFormControllerProvider = NotifierProvider.autoDispose
    .family<HabitFormController, HabitFormState, String?>((habitId) {
      return HabitFormController(habitId);
    });

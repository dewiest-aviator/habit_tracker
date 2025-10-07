import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationSettingsState {
  const NotificationSettingsState({
    this.hasLoaded = false,
    this.enabled = false,
    this.reminderTime = const TimeOfDay(hour: 8, minute: 0),
  });

  final bool hasLoaded;
  final bool enabled;
  final TimeOfDay reminderTime;

  NotificationSettingsState copyWith({
    bool? hasLoaded,
    bool? enabled,
    TimeOfDay? reminderTime,
  }) {
    return NotificationSettingsState(
      hasLoaded: hasLoaded ?? this.hasLoaded,
      enabled: enabled ?? this.enabled,
      reminderTime: reminderTime ?? this.reminderTime,
    );
  }
}

class NotificationSettingsController extends Notifier<NotificationSettingsState> {
  NotificationSettingsController({SharedPreferences? preferences})
    : _providedPrefs = preferences;

  static const _enabledKey = 'notifications_enabled';
  static const _timeKey = 'notifications_time';

  final SharedPreferences? _providedPrefs;
  SharedPreferences? _prefs;

  bool get hasLoaded => state.hasLoaded;
  bool get enabled => state.enabled;
  TimeOfDay get reminderTime => state.reminderTime;

  @override
  NotificationSettingsState build() {
    Future<void>.microtask(() async {
      if (!ref.mounted) return;
      await load();
    });
    return const NotificationSettingsState();
  }

  Future<void> load() async {
    if (state.hasLoaded && _prefs != null) return;

    final prefs = _providedPrefs ?? await SharedPreferences.getInstance();
    _prefs = prefs;

    final stored = prefs.getString(_timeKey);
    TimeOfDay time = const TimeOfDay(hour: 8, minute: 0);
    if (stored != null) {
      final parts = stored.split(':');
      if (parts.length == 2) {
        final hour = int.tryParse(parts[0]);
        final minute = int.tryParse(parts[1]);
        if (hour != null && minute != null) {
          time = TimeOfDay(hour: hour, minute: minute);
        }
      }
    }

    state = state.copyWith(
      hasLoaded: true,
      enabled: prefs.getBool(_enabledKey) ?? false,
      reminderTime: time,
    );
  }

  Future<void> setEnabled(bool value) async {
    if (state.hasLoaded && state.enabled == value) return;

    state = state.copyWith(enabled: value, hasLoaded: true);

    final prefs =
        _prefs ?? _providedPrefs ?? await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey, value);
    _prefs = prefs;
  }

  Future<void> setReminderTime(TimeOfDay time) async {
    if (state.hasLoaded && state.reminderTime == time) return;

    state = state.copyWith(reminderTime: time, hasLoaded: true);

    final prefs =
        _prefs ?? _providedPrefs ?? await SharedPreferences.getInstance();
    final formatted =
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    await prefs.setString(_timeKey, formatted);
    _prefs = prefs;
  }
}

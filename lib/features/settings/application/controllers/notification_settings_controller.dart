import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:habit_tracker/core/services/notification_service.dart';

class NotificationSettingsState {
  const NotificationSettingsState({
    this.hasLoaded = false,
    this.enabled = false,
    this.reminderTime = const TimeOfDay(hour: 8, minute: 0),
    this.permissionStatus = NotificationAuthorizationStatus.unknown,
    this.isPermissionInProgress = false,
    this.permissionRequested = false,
  });

  final bool hasLoaded;
  final bool enabled;
  final TimeOfDay reminderTime;
  final NotificationAuthorizationStatus permissionStatus;
  final bool isPermissionInProgress;
  final bool permissionRequested;

  NotificationSettingsState copyWith({
    bool? hasLoaded,
    bool? enabled,
    TimeOfDay? reminderTime,
    NotificationAuthorizationStatus? permissionStatus,
    bool? isPermissionInProgress,
    bool? permissionRequested,
  }) {
    return NotificationSettingsState(
      hasLoaded: hasLoaded ?? this.hasLoaded,
      enabled: enabled ?? this.enabled,
      reminderTime: reminderTime ?? this.reminderTime,
      permissionStatus: permissionStatus ?? this.permissionStatus,
      isPermissionInProgress:
          isPermissionInProgress ?? this.isPermissionInProgress,
      permissionRequested: permissionRequested ?? this.permissionRequested,
    );
  }
}

class NotificationSettingsController
    extends Notifier<NotificationSettingsState> {
  NotificationSettingsController({SharedPreferences? preferences})
    : _providedPrefs = preferences;

  static const _enabledKey = 'notifications_enabled';
  static const _timeKey = 'notifications_time';
  static const _requestedKey = 'notifications_permission_requested';

  final SharedPreferences? _providedPrefs;
  SharedPreferences? _prefs;

  bool get hasLoaded => state.hasLoaded;
  bool get enabled => state.enabled;
  TimeOfDay get reminderTime => state.reminderTime;
  NotificationAuthorizationStatus get permissionStatus =>
      state.permissionStatus;

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
    final notificationService = ref.read(notificationServiceProvider);

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

    final status = await notificationService.getPermissionStatus();
    var isEnabled = prefs.getBool(_enabledKey) ?? false;
    if (status != NotificationAuthorizationStatus.granted && isEnabled) {
      isEnabled = false;
      await prefs.setBool(_enabledKey, false);
    }

    state = state.copyWith(
      hasLoaded: true,
      enabled: isEnabled,
      reminderTime: time,
      permissionStatus: status,
      permissionRequested: prefs.getBool(_requestedKey) ?? false,
    );
  }

  Future<void> setEnabled(bool value) async {
    if (state.hasLoaded && state.enabled == value) return;

    if (value &&
        state.permissionStatus != NotificationAuthorizationStatus.granted) {
      final status = await _requestPermission();
      if (status != NotificationAuthorizationStatus.granted) {
        state = state.copyWith(
          enabled: false,
          hasLoaded: true,
          permissionStatus: status,
        );
        return;
      }
    }

    state = state.copyWith(enabled: value, hasLoaded: true);

    final prefs =
        _prefs ?? _providedPrefs ?? await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey, value);
    if (value) {
      await prefs.setBool(_requestedKey, true);
      state = state.copyWith(permissionRequested: true);
    }
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

  Future<void> refreshPermissionStatus() async {
    state = state.copyWith(isPermissionInProgress: true);
    try {
      final notificationService = ref.read(notificationServiceProvider);
      final status = await notificationService.getPermissionStatus();
      var enabled = state.enabled;
      if (status != NotificationAuthorizationStatus.granted && enabled) {
        enabled = false;
        final prefs =
            _prefs ?? _providedPrefs ?? await SharedPreferences.getInstance();
        await prefs.setBool(_enabledKey, false);
        _prefs = prefs;
      }
      state = state.copyWith(permissionStatus: status, enabled: enabled);
    } finally {
      state = state.copyWith(isPermissionInProgress: false);
    }
  }

  Future<NotificationAuthorizationStatus> _requestPermission() async {
    state = state.copyWith(isPermissionInProgress: true);
    try {
      final notificationService = ref.read(notificationServiceProvider);
      final status = await notificationService.requestAndGetPermissionStatus();
      var enabled = state.enabled;
      if (status != NotificationAuthorizationStatus.granted && enabled) {
        enabled = false;
        final prefs =
            _prefs ?? _providedPrefs ?? await SharedPreferences.getInstance();
        await prefs.setBool(_enabledKey, false);
        _prefs = prefs;
      }
      state = state.copyWith(
        permissionStatus: status,
        enabled: enabled,
        permissionRequested: true,
      );
      final prefs =
          _prefs ?? _providedPrefs ?? await SharedPreferences.getInstance();
      await prefs.setBool(_requestedKey, true);
      _prefs = prefs;
      return status;
    } finally {
      state = state.copyWith(isPermissionInProgress: false);
    }
  }

  Future<NotificationAuthorizationStatus> requestPermission() {
    return _requestPermission();
  }

  Future<bool> openPermissionSettings() async {
    state = state.copyWith(isPermissionInProgress: true);
    try {
      final notificationService = ref.read(notificationServiceProvider);
      final opened = await notificationService.openSystemNotificationSettings();
      return opened;
    } finally {
      state = state.copyWith(isPermissionInProgress: false);
    }
  }
}

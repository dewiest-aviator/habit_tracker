import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

enum NotificationAuthorizationStatus { unknown, notDetermined, granted, denied }

class NotificationService {
  NotificationService({
    FlutterLocalNotificationsPlugin? plugin,
    Future<String> Function()? timeZoneNameProvider,
  }) : _plugin = plugin ?? FlutterLocalNotificationsPlugin(),
       _timeZoneNameProvider =
           timeZoneNameProvider ?? _defaultTimeZoneNameProvider;

  final FlutterLocalNotificationsPlugin _plugin;
  final Future<String> Function() _timeZoneNameProvider;
  static bool _timeZonesInitialized = false;

  FlutterLocalNotificationsPlugin get plugin => _plugin;

  Future<bool> requestPermission() async {
    var granted = false;

    final androidImpl = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    final iosImpl = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    final macImpl = _plugin
        .resolvePlatformSpecificImplementation<
          MacOSFlutterLocalNotificationsPlugin
        >();

    final androidResult = await androidImpl?.requestNotificationsPermission();
    if (androidImpl != null) {
      if (androidResult == null || androidResult == true) {
        granted = true;
      }
    }

    final iosResult = await iosImpl?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
    if (iosResult == true) {
      granted = true;
    }

    final macResult = await macImpl?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
    if (macResult == true) {
      granted = true;
    }

    return granted;
  }

  Future<NotificationAuthorizationStatus> getPermissionStatus() async {
    if (Platform.isIOS || Platform.isMacOS) {
      final iosPlugin = _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      final macPlugin = _plugin
          .resolvePlatformSpecificImplementation<
            MacOSFlutterLocalNotificationsPlugin
          >();
      final options =
          await iosPlugin?.checkPermissions() ??
          await macPlugin?.checkPermissions();
      if (options == null) {
        return NotificationAuthorizationStatus.unknown;
      }
      if (options.isEnabled || options.isProvisionalEnabled) {
        return NotificationAuthorizationStatus.granted;
      }
      return NotificationAuthorizationStatus.denied;
    }

    final status = await Permission.notification.status;
    if (status.isGranted || status.isProvisional) {
      return NotificationAuthorizationStatus.granted;
    }
    if (status.isPermanentlyDenied || status.isRestricted || status.isLimited) {
      return NotificationAuthorizationStatus.denied;
    }
    if (status.isDenied) {
      return NotificationAuthorizationStatus.notDetermined;
    }
    return NotificationAuthorizationStatus.unknown;
  }

  Future<NotificationAuthorizationStatus>
  requestAndGetPermissionStatus() async {
    await requestPermission();
    return getPermissionStatus();
  }

  Future<bool> openSystemNotificationSettings() async {
    try {
      await AppSettings.openAppSettings(type: AppSettingsType.notification);
      return true;
    } on PlatformException {
      return false;
    }
  }

  Future<void> scheduleHabitReminder({
    required String habitId,
    required String title,
    required String body,
    required List<int> days,
    required String time,
  }) async {
    final reminderTime = _parseTimeOfDay(time);
    if (reminderTime == null || days.isEmpty) {
      return;
    }
    await _ensureTimeZonesInitialized();

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        'habit_reminders',
        'Habit reminders',
        channelDescription: 'Daily habit reminder notifications.',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: const DarwinNotificationDetails(),
      macOS: const DarwinNotificationDetails(),
    );

    for (final day in days) {
      final scheduleDate = _nextInstanceForDay(day, reminderTime);
      try {
        await _plugin.zonedSchedule(
          _notificationIdForHabit(habitId, day),
          title,
          body,
          scheduleDate,
          details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        );
      } on PlatformException catch (_) {
        rethrow;
      }
    }
  }

  Future<void> cancelHabitReminder(String habitId) async {
    for (var day = 0; day < 7; day += 1) {
      await _plugin.cancel(_notificationIdForHabit(habitId, day));
    }
  }

  Future<void> _ensureTimeZonesInitialized() async {
    if (_timeZonesInitialized) return;
    tz.initializeTimeZones();
    try {
      final name = await _timeZoneNameProvider();
      final location = tz.getLocation(name);
      tz.setLocalLocation(location);
    } catch (_) {
      tz.setLocalLocation(tz.getLocation('UTC'));
    }
    _timeZonesInitialized = true;
  }

  @visibleForTesting
  static void resetInitialization() {
    _timeZonesInitialized = false;
  }

  static Future<String> _defaultTimeZoneNameProvider() async {
    try {
      return await FlutterTimezone.getLocalTimezone();
    } catch (_) {
      return 'UTC';
    }
  }

  int _notificationIdForHabit(String habitId, int dayIndex) {
    final base = habitId.hashCode & 0x7FFFFFFF;
    return base ^ dayIndex;
  }

  TimeOfDay? _parseTimeOfDay(String value) {
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

  tz.TZDateTime _nextInstanceForDay(int dayIndex, TimeOfDay time) {
    final now = tz.TZDateTime.now(tz.local);
    final targetWeekday = dayIndex < 6 ? dayIndex + 1 : DateTime.sunday;
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    var delta = (targetWeekday - now.weekday) % 7;
    scheduled = scheduled.add(Duration(days: delta));
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 7));
    }
    return scheduled;
  }
}

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

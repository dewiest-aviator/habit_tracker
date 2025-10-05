import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/state/notification_settings_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('load provides sensible defaults', () async {
    final controller = NotificationSettingsController();
    await controller.load();

    expect(controller.hasLoaded, isTrue);
    expect(controller.enabled, isFalse);
    expect(controller.reminderTime, const TimeOfDay(hour: 8, minute: 0));
  });

  test('setEnabled persists flag', () async {
    final controller = NotificationSettingsController();
    await controller.load();

    await controller.setEnabled(true);
    expect(controller.enabled, isTrue);

    final rehydrated = NotificationSettingsController();
    await rehydrated.load();
    expect(rehydrated.enabled, isTrue);
  });

  test('setReminderTime persists selection', () async {
    final controller = NotificationSettingsController();
    await controller.load();

    const time = TimeOfDay(hour: 18, minute: 30);
    await controller.setReminderTime(time);
    expect(controller.reminderTime, time);

    final rehydrated = NotificationSettingsController();
    await rehydrated.load();
    expect(rehydrated.reminderTime, time);
  });
}

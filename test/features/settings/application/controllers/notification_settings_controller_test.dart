import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/features/settings/application/controllers/notification_settings_controller.dart';
import 'package:habit_tracker/features/settings/application/providers/notification_settings_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late ProviderContainer container;

  Future<void> settle() => Future<void>.delayed(Duration.zero);

  NotificationSettingsController readController() =>
      container.read(notificationSettingsProvider.notifier);

  Future<void> waitUntilLoaded() async {
    for (var i = 0; i < 10; i += 1) {
      if (container.read(notificationSettingsProvider).hasLoaded) return;
      await Future<void>.delayed(const Duration(milliseconds: 1));
    }
    fail('NotificationSettingsController did not load in time');
  }

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    container = ProviderContainer();
  });

  tearDown(() {
    container.dispose();
  });

  test('load provides sensible defaults', () async {
    readController();
    await settle();
    await waitUntilLoaded();

    final state = container.read(notificationSettingsProvider);
    expect(state.hasLoaded, isTrue);
    expect(state.enabled, isFalse);
    expect(state.reminderTime, const TimeOfDay(hour: 8, minute: 0));
  });

  test('setEnabled persists flag', () async {
    final controller = readController();
    await settle();
    await waitUntilLoaded();

    await controller.setEnabled(true);
    expect(container.read(notificationSettingsProvider).enabled, isTrue);

    final secondContainer = ProviderContainer();
    secondContainer.read(notificationSettingsProvider.notifier);
    await Future<void>.delayed(Duration.zero);
    for (var i = 0; i < 10; i += 1) {
      final state = secondContainer.read(notificationSettingsProvider);
      if (state.hasLoaded) {
        expect(state.enabled, isTrue);
        secondContainer.dispose();
        return;
      }
      await Future<void>.delayed(const Duration(milliseconds: 1));
    }
    secondContainer.dispose();
    fail('Rehydrated NotificationSettingsController did not load in time');
  });

  test('setReminderTime persists selection', () async {
    final controller = readController();
    await settle();
    await waitUntilLoaded();

    const time = TimeOfDay(hour: 18, minute: 30);
    await controller.setReminderTime(time);
    expect(container.read(notificationSettingsProvider).reminderTime, time);

    final secondContainer = ProviderContainer();
    secondContainer.read(notificationSettingsProvider.notifier);
    await Future<void>.delayed(Duration.zero);
    for (var i = 0; i < 10; i += 1) {
      final state = secondContainer.read(notificationSettingsProvider);
      if (state.hasLoaded) {
        expect(state.reminderTime, time);
        secondContainer.dispose();
        return;
      }
      await Future<void>.delayed(const Duration(milliseconds: 1));
    }
    secondContainer.dispose();
    fail('Rehydrated notification settings did not load in time');
  });
}

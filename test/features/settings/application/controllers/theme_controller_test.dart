import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/features/settings/application/controllers/theme_controller.dart';
import 'package:habit_tracker/features/settings/application/providers/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late ProviderContainer container;

  Future<void> settle() => Future<void>.delayed(Duration.zero);

  ThemeController readController() =>
      container.read(themeControllerProvider.notifier);

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    container = ProviderContainer();
  });

  tearDown(() {
    container.dispose();
  });

  Future<void> waitUntilLoaded() async {
    for (var i = 0; i < 10; i += 1) {
      if (container.read(themeControllerProvider).hasLoaded) return;
      await Future<void>.delayed(const Duration(milliseconds: 1));
    }
    fail('ThemeController did not load in time');
  }

  test('load defaults to system when no preference stored', () async {
    readController();
    await settle();
    await waitUntilLoaded();

    final state = container.read(themeControllerProvider);
    expect(state.hasLoaded, isTrue);
    expect(state.themeMode, ThemeMode.system);
  });

  test('setThemeMode persists preference', () async {
    final controller = readController();
    await settle();
    await waitUntilLoaded();

    await controller.setThemeMode(ThemeMode.dark);
    expect(container.read(themeControllerProvider).themeMode, ThemeMode.dark);

    final secondContainer = ProviderContainer();
    secondContainer.read(themeControllerProvider.notifier);
    await Future<void>.delayed(Duration.zero);
    for (var i = 0; i < 10; i += 1) {
      final state = secondContainer.read(themeControllerProvider);
      if (state.hasLoaded) {
        expect(state.themeMode, ThemeMode.dark);
        secondContainer.dispose();
        return;
      }
      await Future<void>.delayed(const Duration(milliseconds: 1));
    }
    secondContainer.dispose();
    fail('Rehydrated ThemeController did not load in time');
  });

  test('setThemeMode ignores duplicate updates', () async {
    final controller = readController();
    await settle();
    await waitUntilLoaded();

    await controller.setThemeMode(ThemeMode.light);
    final firstState = container.read(themeControllerProvider).themeMode;

    await controller.setThemeMode(ThemeMode.light);

    expect(container.read(themeControllerProvider).themeMode, firstState);
  });
}

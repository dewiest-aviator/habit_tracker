import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/state/theme_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('load defaults to system when no preference stored', () async {
    final controller = ThemeController();
    expect(controller.themeMode, ThemeMode.system);
    expect(controller.hasLoaded, isFalse);

    await controller.load();

    expect(controller.hasLoaded, isTrue);
    expect(controller.themeMode, ThemeMode.system);
  });

  test('setThemeMode persists preference and notifies listeners', () async {
    final controller = ThemeController();
    await controller.load();

    var notified = false;
    controller.addListener(() {
      notified = true;
    });

    await controller.setThemeMode(ThemeMode.dark);

    expect(controller.themeMode, ThemeMode.dark);
    expect(notified, isTrue);

    final rehydrated = ThemeController();
    await rehydrated.load();

    expect(rehydrated.themeMode, ThemeMode.dark);
  });

  test('setThemeMode ignores duplicate updates', () async {
    final controller = ThemeController();
    await controller.load();
    await controller.setThemeMode(ThemeMode.light);

    var notifyCount = 0;
    controller.addListener(() {
      notifyCount += 1;
    });

    await controller.setThemeMode(ThemeMode.light);

    expect(notifyCount, 0);
  });
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/features/settings/application/controllers/time_preferences_controller.dart';
import 'package:habit_tracker/features/settings/application/providers/time_preferences_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('loads system preference by default', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final controller = container.read(timePreferencesProvider.notifier);
    await controller.load();

    final state = container.read(timePreferencesProvider);
    expect(state.preference, TimeFormatPreference.system);
    expect(state.hasLoaded, isTrue);
  });

  test('persists and restores selected preference', () async {
    final prefs = <String, Object>{'time_format_pref': '24h'};
    SharedPreferences.setMockInitialValues(prefs);

    final container = ProviderContainer();
    addTearDown(container.dispose);

    final controller = container.read(timePreferencesProvider.notifier);
    await controller.load();

    expect(
      container.read(timePreferencesProvider).preference,
      TimeFormatPreference.h24,
    );

    await controller.setPreference(TimeFormatPreference.h12);
    expect(
      container.read(timePreferencesProvider).preference,
      TimeFormatPreference.h12,
    );

    final storedPrefs = await SharedPreferences.getInstance();
    expect(storedPrefs.getString('time_format_pref'), '12h');
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/core/services/analytics_service.dart';
import 'package:habit_tracker/core/services/consent_service.dart';
import 'package:habit_tracker/core/telemetry/controllers/telemetry_controller.dart';
import 'package:habit_tracker/core/telemetry/providers/telemetry_provider.dart';
import 'package:habit_tracker/features/info/application/providers/app_info_provider.dart';
import 'package:habit_tracker/features/settings/application/providers/language_provider.dart';
import 'package:habit_tracker/features/settings/application/providers/notification_settings_provider.dart';
import 'package:habit_tracker/features/settings/application/providers/theme_provider.dart';
import 'package:habit_tracker/features/settings/presentation/screens/settings_screen.dart';
import 'package:habit_tracker/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:package_info_plus/package_info_plus.dart';

class _MockAnalytics extends Mock implements FirebaseAnalytics {}

class _MockCrashlytics extends Mock implements FirebaseCrashlytics {}

void main() {
  late _MockAnalytics analytics;
  late _MockCrashlytics crashlytics;
  late PackageInfo packageInfo;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await ConsentService.reset();
    AnalyticsService.reset();

    analytics = _MockAnalytics();
    crashlytics = _MockCrashlytics();
    when(() => analytics.setAnalyticsCollectionEnabled(any()))
        .thenAnswer((_) async {});
    when(() => analytics.logAppOpen()).thenAnswer((_) async {});
    when(() => crashlytics.setCrashlyticsCollectionEnabled(any()))
        .thenAnswer((_) async {});

    packageInfo = PackageInfo(
      appName: 'Habit Tracker',
      packageName: 'com.example.habit',
      version: '1.2.3',
      buildNumber: '42',
      buildSignature: 'sig',
      installerStore: null,
    );
  });

  ProviderScope buildScope(Widget child) {
    return ProviderScope(
      overrides: [
        telemetryConfigProvider.overrideWithValue(
          TelemetryConfig(
            enableFirebase: true,
            analytics: analytics,
            crashlytics: crashlytics,
          ),
        ),
        telemetryControllerProvider.overrideWith(TelemetryController.new),
        appInfoProvider.overrideWith((ref) async => packageInfo),
      ],
      child: child,
    );
  }

  Future<ProviderContainer> pumpSettings(WidgetTester tester) async {
    await tester.pumpWidget(
      buildScope(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const SettingsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final element = tester.element(find.byType(SettingsScreen));
    return ProviderScope.containerOf(element, listen: false);
  }

  Future<void> waitForCondition(
    bool Function() condition, {
    int maxTicks = 10,
  }) async {
    for (var i = 0; i < maxTicks; i += 1) {
      if (condition()) return;
      await Future<void>.delayed(const Duration(milliseconds: 1));
    }
    fail('Condition not met in allotted time');
  }

  testWidgets('analytics and crash toggles update consent state', (
    WidgetTester tester,
  ) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.binding.setSurfaceSize(const Size(800, 1600));

    final container = await pumpSettings(tester);
    await waitForCondition(
      () => container.read(telemetryControllerProvider).isLoaded,
    );

    expect(
      container.read(telemetryControllerProvider).analyticsConsent,
      isFalse,
    );
    expect(
      container.read(telemetryControllerProvider).crashConsent,
      isFalse,
    );

    final analyticsSwitch = find.byKey(const Key('switch_analytics_consent'));
    final crashSwitch = find.byKey(const Key('switch_crash_consent'));
    await tester.ensureVisible(analyticsSwitch);
    await tester.ensureVisible(crashSwitch);

    await tester.tap(analyticsSwitch);
    await tester.pumpAndSettle();
    expect(
      container.read(telemetryControllerProvider).analyticsConsent,
      isTrue,
    );
    expect(
      container.read(telemetryControllerProvider).crashConsent,
      isFalse,
    );

    await tester.tap(crashSwitch);
    await tester.pumpAndSettle();
    expect(
      container.read(telemetryControllerProvider).crashConsent,
      isTrue,
    );
    expect(
      container.read(telemetryControllerProvider).isConsentGranted,
      isTrue,
    );
  });

  testWidgets('changing theme updates controller', (WidgetTester tester) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.binding.setSurfaceSize(const Size(800, 1600));

    final container = await pumpSettings(tester);
    await waitForCondition(
      () => container.read(themeControllerProvider).hasLoaded,
    );
    expect(container.read(themeControllerProvider).themeMode, ThemeMode.system);

    final dropdownFinder = find.byKey(const Key('dropdown_theme'));
    final dropdownWidget = tester.widget<DropdownButtonFormField<ThemeMode>>(
      dropdownFinder,
    );
    dropdownWidget.onChanged?.call(ThemeMode.dark);
    await tester.pumpAndSettle();

    expect(container.read(themeControllerProvider).themeMode, ThemeMode.dark);
  });

  testWidgets('notification settings toggle and time row respond', (
    WidgetTester tester,
  ) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.binding.setSurfaceSize(const Size(800, 1600));

    final container = await pumpSettings(tester);
    await waitForCondition(
      () => container.read(notificationSettingsProvider).hasLoaded,
    );

    final notificationsSwitch = find.byKey(
      const Key('switch_notifications_enabled'),
    );
    final timeTile = find.byKey(const Key('tile_notification_time'));

    expect(container.read(notificationSettingsProvider).enabled, isFalse);

    await tester.ensureVisible(notificationsSwitch);
    await tester.tap(notificationsSwitch);
    await tester.pumpAndSettle();

    expect(container.read(notificationSettingsProvider).enabled, isTrue);

    final listTile = tester.widget<ListTile>(timeTile);
    expect(listTile.enabled, isTrue);
  });

  testWidgets('changing language updates controller', (
    WidgetTester tester,
  ) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.binding.setSurfaceSize(const Size(800, 1600));

    final container = await pumpSettings(tester);
    await waitForCondition(
      () => container.read(languageControllerProvider).hasLoaded,
    );
    expect(container.read(languageControllerProvider).locale, isNull);

    await container
        .read(languageControllerProvider.notifier)
        .setLocale(const Locale('en'));
    await tester.pumpAndSettle();
    expect(container.read(languageControllerProvider).locale?.languageCode, 'en');
  });
}

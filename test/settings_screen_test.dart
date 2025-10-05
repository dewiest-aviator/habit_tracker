import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/screens/settings_screen.dart';
import 'package:habit_tracker/services/analytics_service.dart';
import 'package:habit_tracker/services/consent_service.dart';
import 'package:habit_tracker/state/app_info_provider.dart';
import 'package:habit_tracker/state/notification_settings_controller.dart';
import 'package:habit_tracker/state/notification_settings_provider.dart';
import 'package:habit_tracker/state/telemetry_controller.dart';
import 'package:habit_tracker/state/telemetry_provider.dart';
import 'package:habit_tracker/state/theme_controller.dart';
import 'package:habit_tracker/state/theme_provider.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:package_info_plus/package_info_plus.dart';

class _MockAnalytics extends Mock implements FirebaseAnalytics {}

class _MockCrashlytics extends Mock implements FirebaseCrashlytics {}

void main() {
  late TelemetryController controller;
  late _MockAnalytics analytics;
  late _MockCrashlytics crashlytics;
  late ThemeController themeController;
  late NotificationSettingsController notificationController;
  late PackageInfo packageInfo;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await ConsentService.reset();
    AnalyticsService.reset();

    analytics = _MockAnalytics();
    crashlytics = _MockCrashlytics();
    when(
      () => analytics.setAnalyticsCollectionEnabled(any()),
    ).thenAnswer((_) async {});
    when(() => analytics.logAppOpen()).thenAnswer((_) async {});
    when(
      () => crashlytics.setCrashlyticsCollectionEnabled(any()),
    ).thenAnswer((_) async {});

    controller = TelemetryController(
      enableFirebase: true,
      analytics: analytics,
      crashlytics: crashlytics,
    );
    await controller.initialize();

    themeController = ThemeController();
    await themeController.load();

    notificationController = NotificationSettingsController();
    await notificationController.load();

    packageInfo = PackageInfo(
      appName: 'Habit Tracker',
      packageName: 'com.example.habit',
      version: '1.2.3',
      buildNumber: '42',
      buildSignature: 'sig',
      installerStore: null,
    );
  });

  testWidgets('analytics and crash toggles update consent state', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          telemetryControllerProvider.overrideWith((ref) => controller),
          themeControllerProvider.overrideWith((ref) => themeController),
          notificationSettingsProvider.overrideWith(
            (ref) => notificationController,
          ),
          appInfoProvider.overrideWith((ref) async => packageInfo),
        ],
        child: const MaterialApp(home: SettingsScreen()),
      ),
    );

    await tester.pumpAndSettle();

    final analyticsSwitch = find.byKey(const Key('switch_analytics_consent'));
    final crashSwitch = find.byKey(const Key('switch_crash_consent'));
    expect(analyticsSwitch, findsOneWidget);
    expect(crashSwitch, findsOneWidget);

    expect(controller.isAnalyticsEnabled, isFalse);
    expect(controller.isCrashEnabled, isFalse);

    await tester.tap(analyticsSwitch);
    await tester.pumpAndSettle();

    expect(controller.isAnalyticsEnabled, isTrue);
    expect(controller.isCrashEnabled, isFalse);

    await tester.tap(crashSwitch);
    await tester.pumpAndSettle();

    expect(controller.isCrashEnabled, isTrue);
    expect(controller.isConsentGranted, isTrue);
  });

  testWidgets('changing theme updates controller', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          telemetryControllerProvider.overrideWith((ref) => controller),
          themeControllerProvider.overrideWith((ref) => themeController),
          notificationSettingsProvider.overrideWith(
            (ref) => notificationController,
          ),
          appInfoProvider.overrideWith((ref) async => packageInfo),
        ],
        child: const MaterialApp(home: SettingsScreen()),
      ),
    );

    await tester.pumpAndSettle();
    expect(themeController.themeMode, ThemeMode.system);

    final dropdownFinder = find.byType(DropdownButtonFormField<ThemeMode>);
    expect(dropdownFinder, findsOneWidget);

    final dropdownWidget = tester.widget<DropdownButtonFormField<ThemeMode>>(
      dropdownFinder,
    );
    dropdownWidget.onChanged?.call(ThemeMode.dark);
    await tester.pumpAndSettle();

    expect(themeController.themeMode, ThemeMode.dark);
  });

  testWidgets('notification settings toggle and time row respond', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          telemetryControllerProvider.overrideWith((ref) => controller),
          themeControllerProvider.overrideWith((ref) => themeController),
          notificationSettingsProvider.overrideWith(
            (ref) => notificationController,
          ),
          appInfoProvider.overrideWith((ref) async => packageInfo),
        ],
        child: const MaterialApp(home: SettingsScreen()),
      ),
    );

    await tester.pumpAndSettle();

    final notificationsSwitch = find.byKey(
      const Key('switch_notifications_enabled'),
    );
    final timeTile = find.byKey(const Key('tile_notification_time'));

    expect(notificationsSwitch, findsOneWidget);
    expect(timeTile, findsOneWidget);
    expect(notificationController.enabled, isFalse);

    await tester.tap(notificationsSwitch);
    await tester.pumpAndSettle();

    expect(notificationController.enabled, isTrue);

    // Tapping the time tile should open a time picker; we cannot interact with it
    // in this unit test, but we ensure the tile is enabled once notifications are.
    final listTile = tester.widget<ListTile>(timeTile);
    expect(listTile.enabled, isTrue);
  });
}

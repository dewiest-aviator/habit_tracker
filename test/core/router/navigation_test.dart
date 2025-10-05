import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/core/router/app_router.dart';
import 'package:habit_tracker/core/services/analytics_service.dart';
import 'package:habit_tracker/core/telemetry/controllers/telemetry_controller.dart';
import 'package:habit_tracker/core/telemetry/providers/telemetry_provider.dart';
import 'package:habit_tracker/core/theme/app_theme.dart';
import 'package:habit_tracker/features/info/application/providers/app_info_provider.dart';
import 'package:habit_tracker/features/settings/application/controllers/notification_settings_controller.dart';
import 'package:habit_tracker/features/settings/application/controllers/theme_controller.dart';
import 'package:habit_tracker/features/settings/application/providers/notification_settings_provider.dart';
import 'package:habit_tracker/features/settings/application/providers/theme_provider.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
    SharedPreferences.setMockInitialValues({
      'analytics_consent': true,
      'crash_consent': true,
      'notifications_enabled': true,
      'notifications_time': '08:00',
    });
    AnalyticsService.reset();

    analytics = _MockAnalytics();
    crashlytics = _MockCrashlytics();

    when(
      () => analytics.setAnalyticsCollectionEnabled(any()),
    ).thenAnswer((_) async {});
    when(() => analytics.logAppOpen()).thenAnswer((_) async {});
    when(
      () => analytics.logEvent(
        name: any(named: 'name'),
        parameters: any(named: 'parameters'),
      ),
    ).thenAnswer((_) async {});
    when(
      () => analytics.logScreenView(
        screenName: any(named: 'screenName'),
        screenClass: any(named: 'screenClass'),
      ),
    ).thenAnswer((_) async {});
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

  testWidgets('navigates from Home to Settings', (WidgetTester tester) async {
    final router = createAppRouter(
      observers: [
        if (controller.analyticsObserver != null) controller.analyticsObserver!,
      ],
    );

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
        child: MaterialApp.router(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          routerConfig: router,
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('Habits'), findsOneWidget);

    final settingsButton = find.byKey(const Key('btn_settings'));
    expect(settingsButton, findsOneWidget);
    await tester.tap(settingsButton);
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsOneWidget);

    final backButton = find.byTooltip('Back');
    await tester.tap(backButton);
    await tester.pumpAndSettle();

    final fab = find.byType(FloatingActionButton);
    expect(fab, findsOneWidget);
    await tester.tap(fab);
    await tester.pump();
  });

  testWidgets('shows not found page for unknown routes', (
    WidgetTester tester,
  ) async {
    final router = createAppRouter(
      observers: [
        if (controller.analyticsObserver != null) controller.analyticsObserver!,
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          telemetryControllerProvider.overrideWith((ref) => controller),
          themeControllerProvider.overrideWith((ref) => themeController),
          appInfoProvider.overrideWith((ref) async => packageInfo),
        ],
        child: MaterialApp.router(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          routerConfig: router,
        ),
      ),
    );

    router.go('/missing');
    await tester.pumpAndSettle();

    expect(find.text('Not found'), findsOneWidget);
  });
}

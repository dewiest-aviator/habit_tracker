import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/screens/settings_screen.dart';
import 'package:habit_tracker/services/analytics_service.dart';
import 'package:habit_tracker/services/consent_service.dart';
import 'package:habit_tracker/state/telemetry_controller.dart';
import 'package:habit_tracker/state/telemetry_provider.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class _MockAnalytics extends Mock implements FirebaseAnalytics {}

class _MockCrashlytics extends Mock implements FirebaseCrashlytics {}

void main() {
  late TelemetryController controller;
  late _MockAnalytics analytics;
  late _MockCrashlytics crashlytics;

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
  });

  tearDown(() {
    controller.dispose();
  });

  testWidgets('toggle updates consent state', (WidgetTester tester) async {
    await tester.pumpWidget(
      TelemetryProvider(
        controller: controller,
        child: const MaterialApp(home: SettingsScreen()),
      ),
    );

    await tester.pump();

    final toggle = find.byType(SwitchListTile);
    expect(toggle, findsOneWidget);

    expect(controller.isConsentGranted, isFalse);

    await tester.tap(toggle);
    await tester.pumpAndSettle();

    expect(controller.isConsentGranted, isTrue);
  });
}

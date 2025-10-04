import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/services/analytics_service.dart';
import 'package:habit_tracker/services/consent_service.dart';
import 'package:habit_tracker/state/telemetry_controller.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MockAnalytics extends Mock implements FirebaseAnalytics {}

class _MockCrashlytics extends Mock implements FirebaseCrashlytics {}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await ConsentService.reset();
    AnalyticsService.reset();
  });

  _MockAnalytics buildAnalyticsMock() {
    final analytics = _MockAnalytics();
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
    return analytics;
  }

  _MockCrashlytics buildCrashlyticsMock() {
    final crashlytics = _MockCrashlytics();
    when(
      () => crashlytics.setCrashlyticsCollectionEnabled(any()),
    ).thenAnswer((_) async {});
    return crashlytics;
  }

  test('initialize keeps telemetry disabled without consent', () async {
    final analytics = buildAnalyticsMock();
    final crashlytics = buildCrashlyticsMock();

    final controller = TelemetryController(
      enableFirebase: true,
      analytics: analytics,
      crashlytics: crashlytics,
    );

    await controller.initialize();

    expect(controller.isLoaded, isTrue);
    expect(controller.hasRecordedDecision, isFalse);
    expect(controller.isConsentGranted, isFalse);
    expect(AnalyticsService.enabled, isFalse);

    verify(() => analytics.setAnalyticsCollectionEnabled(false)).called(1);
    verify(() => crashlytics.setCrashlyticsCollectionEnabled(false)).called(1);
  });

  test('initialize enables telemetry when consent stored', () async {
    SharedPreferences.setMockInitialValues({'analytics_consent': true});

    final analytics = buildAnalyticsMock();
    final crashlytics = buildCrashlyticsMock();

    final controller = TelemetryController(
      enableFirebase: true,
      analytics: analytics,
      crashlytics: crashlytics,
    );

    await controller.initialize();

    expect(controller.isConsentGranted, isTrue);
    expect(controller.hasRecordedDecision, isTrue);
    expect(AnalyticsService.enabled, isTrue);
    expect(controller.analyticsObserver, isNotNull);

    verify(() => analytics.setAnalyticsCollectionEnabled(true)).called(2);
    verify(() => crashlytics.setCrashlyticsCollectionEnabled(true)).called(1);
  });

  test('updateConsent toggles telemetry at runtime', () async {
    final analytics = buildAnalyticsMock();
    final crashlytics = buildCrashlyticsMock();

    final controller = TelemetryController(
      enableFirebase: true,
      analytics: analytics,
      crashlytics: crashlytics,
    );
    await controller.initialize();

    await controller.updateConsent(true);
    expect(controller.isConsentGranted, isTrue);
    verify(() => analytics.setAnalyticsCollectionEnabled(true)).called(2);
    verify(() => crashlytics.setCrashlyticsCollectionEnabled(true)).called(1);

    clearInteractions(analytics);
    clearInteractions(crashlytics);

    await controller.updateConsent(false);
    expect(controller.isConsentGranted, isFalse);
    verify(() => analytics.setAnalyticsCollectionEnabled(false)).called(1);
    verify(() => crashlytics.setCrashlyticsCollectionEnabled(false)).called(1);
  });
}

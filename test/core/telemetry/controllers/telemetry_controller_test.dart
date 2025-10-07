import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/core/services/analytics_service.dart';
import 'package:habit_tracker/core/services/consent_service.dart';
import 'package:habit_tracker/core/telemetry/controllers/telemetry_controller.dart';
import 'package:habit_tracker/core/telemetry/providers/telemetry_provider.dart';
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

  ProviderContainer buildContainer({
    required FirebaseAnalytics analytics,
    required FirebaseCrashlytics crashlytics,
    bool enableFirebase = true,
  }) {
    return ProviderContainer(
      overrides: [
        telemetryConfigProvider.overrideWithValue(
          TelemetryConfig(
            enableFirebase: enableFirebase,
            analytics: analytics,
            crashlytics: crashlytics,
          ),
        ),
        telemetryControllerProvider.overrideWith(TelemetryController.new),
      ],
    );
  }

  Future<void> settle() => Future<void>.delayed(Duration.zero);

  test('initialize keeps telemetry disabled without consent', () async {
    final analytics = buildAnalyticsMock();
    final crashlytics = buildCrashlyticsMock();
    final container = buildContainer(
      analytics: analytics,
      crashlytics: crashlytics,
    );
    final controller = container.read(telemetryControllerProvider.notifier);
    await settle();

    expect(controller.isLoaded, isTrue);
    expect(controller.hasRecordedDecision, isFalse);
    expect(controller.isAnalyticsEnabled, isFalse);
    expect(controller.isCrashEnabled, isFalse);
    expect(AnalyticsService.enabled, isFalse);

    container.dispose();
  });

  test('initialize enables telemetry when consent stored', () async {
    SharedPreferences.setMockInitialValues({
      'analytics_consent': true,
      'crash_consent': true,
    });

    final analytics = buildAnalyticsMock();
    final crashlytics = buildCrashlyticsMock();
    final container = buildContainer(
      analytics: analytics,
      crashlytics: crashlytics,
    );
    final controller = container.read(telemetryControllerProvider.notifier);
    await settle();

    expect(controller.isConsentGranted, isTrue);
    expect(controller.hasRecordedDecision, isTrue);
    expect(AnalyticsService.enabled, isTrue);
    expect(controller.analyticsObserver, isNotNull);

    container.dispose();
  });

  test('updateConsent toggles telemetry at runtime', () async {
    final analytics = buildAnalyticsMock();
    final crashlytics = buildCrashlyticsMock();
    final container = buildContainer(
      analytics: analytics,
      crashlytics: crashlytics,
    );
    final controller = container.read(telemetryControllerProvider.notifier);
    await settle();

    clearInteractions(analytics);
    clearInteractions(crashlytics);

    await controller.updateConsent(true);
    expect(controller.isConsentGranted, isTrue);
    expect(controller.isAnalyticsEnabled, isTrue);
    expect(controller.isCrashEnabled, isTrue);
    verify(() => analytics.setAnalyticsCollectionEnabled(true)).called(2);
    verify(() => crashlytics.setCrashlyticsCollectionEnabled(true)).called(1);

    clearInteractions(analytics);
    clearInteractions(crashlytics);

    await controller.updateConsent(false);
    expect(controller.isConsentGranted, isFalse);
    expect(controller.isAnalyticsEnabled, isFalse);
    expect(controller.isCrashEnabled, isFalse);
    verify(() => analytics.setAnalyticsCollectionEnabled(false)).called(1);
    verify(() => crashlytics.setCrashlyticsCollectionEnabled(false)).called(1);

    container.dispose();
  });

  test('updateAnalyticsConsent toggles analytics only', () async {
    final analytics = buildAnalyticsMock();
    final crashlytics = buildCrashlyticsMock();
    final container = buildContainer(
      analytics: analytics,
      crashlytics: crashlytics,
    );
    final controller = container.read(telemetryControllerProvider.notifier);
    await settle();

    clearInteractions(analytics);

    await controller.updateAnalyticsConsent(true);
    expect(controller.isAnalyticsEnabled, isTrue);
    expect(controller.isCrashEnabled, isFalse);
    verify(() => analytics.setAnalyticsCollectionEnabled(true)).called(2);
    verifyNever(() => crashlytics.setCrashlyticsCollectionEnabled(true));

    clearInteractions(analytics);

    await controller.updateAnalyticsConsent(false);
    expect(controller.isAnalyticsEnabled, isFalse);
    verify(() => analytics.setAnalyticsCollectionEnabled(false)).called(1);

    container.dispose();
  });

  test('updateCrashConsent toggles crash collection only', () async {
    final analytics = buildAnalyticsMock();
    final crashlytics = buildCrashlyticsMock();
    final container = buildContainer(
      analytics: analytics,
      crashlytics: crashlytics,
    );
    final controller = container.read(telemetryControllerProvider.notifier);
    await settle();

    clearInteractions(crashlytics);

    await controller.updateCrashConsent(true);
    expect(controller.isCrashEnabled, isTrue);
    expect(controller.isAnalyticsEnabled, isFalse);
    verify(() => crashlytics.setCrashlyticsCollectionEnabled(true)).called(1);
    verifyNever(() => analytics.setAnalyticsCollectionEnabled(true));

    clearInteractions(crashlytics);

    await controller.updateCrashConsent(false);
    expect(controller.isCrashEnabled, isFalse);
    verify(() => crashlytics.setCrashlyticsCollectionEnabled(false)).called(1);

    container.dispose();
  });
}

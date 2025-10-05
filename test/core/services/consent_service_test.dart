import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/core/services/consent_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await ConsentService.reset();
  });

  test('load defaults to no decision and false consent', () async {
    await ConsentService.load();

    expect(ConsentService.hasLoaded, isTrue);
    expect(ConsentService.hasAnalyticsDecision, isFalse);
    expect(ConsentService.hasCrashDecision, isFalse);
    expect(ConsentService.hasRecordedDecision, isFalse);
    expect(ConsentService.analyticsConsentGranted, isFalse);
    expect(ConsentService.crashConsentGranted, isFalse);
    expect(ConsentService.consentGranted, isFalse);
  });

  test('setConsent persists and marks decision', () async {
    await ConsentService.load();
    await ConsentService.setAnalyticsConsent(true);
    await ConsentService.setCrashConsent(false);

    expect(ConsentService.analyticsConsentGranted, isTrue);
    expect(ConsentService.crashConsentGranted, isFalse);
    expect(ConsentService.hasAnalyticsDecision, isTrue);
    expect(ConsentService.hasCrashDecision, isTrue);
    expect(ConsentService.hasRecordedDecision, isTrue);
    expect(ConsentService.consentGranted, isFalse);

    // Reload from storage to verify persistence
    await ConsentService.load();
    expect(ConsentService.analyticsConsentGranted, isTrue);
    expect(ConsentService.crashConsentGranted, isFalse);
    expect(ConsentService.hasAnalyticsDecision, isTrue);
    expect(ConsentService.hasCrashDecision, isTrue);
  });
}

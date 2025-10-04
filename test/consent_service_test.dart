import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/services/consent_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await ConsentService.reset();
  });

  test('load defaults to no decision and false consent', () async {
    await ConsentService.load();

    expect(ConsentService.hasLoaded, isTrue);
    expect(ConsentService.hasRecordedDecision, isFalse);
    expect(ConsentService.consentGranted, isFalse);
  });

  test('setConsent persists and marks decision', () async {
    await ConsentService.load();
    await ConsentService.setConsent(true);

    expect(ConsentService.consentGranted, isTrue);
    expect(ConsentService.hasRecordedDecision, isTrue);

    // Reload from storage to verify persistence
    await ConsentService.load();
    expect(ConsentService.consentGranted, isTrue);
    expect(ConsentService.hasRecordedDecision, isTrue);
  });
}

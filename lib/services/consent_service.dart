import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConsentService {
  const ConsentService._();

  static const _analyticsKey = 'analytics_consent';
  static const _crashKey = 'crash_consent';

  static bool _hasLoaded = false;
  static bool _analyticsConsentGranted = false;
  static bool _crashConsentGranted = false;
  static bool _hasAnalyticsDecision = false;
  static bool _hasCrashDecision = false;

  static bool get hasLoaded => _hasLoaded;
  static bool get analyticsConsentGranted => _analyticsConsentGranted;
  static bool get crashConsentGranted => _crashConsentGranted;
  static bool get consentGranted =>
      _analyticsConsentGranted && _crashConsentGranted;
  static bool get hasAnalyticsDecision => _hasAnalyticsDecision;
  static bool get hasCrashDecision => _hasCrashDecision;
  static bool get hasRecordedDecision =>
      _hasAnalyticsDecision && _hasCrashDecision;

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    _hasAnalyticsDecision = prefs.containsKey(_analyticsKey);
    _analyticsConsentGranted = prefs.getBool(_analyticsKey) ?? false;

    if (prefs.containsKey(_crashKey)) {
      _hasCrashDecision = true;
      _crashConsentGranted = prefs.getBool(_crashKey) ?? false;
    } else {
      // Migrate legacy single-consent value to crash setting.
      _crashConsentGranted = _analyticsConsentGranted;
      _hasCrashDecision = _hasAnalyticsDecision;
      if (_hasCrashDecision) {
        await prefs.setBool(_crashKey, _crashConsentGranted);
      }
    }

    _hasLoaded = true;
  }

  static Future<void> setConsent(bool granted) async {
    await setAnalyticsConsent(granted);
    await setCrashConsent(granted);
  }

  static Future<void> setAnalyticsConsent(bool granted) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_analyticsKey, granted);
    _analyticsConsentGranted = granted;
    _hasAnalyticsDecision = true;
  }

  static Future<void> setCrashConsent(bool granted) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_crashKey, granted);
    _crashConsentGranted = granted;
    _hasCrashDecision = true;
  }

  @visibleForTesting
  static Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_analyticsKey);
    await prefs.remove(_crashKey);
    _hasLoaded = false;
    _analyticsConsentGranted = false;
    _crashConsentGranted = false;
    _hasAnalyticsDecision = false;
    _hasCrashDecision = false;
  }
}

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConsentService {
  const ConsentService._();

  static const _key = 'analytics_consent';
  static bool _hasLoaded = false;
  static bool _consentGranted = false;
  static bool _hasDecision = false;

  static bool get hasLoaded => _hasLoaded;
  static bool get consentGranted => _consentGranted;
  static bool get hasRecordedDecision => _hasDecision;

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _hasDecision = prefs.containsKey(_key);
    _consentGranted = prefs.getBool(_key) ?? false;
    _hasLoaded = true;
  }

  static Future<void> setConsent(bool granted) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, granted);
    _consentGranted = granted;
    _hasDecision = true;
  }

  @visibleForTesting
  static Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
    _hasLoaded = false;
    _consentGranted = false;
    _hasDecision = false;
  }
}

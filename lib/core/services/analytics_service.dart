import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

/// Thin wrapper around [FirebaseAnalytics] so the UI can safely
/// no-op when analytics is disabled.
class AnalyticsService {
  const AnalyticsService._();

  static FirebaseAnalytics? _analytics;
  static FirebaseAnalyticsObserver? _observer;

  static bool get enabled => _analytics != null;
  static FirebaseAnalyticsObserver? get observer => _observer;

  static Future<void> configure(FirebaseAnalytics analytics) async {
    _analytics = analytics;
    _observer = FirebaseAnalyticsObserver(analytics: analytics);
    await analytics.setAnalyticsCollectionEnabled(true);
  }

  static Future<void> logAppOpen() async {
    await _analytics?.logAppOpen();
  }

  static Future<void> logEvent(
    String name, {
    Map<String, Object?>? parameters,
  }) async {
    final sanitized = parameters == null
        ? null
        : Map<String, Object>.fromEntries(
            parameters.entries
                .where((entry) => entry.value != null)
                .map((entry) => MapEntry(entry.key, entry.value!)),
          );
    await _analytics?.logEvent(name: name, parameters: sanitized);
  }

  static Future<void> logScreenView(
    String screenName, {
    String? screenClass,
  }) async {
    await _analytics?.logScreenView(
      screenName: screenName,
      screenClass: screenClass ?? screenName,
    );
  }

  static void disable() {
    _analytics = null;
    _observer = null;
  }

  @visibleForTesting
  static void reset() => disable();
}

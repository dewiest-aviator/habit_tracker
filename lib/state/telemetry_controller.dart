import 'package:flutter/widgets.dart';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import '../services/analytics_service.dart';
import '../services/consent_service.dart';

class TelemetryController extends ChangeNotifier {
  TelemetryController({
    required this.enableFirebase,
    FirebaseAnalytics? analytics,
    FirebaseCrashlytics? crashlytics,
  })  : _analytics = enableFirebase
            ? analytics ?? FirebaseAnalytics.instance
            : null,
        _crashlytics = enableFirebase
            ? crashlytics ?? FirebaseCrashlytics.instance
            : null;

  final bool enableFirebase;
  final FirebaseAnalytics? _analytics;
  final FirebaseCrashlytics? _crashlytics;

  bool _loaded = false;
  bool _consent = false;
  bool _hasDecision = false;

  bool get isLoaded => _loaded;
  bool get isConsentGranted => _consent;
  bool get hasRecordedDecision => _hasDecision;

  NavigatorObserver? get analyticsObserver => AnalyticsService.observer;

  Future<void> initialize() async {
    await ConsentService.load();
    _consent = ConsentService.consentGranted;
    _hasDecision = ConsentService.hasRecordedDecision;

    if (enableFirebase) {
      await _applyTelemetryState(_consent);
    }

    _loaded = true;
    notifyListeners();
  }

  Future<void> updateConsent(bool granted) async {
    await ConsentService.setConsent(granted);
    _consent = granted;
    _hasDecision = true;

    if (enableFirebase) {
      await _applyTelemetryState(granted);
    }

    notifyListeners();
  }

  Future<void> _applyTelemetryState(bool granted) async {
    final crashlytics = _crashlytics;
    if (crashlytics != null) {
      await crashlytics.setCrashlyticsCollectionEnabled(granted);
    }
    final analytics = _analytics;
    if (analytics != null) {
      await analytics.setAnalyticsCollectionEnabled(granted);
    }

    if (granted) {
      if (!AnalyticsService.enabled && analytics != null) {
        await AnalyticsService.configure(analytics);
      }
      await AnalyticsService.logAppOpen();
    }
  }
}

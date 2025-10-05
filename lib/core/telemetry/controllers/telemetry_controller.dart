import 'package:flutter/widgets.dart';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import 'package:habit_tracker/core/services/analytics_service.dart';
import 'package:habit_tracker/core/services/consent_service.dart';

class TelemetryController extends ChangeNotifier {
  TelemetryController({
    required this.enableFirebase,
    FirebaseAnalytics? analytics,
    FirebaseCrashlytics? crashlytics,
  }) : _analytics = enableFirebase
           ? analytics ?? FirebaseAnalytics.instance
           : null,
       _crashlytics = enableFirebase
           ? crashlytics ?? FirebaseCrashlytics.instance
           : null;

  final bool enableFirebase;
  final FirebaseAnalytics? _analytics;
  final FirebaseCrashlytics? _crashlytics;

  bool _loaded = false;
  bool _analyticsConsent = false;
  bool _crashConsent = false;
  bool _hasAnalyticsDecision = false;
  bool _hasCrashDecision = false;

  bool get isLoaded => _loaded;
  bool get isAnalyticsEnabled => _analyticsConsent;
  bool get isCrashEnabled => _crashConsent;
  bool get isConsentGranted => _analyticsConsent && _crashConsent;
  bool get hasAnalyticsDecision => _hasAnalyticsDecision;
  bool get hasCrashDecision => _hasCrashDecision;
  bool get hasRecordedDecision => _hasAnalyticsDecision && _hasCrashDecision;

  NavigatorObserver? get analyticsObserver => AnalyticsService.observer;

  Future<void> initialize() async {
    await ConsentService.load();
    _analyticsConsent = ConsentService.analyticsConsentGranted;
    _crashConsent = ConsentService.crashConsentGranted;
    _hasAnalyticsDecision = ConsentService.hasAnalyticsDecision;
    _hasCrashDecision = ConsentService.hasCrashDecision;

    if (enableFirebase) {
      await _applyAnalyticsState(_analyticsConsent);
      await _applyCrashState(_crashConsent);
    } else if (!_analyticsConsent) {
      AnalyticsService.disable();
    }

    _loaded = true;
    notifyListeners();
  }

  Future<void> updateConsent(bool granted) async {
    await _setAnalyticsConsent(granted);
    await _setCrashConsent(granted);
    notifyListeners();
  }

  Future<void> updateAnalyticsConsent(bool granted) async {
    await _setAnalyticsConsent(granted);
    notifyListeners();
  }

  Future<void> updateCrashConsent(bool granted) async {
    await _setCrashConsent(granted);
    notifyListeners();
  }

  Future<void> _setAnalyticsConsent(bool granted) async {
    await ConsentService.setAnalyticsConsent(granted);
    _analyticsConsent = granted;
    _hasAnalyticsDecision = true;

    if (enableFirebase) {
      await _applyAnalyticsState(granted);
    } else if (!granted) {
      AnalyticsService.disable();
    }
  }

  Future<void> _setCrashConsent(bool granted) async {
    await ConsentService.setCrashConsent(granted);
    _crashConsent = granted;
    _hasCrashDecision = true;

    if (enableFirebase) {
      await _applyCrashState(granted);
    }
  }

  Future<void> _applyAnalyticsState(bool granted) async {
    final analytics = _analytics;
    if (analytics != null) {
      await analytics.setAnalyticsCollectionEnabled(granted);
      if (granted) {
        if (!AnalyticsService.enabled) {
          await AnalyticsService.configure(analytics);
        }
        await AnalyticsService.logAppOpen();
      } else {
        AnalyticsService.disable();
      }
    }
  }

  Future<void> _applyCrashState(bool granted) async {
    final crashlytics = _crashlytics;
    if (crashlytics != null) {
      await crashlytics.setCrashlyticsCollectionEnabled(granted);
    }
  }
}

import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import 'package:habit_tracker/core/services/analytics_service.dart';
import 'package:habit_tracker/core/services/consent_service.dart';

class TelemetryConfig {
  const TelemetryConfig({
    this.enableFirebase = false,
    this.analytics,
    this.crashlytics,
  });

  final bool enableFirebase;
  final FirebaseAnalytics? analytics;
  final FirebaseCrashlytics? crashlytics;
}

final telemetryConfigProvider = Provider<TelemetryConfig>((ref) {
  return const TelemetryConfig();
});

class TelemetryState {
  const TelemetryState({
    this.isLoaded = false,
    this.analyticsConsent = false,
    this.crashConsent = false,
    this.hasAnalyticsDecision = false,
    this.hasCrashDecision = false,
  });

  final bool isLoaded;
  final bool analyticsConsent;
  final bool crashConsent;
  final bool hasAnalyticsDecision;
  final bool hasCrashDecision;

  bool get isConsentGranted => analyticsConsent && crashConsent;
  bool get hasRecordedDecision => hasAnalyticsDecision && hasCrashDecision;

  TelemetryState copyWith({
    bool? isLoaded,
    bool? analyticsConsent,
    bool? crashConsent,
    bool? hasAnalyticsDecision,
    bool? hasCrashDecision,
  }) {
    return TelemetryState(
      isLoaded: isLoaded ?? this.isLoaded,
      analyticsConsent: analyticsConsent ?? this.analyticsConsent,
      crashConsent: crashConsent ?? this.crashConsent,
      hasAnalyticsDecision: hasAnalyticsDecision ?? this.hasAnalyticsDecision,
      hasCrashDecision: hasCrashDecision ?? this.hasCrashDecision,
    );
  }
}

class TelemetryController extends Notifier<TelemetryState> {
  TelemetryController({
    bool? enableFirebase,
    FirebaseAnalytics? analytics,
    FirebaseCrashlytics? crashlytics,
  }) : _configOverride = (enableFirebase == null &&
            analytics == null &&
            crashlytics == null)
          ? null
          : TelemetryConfig(
              enableFirebase: enableFirebase ?? false,
              analytics: analytics,
              crashlytics: crashlytics,
            );

  final TelemetryConfig? _configOverride;

  late bool enableFirebase;
  late FirebaseAnalytics? _analytics;
  late FirebaseCrashlytics? _crashlytics;

  bool get isLoaded => state.isLoaded;
  bool get isAnalyticsEnabled => state.analyticsConsent;
  bool get isCrashEnabled => state.crashConsent;
  bool get isConsentGranted => state.isConsentGranted;
  bool get hasAnalyticsDecision => state.hasAnalyticsDecision;
  bool get hasCrashDecision => state.hasCrashDecision;
  bool get hasRecordedDecision => state.hasRecordedDecision;

  NavigatorObserver? get analyticsObserver => AnalyticsService.observer;

  @override
  TelemetryState build() {
    final TelemetryConfig config =
        _configOverride ?? ref.read(telemetryConfigProvider);
    enableFirebase = config.enableFirebase;
    _analytics = enableFirebase
        ? (config.analytics ?? FirebaseAnalytics.instance)
        : null;
    _crashlytics = enableFirebase
        ? (config.crashlytics ?? FirebaseCrashlytics.instance)
        : null;

    Future<void>.microtask(() async {
      if (!ref.mounted) return;
      await initialize();
    });
    return const TelemetryState();
  }

  Future<void> initialize() async {
    if (state.isLoaded) return;

    await ConsentService.load();
    final analyticsConsent = ConsentService.analyticsConsentGranted;
    final crashConsent = ConsentService.crashConsentGranted;
    final hasAnalyticsDecision = ConsentService.hasAnalyticsDecision;
    final hasCrashDecision = ConsentService.hasCrashDecision;

    if (enableFirebase) {
      await _applyAnalyticsState(analyticsConsent);
      await _applyCrashState(crashConsent);
    } else if (!analyticsConsent) {
      AnalyticsService.disable();
    }

    state = state.copyWith(
      isLoaded: true,
      analyticsConsent: analyticsConsent,
      crashConsent: crashConsent,
      hasAnalyticsDecision: hasAnalyticsDecision,
      hasCrashDecision: hasCrashDecision,
    );
  }

  Future<void> updateConsent(bool granted) async {
    await _setAnalyticsConsent(granted);
    await _setCrashConsent(granted);
  }

  Future<void> updateAnalyticsConsent(bool granted) async {
    await _setAnalyticsConsent(granted);
  }

  Future<void> updateCrashConsent(bool granted) async {
    await _setCrashConsent(granted);
  }

  Future<void> _setAnalyticsConsent(bool granted) async {
    await ConsentService.setAnalyticsConsent(granted);

    if (enableFirebase) {
      await _applyAnalyticsState(granted);
    } else if (!granted) {
      AnalyticsService.disable();
    }

    state = state.copyWith(
      analyticsConsent: granted,
      hasAnalyticsDecision: true,
    );
  }

  Future<void> _setCrashConsent(bool granted) async {
    await ConsentService.setCrashConsent(granted);

    if (enableFirebase) {
      await _applyCrashState(granted);
    }

    state = state.copyWith(
      crashConsent: granted,
      hasCrashDecision: true,
    );
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

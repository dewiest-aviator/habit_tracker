import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:habit_tracker/core/services/analytics_service.dart';

import 'controllers/time_preferences_controller.dart';

@immutable
class SettingsAnalytics {
  const SettingsAnalytics();

  Future<void> logView({
    required ThemeMode themeMode,
    required Locale? locale,
    required bool analyticsEnabled,
    required bool crashEnabled,
    required TimeFormatPreference timePreference,
  }) {
    return AnalyticsService.logEvent(
      'settings_view',
      parameters: <String, Object?>{
        'theme': themeMode.name,
        'language': locale?.languageCode ?? 'system',
        'analytics_enabled': analyticsEnabled ? 1 : 0,
        'crash_enabled': crashEnabled ? 1 : 0,
        'time_format': _timePreferenceValue(timePreference),
      },
    );
  }

  Future<void> logThemeChange({
    required ThemeMode newTheme,
    required ThemeMode previousTheme,
  }) {
    return AnalyticsService.logEvent(
      'settings_theme_change',
      parameters: <String, Object?>{
        'theme_new': newTheme.name,
        'theme_old': previousTheme.name,
      },
    );
  }

  Future<void> logLanguageChange({
    required Locale? newLocale,
    required Locale? previousLocale,
  }) {
    return AnalyticsService.logEvent(
      'settings_language_change',
      parameters: <String, Object?>{
        'lang_new': newLocale?.languageCode ?? 'system',
        'lang_old': previousLocale?.languageCode ?? 'system',
      },
    );
  }

  Future<void> logTimeFormatChange(TimeFormatPreference preference) {
    return AnalyticsService.logEvent(
      'settings_time_format_change',
      parameters: <String, Object?>{
        'use_24h': preference == TimeFormatPreference.h24 ? 1 : 0,
        'time_format': _timePreferenceValue(preference),
      },
    );
  }

  Future<void> logAnalyticsToggle(bool enabled) {
    return AnalyticsService.logEvent(
      'settings_analytics_toggle',
      parameters: <String, Object?>{'enabled': enabled ? 1 : 0},
    );
  }

  Future<void> logCrashToggle(bool enabled) {
    return AnalyticsService.logEvent(
      'settings_crash_toggle',
      parameters: <String, Object?>{'enabled': enabled ? 1 : 0},
    );
  }

  Future<void> logRateAppTap({required bool inAppAvailable}) {
    return AnalyticsService.logEvent(
      'settings_rate_tap',
      parameters: <String, Object?>{'in_app_available': inAppAvailable ? 1 : 0},
    );
  }

  Future<void> logReportIssueTap({required bool logReady, int? logSizeBytes}) {
    return AnalyticsService.logEvent(
      'settings_report_issue_tap',
      parameters: <String, Object?>{
        'log_ready': logReady ? 1 : 0,
        if (logSizeBytes != null) 'log_size_kb': (logSizeBytes / 1024).round(),
      },
    );
  }

  Future<void> logPrivacyPolicyOpen() {
    return AnalyticsService.logEvent(
      'settings_privacy_open',
      parameters: const <String, Object?>{'in_app': 1},
    );
  }

  Future<void> logReleaseNotesOpen() {
    return AnalyticsService.logEvent(
      'settings_release_notes_open',
      parameters: const <String, Object?>{'in_app': 1},
    );
  }

  Future<void> logLicensesOpen() {
    return AnalyticsService.logEvent('settings_licenses_open');
  }

  String _timePreferenceValue(TimeFormatPreference preference) {
    switch (preference) {
      case TimeFormatPreference.system:
        return 'system';
      case TimeFormatPreference.h12:
        return '12h';
      case TimeFormatPreference.h24:
        return '24h';
    }
  }
}

final settingsAnalyticsProvider = Provider<SettingsAnalytics>((ref) {
  return const SettingsAnalytics();
});

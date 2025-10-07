import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum TimeFormatPreference { system, h12, h24 }

class TimePreferencesState {
  const TimePreferencesState({
    this.preference = TimeFormatPreference.system,
    this.hasLoaded = false,
  });

  final TimeFormatPreference preference;
  final bool hasLoaded;

  TimePreferencesState copyWith({
    TimeFormatPreference? preference,
    bool? hasLoaded,
  }) {
    return TimePreferencesState(
      preference: preference ?? this.preference,
      hasLoaded: hasLoaded ?? this.hasLoaded,
    );
  }
}

class TimePreferencesController extends Notifier<TimePreferencesState> {
  TimePreferencesController({SharedPreferences? preferences})
    : _providedPrefs = preferences;

  static const _prefsKey = 'time_format_pref';

  final SharedPreferences? _providedPrefs;
  SharedPreferences? _prefs;

  TimeFormatPreference get preference => state.preference;
  bool get hasLoaded => state.hasLoaded;

  @override
  TimePreferencesState build() {
    Future<void>.microtask(() async {
      if (!ref.mounted) return;
      await load();
    });
    return const TimePreferencesState();
  }

  Future<void> load() async {
    if (state.hasLoaded && _prefs != null) return;

    final prefs = _providedPrefs ?? await SharedPreferences.getInstance();
    _prefs = prefs;
    final stored = prefs.getString(_prefsKey);
    state = state.copyWith(
      preference: _stringToPreference(stored),
      hasLoaded: true,
    );
  }

  Future<void> setPreference(TimeFormatPreference preference) async {
    if (state.hasLoaded && state.preference == preference) return;

    state = state.copyWith(preference: preference, hasLoaded: true);

    final prefs =
        _prefs ?? _providedPrefs ?? await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, _preferenceToString(preference));
    _prefs = prefs;
  }

  TimeFormatPreference _stringToPreference(String? value) {
    switch (value) {
      case '12h':
        return TimeFormatPreference.h12;
      case '24h':
        return TimeFormatPreference.h24;
      case 'system':
      default:
        return TimeFormatPreference.system;
    }
  }

  String _preferenceToString(TimeFormatPreference preference) {
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

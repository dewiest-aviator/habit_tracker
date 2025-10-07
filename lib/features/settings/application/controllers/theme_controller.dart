import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeState {
  const ThemeState({this.themeMode = ThemeMode.system, this.hasLoaded = false});

  final ThemeMode themeMode;
  final bool hasLoaded;

  ThemeState copyWith({ThemeMode? themeMode, bool? hasLoaded}) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
      hasLoaded: hasLoaded ?? this.hasLoaded,
    );
  }
}

class ThemeController extends Notifier<ThemeState> {
  ThemeController({SharedPreferences? preferences})
    : _providedPrefs = preferences;

  static const _prefsKey = 'theme_mode';

  final SharedPreferences? _providedPrefs;
  SharedPreferences? _prefs;

  ThemeMode get themeMode => state.themeMode;
  bool get hasLoaded => state.hasLoaded;

  @override
  ThemeState build() {
    Future<void>.microtask(() async {
      if (!ref.mounted) return;
      await load();
    });
    return const ThemeState();
  }

  Future<void> load() async {
    if (state.hasLoaded && _prefs != null) return;

    final prefs = _providedPrefs ?? await SharedPreferences.getInstance();
    _prefs = prefs;
    state = state.copyWith(
      themeMode: _stringToThemeMode(prefs.getString(_prefsKey)),
      hasLoaded: true,
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (state.hasLoaded && state.themeMode == mode) return;

    state = state.copyWith(themeMode: mode, hasLoaded: true);

    final prefs =
        _prefs ?? _providedPrefs ?? await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, mode.name);
    _prefs = prefs;
  }

  ThemeMode _stringToThemeMode(String? value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }
}

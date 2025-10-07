import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_tracker/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageState {
  const LanguageState({this.locale, this.hasLoaded = false});

  final Locale? locale;
  final bool hasLoaded;

  LanguageState copyWith({Locale? locale, bool? hasLoaded}) {
    return LanguageState(
      locale: locale ?? this.locale,
      hasLoaded: hasLoaded ?? this.hasLoaded,
    );
  }
}

class LanguageController extends Notifier<LanguageState> {
  LanguageController({SharedPreferences? preferences})
    : _providedPrefs = preferences;

  static const _prefsKey = 'language_code';

  final SharedPreferences? _providedPrefs;
  SharedPreferences? _prefs;

  Locale? get locale => state.locale;
  bool get hasLoaded => state.hasLoaded;

  @override
  LanguageState build() {
    Future<void>.microtask(() async {
      if (!ref.mounted) return;
      await load();
    });
    return const LanguageState();
  }

  Future<void> load() async {
    if (state.hasLoaded && _prefs != null) return;

    final prefs = _providedPrefs ?? await SharedPreferences.getInstance();
    _prefs = prefs;
    final resolved = _stringToLocale(prefs.getString(_prefsKey));
    state = state.copyWith(locale: resolved, hasLoaded: true);
  }

  Future<void> setLocale(Locale? locale) async {
    if (state.hasLoaded && state.locale == locale) return;

    state = state.copyWith(locale: locale, hasLoaded: true);

    final prefs =
        _prefs ?? _providedPrefs ?? await SharedPreferences.getInstance();
    if (locale == null) {
      await prefs.remove(_prefsKey);
    } else {
      await prefs.setString(_prefsKey, locale.languageCode);
    }
    _prefs = prefs;
  }

  Locale? _stringToLocale(String? code) {
    if (code == null || code.isEmpty) return null;
    for (final locale in AppLocalizations.supportedLocales) {
      if (locale.languageCode == code) {
        return locale;
      }
    }
    return null;
  }
}

import 'package:flutter/material.dart';
import 'package:habit_tracker/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageController extends ChangeNotifier {
  LanguageController({SharedPreferences? preferences})
    : _providedPrefs = preferences;

  static const _prefsKey = 'language_code';

  final SharedPreferences? _providedPrefs;
  SharedPreferences? _prefs;

  Locale? _locale;
  bool _hasLoaded = false;

  Locale? get locale => _locale;
  bool get hasLoaded => _hasLoaded;

  Future<void> load() async {
    final prefs = _providedPrefs ?? await SharedPreferences.getInstance();
    _prefs = prefs;
    _locale = _stringToLocale(prefs.getString(_prefsKey));
    _hasLoaded = true;
    notifyListeners();
  }

  Future<void> setLocale(Locale? locale) async {
    if (_hasLoaded && _locale == locale) return;

    _locale = locale;
    _hasLoaded = true;
    notifyListeners();

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

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends ChangeNotifier {
  ThemeController({SharedPreferences? preferences})
    : _providedPrefs = preferences;

  static const _prefsKey = 'theme_mode';

  final SharedPreferences? _providedPrefs;
  SharedPreferences? _prefs;

  ThemeMode _themeMode = ThemeMode.system;
  bool _hasLoaded = false;

  ThemeMode get themeMode => _themeMode;
  bool get hasLoaded => _hasLoaded;

  Future<void> load() async {
    final prefs = _providedPrefs ?? await SharedPreferences.getInstance();
    _prefs = prefs;
    _themeMode = _stringToThemeMode(prefs.getString(_prefsKey));
    _hasLoaded = true;
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode && _hasLoaded) return;
    _themeMode = mode;
    _hasLoaded = true;
    notifyListeners();

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

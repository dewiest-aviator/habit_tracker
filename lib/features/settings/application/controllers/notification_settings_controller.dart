import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationSettingsController extends ChangeNotifier {
  NotificationSettingsController({SharedPreferences? preferences})
    : _providedPrefs = preferences;

  static const _enabledKey = 'notifications_enabled';
  static const _timeKey = 'notifications_time';

  final SharedPreferences? _providedPrefs;
  SharedPreferences? _prefs;

  bool _hasLoaded = false;
  bool _enabled = false;
  TimeOfDay _time = const TimeOfDay(hour: 8, minute: 0);

  bool get hasLoaded => _hasLoaded;
  bool get enabled => _enabled;
  TimeOfDay get reminderTime => _time;

  Future<void> load() async {
    final prefs = _providedPrefs ?? await SharedPreferences.getInstance();
    _prefs = prefs;

    _enabled = prefs.getBool(_enabledKey) ?? false;
    final stored = prefs.getString(_timeKey);
    if (stored != null) {
      final parts = stored.split(':');
      if (parts.length == 2) {
        final hour = int.tryParse(parts[0]);
        final minute = int.tryParse(parts[1]);
        if (hour != null && minute != null) {
          _time = TimeOfDay(hour: hour, minute: minute);
        }
      }
    }

    _hasLoaded = true;
    notifyListeners();
  }

  Future<void> setEnabled(bool value) async {
    if (_enabled == value && _hasLoaded) return;
    _enabled = value;
    _hasLoaded = true;
    notifyListeners();

    final prefs =
        _prefs ?? _providedPrefs ?? await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey, value);
    _prefs = prefs;
  }

  Future<void> setReminderTime(TimeOfDay time) async {
    if (_time == time && _hasLoaded) return;
    _time = time;
    _hasLoaded = true;
    notifyListeners();

    final prefs =
        _prefs ?? _providedPrefs ?? await SharedPreferences.getInstance();
    final formatted =
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    await prefs.setString(_timeKey, formatted);
    _prefs = prefs;
  }
}

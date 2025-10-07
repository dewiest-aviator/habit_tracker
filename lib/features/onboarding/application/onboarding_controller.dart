import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../habits/data/repositories/habits_repository.dart';
import '../../habits/domain/domain.dart';
import '../../settings/application/controllers/notification_settings_controller.dart';
import '../../settings/application/providers/notification_settings_provider.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/telemetry/controllers/telemetry_controller.dart';
import '../../../core/telemetry/providers/telemetry_provider.dart';
import 'onboarding_analytics.dart';
import 'onboarding_state.dart';
import 'starter_habit_template.dart';

class OnboardingController extends Notifier<OnboardingState> {
  late final HabitsRepository _habitsRepository;
  late final NotificationService _notificationService;
  late final NotificationSettingsController _notificationSettings;
  late final TelemetryController _telemetryController;
  late final OnboardingAnalytics _analytics;
  late final SharedPreferences? _providedPrefs;

  static const hasOnboardedKey = 'has_onboarded';

  SharedPreferences? _prefs;

  Future<SharedPreferences> _prefsInstance() async {
    return _prefs ??= _providedPrefs ?? await SharedPreferences.getInstance();
  }

  @override
  OnboardingState build() {
    _habitsRepository = ref.read(habitsRepositoryProvider);
    _notificationService = ref.read(notificationServiceProvider);
    _notificationSettings = ref.read(notificationSettingsProvider.notifier);
    _telemetryController = ref.read(telemetryControllerProvider.notifier);
    _analytics = ref.read(onboardingAnalyticsProvider);
    _providedPrefs = ref.read(onboardingPreferencesProvider);

    Future<void>.microtask(() {
      if (!ref.mounted) return;
      _analytics.logPageView(0);
    });

    return const OnboardingState();
  }

  void setPageIndex(int index) {
    if (index == state.pageIndex) return;
    state = state.copyWith(pageIndex: index);
    _analytics.logPageView(index);
  }

  Future<bool> skipOnboarding() async {
    if (state.isSaving) return false;
    state = state.copyWith(isSaving: true, errorMessage: null);

    try {
      await _createSelectedHabits();
      await _notificationSettings.setEnabled(false);
      state = state.copyWith(
        permissionStatus: NotificationPermissionStatus.denied,
        errorMessage: null,
      );
      await _applyTelemetryConsent();
      final prefs = await _prefsInstance();
      await prefs.setBool(hasOnboardedKey, true);
      state = state.copyWith(isSaving: false);
      _analytics.logSkip();
      _analytics.logComplete(selectedCount: state.selectedHabits.length);
      return true;
    } catch (error) {
      state = state.copyWith(isSaving: false, errorMessage: error.toString());
      return false;
    }
  }

  void toggleHabit(StarterHabitTemplate template, String label) {
    final current = Map<String, String>.from(state.selectedHabits);
    if (current.containsKey(template.id)) {
      current.remove(template.id);
      state = state.copyWith(selectedHabits: current);
      _analytics.logHabitToggle(template, label, false);
      return;
    }

    if (current.length >= 3) {
      _analytics.logHabitToggle(template, label, false);
      return;
    }

    current[template.id] = label;
    state = state.copyWith(selectedHabits: current);
    _analytics.logHabitToggle(template, label, true);
  }

  void setAnalyticsConsent(bool value) {
    if (state.analyticsConsent == value) return;
    state = state.copyWith(analyticsConsent: value);
    _analytics.logConsentUpdate(channel: 'analytics', granted: value);
  }

  void setCrashConsent(bool value) {
    if (state.crashConsent == value) return;
    state = state.copyWith(crashConsent: value);
    _analytics.logConsentUpdate(channel: 'crash', granted: value);
  }

  Future<void> enableNotifications() async {
    if (state.isRequestingPermission) return;
    state = state.copyWith(isRequestingPermission: true, errorMessage: null);

    try {
      final granted = await _notificationService.requestPermission();
      await _notificationSettings.setEnabled(granted);
      state = state.copyWith(
        permissionStatus: granted
            ? NotificationPermissionStatus.granted
            : NotificationPermissionStatus.denied,
        isRequestingPermission: false,
      );
      _analytics.logNotificationsRequest(granted: granted);
    } catch (error) {
      state = state.copyWith(
        errorMessage: error.toString(),
        permissionStatus: NotificationPermissionStatus.denied,
        isRequestingPermission: false,
      );
      _analytics.logNotificationsRequest(granted: false);
    }
  }

  Future<void> declineNotifications() async {
    await _notificationSettings.setEnabled(false);
    state = state.copyWith(
      permissionStatus: NotificationPermissionStatus.denied,
      errorMessage: null,
    );
    _analytics.logNotificationsDeclined();
  }

  Future<bool> completeOnboarding() async {
    if (state.isSaving) return false;
    state = state.copyWith(isSaving: true, errorMessage: null);

    try {
      await _createSelectedHabits();
      await _applyTelemetryConsent();
      final prefs = await _prefsInstance();
      await prefs.setBool(hasOnboardedKey, true);
      state = state.copyWith(isSaving: false);
      _analytics.logComplete(selectedCount: state.selectedHabits.length);
      return true;
    } catch (error) {
      state = state.copyWith(isSaving: false, errorMessage: error.toString());
      return false;
    }
  }

  Future<void> _createSelectedHabits() async {
    if (state.selectedHabits.isEmpty) return;
    final templates = {
      for (final template in starterHabitTemplates) template.id: template,
    };
    var counter = 0;
    final timestamp = DateTime.now().microsecondsSinceEpoch;
    for (final entry in state.selectedHabits.entries) {
      final template = templates[entry.key];
      if (template == null) continue;
      final habitId =
          'starter_${template.id}_${timestamp}_${counter.toRadixString(16)}';
      counter += 1;
      final habit = Habit(
        id: habitId,
        name: entry.value,
        emoji: template.emoji,
        color: template.color,
        days: List<int>.generate(7, (index) => index),
        reminderId: habitId,
        reminderTime: '08:00',
        bestStreak: 0,
        currentStreak: 0,
      );
      await _habitsRepository.saveHabit(habit);
    }
  }

  Future<void> _applyTelemetryConsent() async {
    await _telemetryController.updateAnalyticsConsent(state.analyticsConsent);
    await _telemetryController.updateCrashConsent(state.crashConsent);
  }
}

final onboardingPreferencesProvider = Provider<SharedPreferences?>((ref) {
  return null;
});

final onboardingControllerProvider =
    NotifierProvider<OnboardingController, OnboardingState>(
      OnboardingController.new,
    );

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../habits/data/repositories/habits_repository.dart';
import '../../habits/domain/domain.dart';
import '../../settings/application/controllers/notification_settings_controller.dart';
import '../../settings/application/providers/notification_settings_provider.dart';
import '../../../core/services/notification_service.dart';
import 'onboarding_state.dart';
import 'starter_habit_template.dart';

class OnboardingController extends StateNotifier<OnboardingState> {
  OnboardingController({
    required HabitsRepository habitsRepository,
    required NotificationService notificationService,
    required NotificationSettingsController notificationSettings,
    SharedPreferences? preferences,
  })  : _habitsRepository = habitsRepository,
        _notificationService = notificationService,
        _notificationSettings = notificationSettings,
        _providedPrefs = preferences,
        super(const OnboardingState());

  static const hasOnboardedKey = 'has_onboarded';

  final HabitsRepository _habitsRepository;
  final NotificationService _notificationService;
  final NotificationSettingsController _notificationSettings;
  final SharedPreferences? _providedPrefs;

  SharedPreferences? _prefs;

  Future<SharedPreferences> _prefsInstance() async {
    return _prefs ??= _providedPrefs ?? await SharedPreferences.getInstance();
  }

  void setPageIndex(int index) {
    if (index == state.pageIndex) return;
    state = state.copyWith(pageIndex: index);
  }

  void skipToNotifications() {
    setPageIndex(2);
  }

  void toggleHabit(StarterHabitTemplate template, String label) {
    final current = Map<String, String>.from(state.selectedHabits);
    if (current.containsKey(template.id)) {
      current.remove(template.id);
      state = state.copyWith(selectedHabits: current);
      return;
    }

    if (current.length >= 3) {
      return;
    }

    current[template.id] = label;
    state = state.copyWith(selectedHabits: current);
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
    } catch (error) {
      state = state.copyWith(
        errorMessage: error.toString(),
        permissionStatus: NotificationPermissionStatus.denied,
        isRequestingPermission: false,
      );
    }
  }

  Future<void> declineNotifications() async {
    await _notificationSettings.setEnabled(false);
    state = state.copyWith(
      permissionStatus: NotificationPermissionStatus.denied,
      errorMessage: null,
    );
  }

  Future<bool> completeOnboarding() async {
    if (state.isSaving) return false;
    state = state.copyWith(isSaving: true, errorMessage: null);

    try {
      await _createSelectedHabits();
      final prefs = await _prefsInstance();
      await prefs.setBool(hasOnboardedKey, true);
      state = state.copyWith(isSaving: false);
      return true;
    } catch (error) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: error.toString(),
      );
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
}

final onboardingControllerProvider =
    StateNotifierProvider<OnboardingController, OnboardingState>((ref) {
  final habitsRepository = ref.watch(habitsRepositoryProvider);
  final notificationService = ref.watch(notificationServiceProvider);
  final notificationSettings = ref.watch(notificationSettingsProvider);

  return OnboardingController(
    habitsRepository: habitsRepository,
    notificationService: notificationService,
    notificationSettings: notificationSettings,
  );
});

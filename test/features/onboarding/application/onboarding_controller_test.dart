import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:habit_tracker/core/services/consent_service.dart';
import 'package:habit_tracker/core/services/notification_service.dart';
import 'package:habit_tracker/core/telemetry/controllers/telemetry_controller.dart';
import 'package:habit_tracker/core/telemetry/providers/telemetry_provider.dart';
import 'package:habit_tracker/features/habits/data/repositories/habits_repository.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit.dart';
import 'package:habit_tracker/features/onboarding/application/onboarding_analytics.dart';
import 'package:habit_tracker/features/onboarding/application/onboarding_controller.dart';
import 'package:habit_tracker/features/onboarding/application/onboarding_state.dart';
import 'package:habit_tracker/features/onboarding/application/starter_habit_template.dart';
import 'package:habit_tracker/features/settings/application/controllers/notification_settings_controller.dart';
import 'package:habit_tracker/features/settings/application/providers/notification_settings_provider.dart';

class _MockHabitsRepository extends Mock implements HabitsRepository {}

class _MockNotificationService extends Mock implements NotificationService {}

class _StubOnboardingAnalytics extends OnboardingAnalytics {
  const _StubOnboardingAnalytics();

  @override
  Future<void> logPageView(int index) async {}

  @override
  Future<void> logGetStartedTap() async {}

  @override
  Future<void> logSkip() async {}

  @override
  Future<void> logHabitToggle(
    StarterHabitTemplate template,
    String label,
    bool selected,
  ) async {}

  @override
  Future<void> logNotificationsRequest({required bool granted}) async {}

  @override
  Future<void> logNotificationsDeclined() async {}

  @override
  Future<void> logComplete({required int selectedCount}) async {}

  @override
  Future<void> logConsentUpdate({
    required String channel,
    required bool granted,
  }) async {}
}

void main() {
  late ProviderContainer container;
  late SharedPreferences prefs;
  late _MockHabitsRepository habitsRepository;
  late _MockNotificationService notificationService;

  setUpAll(() {
    registerFallbackValue(
      Habit(
        id: 'fallback',
        name: 'Fallback',
        emoji: '✨',
        color: 0xFFFFFFFF,
        days: const [0, 1, 2, 3, 4, 5, 6],
        reminderId: 'fallback',
        reminderTime: '08:00',
        bestStreak: 0,
        currentStreak: 0,
      ),
    );
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    await ConsentService.reset();

    habitsRepository = _MockHabitsRepository();
    notificationService = _MockNotificationService();

    when(() => habitsRepository.saveHabit(any())).thenAnswer((_) async {});
    when(
      () => notificationService.requestPermission(),
    ).thenAnswer((_) async => true);

    container = ProviderContainer(
      overrides: [
        habitsRepositoryProvider.overrideWithValue(habitsRepository),
        notificationServiceProvider.overrideWithValue(notificationService),
        notificationSettingsProvider.overrideWith(
          () => NotificationSettingsController(preferences: prefs),
        ),
        telemetryConfigProvider.overrideWithValue(
          const TelemetryConfig(enableFirebase: false),
        ),
        telemetryControllerProvider.overrideWith(TelemetryController.new),
        onboardingPreferencesProvider.overrideWithValue(prefs),
        onboardingAnalyticsProvider.overrideWithValue(
          const _StubOnboardingAnalytics(),
        ),
      ],
    );

    await container.read(telemetryControllerProvider.notifier).initialize();
    await container.read(notificationSettingsProvider.notifier).load();
  });

  tearDown(() {
    container.dispose();
  });

  OnboardingController controller() =>
      container.read(onboardingControllerProvider.notifier);

  OnboardingState state() => container.read(onboardingControllerProvider);

  test('limits starter habit selection to three items', () {
    final ctrl = controller();

    ctrl.toggleHabit(starterHabitTemplates[0], 'Meditate');
    ctrl.toggleHabit(starterHabitTemplates[1], 'Walk');
    ctrl.toggleHabit(starterHabitTemplates[2], 'Drink water');
    ctrl.toggleHabit(starterHabitTemplates[3], 'Journal');

    final current = state().selectedHabits;
    expect(current.length, 3);
    expect(current.containsKey('journal'), isFalse);
  });

  test('persists selected habits and sets onboarding flag', () async {
    final ctrl = controller();
    ctrl.toggleHabit(starterHabitTemplates[0], 'Meditate');
    ctrl.toggleHabit(starterHabitTemplates[1], 'Walk');

    final result = await ctrl.completeOnboarding();

    expect(result, isTrue);
    verify(() => habitsRepository.saveHabit(any())).called(2);

    final telemetryState = container.read(telemetryControllerProvider);
    expect(telemetryState.analyticsConsent, isTrue);
    expect(telemetryState.crashConsent, isTrue);
    expect(prefs.getBool(OnboardingController.hasOnboardedKey), isTrue);
  });

  test('updates permission status when enabling reminders', () async {
    final ctrl = controller();

    await ctrl.enableNotifications();

    final onboardingState = state();
    expect(
      onboardingState.permissionStatus,
      NotificationPermissionStatus.granted,
    );
    final notifSettings = container.read(notificationSettingsProvider);
    expect(notifSettings.enabled, isTrue);
    verify(() => notificationService.requestPermission()).called(1);
  });

  test('handles platform denial when enabling reminders', () async {
    when(
      () => notificationService.requestPermission(),
    ).thenAnswer((_) async => false);
    final ctrl = controller();

    await ctrl.enableNotifications();

    final onboardingState = state();
    expect(
      onboardingState.permissionStatus,
      NotificationPermissionStatus.denied,
    );
    final notifSettings = container.read(notificationSettingsProvider);
    expect(notifSettings.enabled, isFalse);
  });

  test('declining reminders disables notifications', () async {
    final ctrl = controller();

    await ctrl.declineNotifications();

    final onboardingState = state();
    expect(
      onboardingState.permissionStatus,
      NotificationPermissionStatus.denied,
    );
    final notifSettings = container.read(notificationSettingsProvider);
    expect(notifSettings.enabled, isFalse);
  });

  test('updates telemetry choices', () {
    final ctrl = controller();

    ctrl.setAnalyticsConsent(false);
    ctrl.setCrashConsent(false);

    final updated = state();
    expect(updated.analyticsConsent, isFalse);
    expect(updated.crashConsent, isFalse);
  });

  test('skip onboarding records defaults and flags completion', () async {
    final ctrl = controller();
    ctrl.toggleHabit(starterHabitTemplates.first, 'Meditate');

    final result = await ctrl.skipOnboarding();

    expect(result, isTrue);
    expect(prefs.getBool(OnboardingController.hasOnboardedKey), isTrue);
    verify(() => habitsRepository.saveHabit(any())).called(1);

    final telemetryState = container.read(telemetryControllerProvider);
    expect(telemetryState.analyticsConsent, isTrue);
    expect(telemetryState.crashConsent, isTrue);

    final notifSettings = container.read(notificationSettingsProvider);
    expect(notifSettings.enabled, isFalse);
  });
}

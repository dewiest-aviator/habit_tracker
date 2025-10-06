import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:habit_tracker/features/onboarding/application/onboarding_controller.dart';
import 'package:habit_tracker/features/onboarding/application/onboarding_state.dart';
import 'package:habit_tracker/features/onboarding/application/starter_habit_template.dart';
import 'package:habit_tracker/features/habits/data/repositories/habits_repository.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit.dart';
import 'package:habit_tracker/features/settings/application/controllers/notification_settings_controller.dart';
import 'package:habit_tracker/core/services/notification_service.dart';

class _MockHabitsRepository extends Mock implements HabitsRepository {}

class _MockNotificationService extends Mock implements NotificationService {}

class _MockNotificationSettingsController extends Mock
    implements NotificationSettingsController {}

void main() {
  late _MockHabitsRepository habitsRepository;
  late _MockNotificationService notificationService;
  late _MockNotificationSettingsController notificationSettings;
  late SharedPreferences prefs;

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
    habitsRepository = _MockHabitsRepository();
    notificationService = _MockNotificationService();
    notificationSettings = _MockNotificationSettingsController();

    when(() => habitsRepository.saveHabit(any())).thenAnswer((_) async {});
    when(() => notificationSettings.setEnabled(any())).thenAnswer((_) async {});
    when(
      () => notificationService.requestPermission(),
    ).thenAnswer((_) async => true);
  });

  OnboardingController buildController() {
    return OnboardingController(
      habitsRepository: habitsRepository,
      notificationService: notificationService,
      notificationSettings: notificationSettings,
      preferences: prefs,
    );
  }

  test('limits starter habit selection to three items', () {
    final controller = buildController();

    controller.toggleHabit(starterHabitTemplates[0], 'Meditate');
    controller.toggleHabit(starterHabitTemplates[1], 'Walk');
    controller.toggleHabit(starterHabitTemplates[2], 'Drink water');
    controller.toggleHabit(starterHabitTemplates[3], 'Journal');

    expect(controller.state.selectedHabits.length, 3);
    expect(controller.state.selectedHabits.containsKey('journal'), isFalse);
  });

  test('persists selected habits and sets onboarding flag', () async {
    final controller = buildController();
    controller.toggleHabit(starterHabitTemplates[0], 'Meditate');
    controller.toggleHabit(starterHabitTemplates[1], 'Walk');

    final result = await controller.completeOnboarding();

    expect(result, isTrue);
    verify(() => habitsRepository.saveHabit(any())).called(2);
    expect(prefs.getBool(OnboardingController.hasOnboardedKey), isTrue);
  });

  test('updates permission status when enabling reminders', () async {
    final controller = buildController();

    await controller.enableNotifications();

    expect(
      controller.state.permissionStatus,
      NotificationPermissionStatus.granted,
    );
    verify(() => notificationSettings.setEnabled(true)).called(1);
    verify(() => notificationService.requestPermission()).called(1);
  });

  test('handles platform denial when enabling reminders', () async {
    when(
      () => notificationService.requestPermission(),
    ).thenAnswer((_) async => false);
    final controller = buildController();

    await controller.enableNotifications();

    expect(
      controller.state.permissionStatus,
      NotificationPermissionStatus.denied,
    );
    verify(() => notificationSettings.setEnabled(false)).called(1);
    verify(() => notificationService.requestPermission()).called(1);
  });

  test('declining reminders disables notifications', () async {
    final controller = buildController();

    await controller.declineNotifications();

    expect(
      controller.state.permissionStatus,
      NotificationPermissionStatus.denied,
    );
    verify(() => notificationSettings.setEnabled(false)).called(1);
  });

  test('skip to notifications preselects declined reminders', () async {
    final controller = buildController();

    await controller.skipToNotifications();

    expect(controller.state.pageIndex, 2);
    expect(
      controller.state.permissionStatus,
      NotificationPermissionStatus.denied,
    );
    verify(() => notificationSettings.setEnabled(false)).called(1);
  });
}

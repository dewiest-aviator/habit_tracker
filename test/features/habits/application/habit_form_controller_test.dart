import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:habit_tracker/core/services/notification_service.dart';
import 'package:habit_tracker/features/habits/application/habit_form_controller.dart';
import 'package:habit_tracker/features/habits/application/habit_form_state.dart';
import 'package:habit_tracker/features/habits/data/repositories/habit_entries_repository.dart';
import 'package:habit_tracker/features/habits/data/repositories/habits_repository.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit.dart';

class _MockHabitsRepository extends Mock implements HabitsRepository {}

class _MockHabitEntriesRepository extends Mock
    implements HabitEntriesRepository {}

class _MockNotificationService extends Mock implements NotificationService {}

class _StubAnalytics extends HabitFormAnalytics {
  const _StubAnalytics();

  @override
  Future<void> logView({
    required HabitFormMode mode,
    required bool prefilled,
  }) async {}

  @override
  Future<void> logPrefill({
    required Habit habit,
    required bool reminderEnabled,
  }) async {}

  @override
  Future<void> logFieldChange({
    required String field,
    String? valueLength,
    int? daysCount,
    bool? reminderEnabled,
  }) async {}

  @override
  Future<void> logValidationError({
    required String field,
    required String code,
  }) async {}

  @override
  Future<void> logSaveTap({
    required HabitFormMode mode,
    required bool hasChanges,
  }) async {}

  @override
  Future<void> logSaveSuccess({
    required Habit habit,
    required HabitFormMode mode,
    required bool reminderEnabled,
  }) async {}

  @override
  Future<void> logSaveFail({
    required HabitFormMode mode,
    required String errorCode,
  }) async {}

  @override
  Future<void> logDeleteTap(String habitId) async {}

  @override
  Future<void> logDeleteConfirm(String habitId) async {}

  @override
  Future<void> logReminderPermissionPrompt() async {}

  @override
  Future<void> logReminderPermissionResult({required bool granted}) async {}

  @override
  Future<void> logColorPickerOpen() async {}

  @override
  Future<void> logEmojiPickerOpen() async {}
}

void main() {
  late ProviderContainer container;
  late _MockHabitsRepository habitsRepository;
  late _MockHabitEntriesRepository habitEntriesRepository;
  late _MockNotificationService notificationService;
  const analytics = _StubAnalytics();
  final subscriptions = <String?, ProviderSubscription<HabitFormState>>{};

  setUpAll(() {
    registerFallbackValue(
      Habit(
        id: 'fallback',
        name: 'Fallback',
        emoji: '🌱',
        color: 0xFF4F46E5,
        days: const [0, 1, 2, 3, 4, 5, 6],
        reminderId: 'fallback',
        reminderTime: '',
        bestStreak: 0,
        currentStreak: 0,
      ),
    );
  });

  setUp(() {
    habitsRepository = _MockHabitsRepository();
    habitEntriesRepository = _MockHabitEntriesRepository();
    notificationService = _MockNotificationService();

    when(() => habitsRepository.countHabits()).thenAnswer((_) async => 0);
    when(() => habitsRepository.saveHabit(any())).thenAnswer((_) async {});
    when(() => habitsRepository.findById(any())).thenAnswer((_) async => null);
    when(() => habitEntriesRepository.deleteEntriesForHabit(any()))
        .thenAnswer((_) async {});
    when(() => notificationService.cancelHabitReminder(any()))
        .thenAnswer((_) async {});
    when(
      () => notificationService.scheduleHabitReminder(
        habitId: any(named: 'habitId'),
        title: any(named: 'title'),
        body: any(named: 'body'),
        days: any(named: 'days'),
        time: any(named: 'time'),
      ),
    ).thenAnswer((_) async {});
    when(() => notificationService.requestPermission())
        .thenAnswer((_) async => true);

    container = ProviderContainer(
      overrides: [
        habitsRepositoryProvider.overrideWithValue(habitsRepository),
        habitEntriesRepositoryProvider.overrideWithValue(
          habitEntriesRepository,
        ),
        notificationServiceProvider.overrideWithValue(notificationService),
        habitFormAnalyticsProvider.overrideWithValue(analytics),
      ],
    );
  });

  tearDown(() {
    for (final entry in subscriptions.values) {
      entry.close();
    }
    subscriptions.clear();
    container.dispose();
  });

  HabitFormController buildController({String? habitId}) {
    subscriptions.putIfAbsent(
      habitId,
      () => container.listen(
        habitFormControllerProvider(habitId),
        (previous, next) {},
      ),
    );
    return container.read(habitFormControllerProvider(habitId).notifier);
  }

  HabitFormState readState({String? habitId}) {
    return container.read(habitFormControllerProvider(habitId));
  }

  HabitReminderStrings reminderStrings() {
    return const HabitReminderStrings(title: 'Reminder', body: 'Time to act');
  }

  Future<void> settle() => Future<void>.delayed(Duration.zero);

  test('submit returns validation failure when name is invalid', () async {
    final controller = buildController();

    controller.setName(' ');
    controller.setEmoji('💧');
    final result = await controller.submit(reminderStrings: reminderStrings());

    expect(result.status, HabitFormSaveStatus.validationFailed);
    verifyNever(() => habitsRepository.saveHabit(any()));
  });

  test('submit returns limit reached when at max habits', () async {
    when(() => habitsRepository.countHabits())
        .thenAnswer((_) async => HabitsRepository.maxHabitsPerDay);
    final controller = buildController();

    controller.setName('Drink water');
    controller.setEmoji('💧');
    final result = await controller.submit(reminderStrings: reminderStrings());

    expect(result.status, HabitFormSaveStatus.limitReached);
    verifyNever(() => habitsRepository.saveHabit(any()));
  });

  test('submit persists habit successfully', () async {
    final controller = buildController();

    controller.setName('Drink water');
    controller.setEmoji('💧');
    await controller.setReminderEnabled(true);
    controller.setReminderTime('09:00');

    final result = await controller.submit(reminderStrings: reminderStrings());

    expect(result.status, HabitFormSaveStatus.success);
    expect(result.isNew, isTrue);
    verify(() => habitsRepository.saveHabit(any())).called(1);
    verifyNever(() => notificationService.cancelHabitReminder(any()));
    verify(
      () => notificationService.scheduleHabitReminder(
        habitId: any(named: 'habitId'),
        title: any(named: 'title'),
        body: any(named: 'body'),
        days: any(named: 'days'),
        time: any(named: 'time'),
      ),
    ).called(1);
  });

  test('submit returns edit result when updating existing habit', () async {
    final habit = Habit(
      id: 'habit-1',
      name: 'Stretch',
      emoji: '🧘',
      color: 0xFF4F46E5,
      days: const [0, 2, 4],
      reminderId: 'reminder-1',
      reminderTime: '08:00',
      bestStreak: 0,
      currentStreak: 0,
    );
    when(() => habitsRepository.findById('habit-1'))
        .thenAnswer((_) async => habit);

    final controller = buildController(habitId: habit.id);
    await settle();

    controller.setName('Stretching');
    controller.setEmoji('🤸');
    controller.setReminderTime('07:00');
    final result = await controller.submit(reminderStrings: reminderStrings());

    expect(result.status, HabitFormSaveStatus.success);
    expect(result.isNew, isFalse);
    verify(() => notificationService.cancelHabitReminder(habit.reminderId))
        .called(1);
    verify(() => notificationService.scheduleHabitReminder(
          habitId: habit.reminderId,
          title: any(named: 'title'),
          body: any(named: 'body'),
          days: any(named: 'days'),
          time: any(named: 'time'),
        )).called(1);
  });

  test('deleteHabit cancels scheduled notifications', () async {
    final controller = buildController();

    when(() => habitsRepository.saveHabit(any())).thenAnswer((_) async {});

    controller.setName('Stretch');
    controller.setEmoji('🧘');
    controller.setDays(const [0, 2, 4]);
    final result = await controller.submit(reminderStrings: reminderStrings());

    expect(result.status, HabitFormSaveStatus.success);

    when(() => habitsRepository.deleteHabit(any())).thenAnswer((_) async {});
    final deleteResult = await controller.deleteHabit();

    expect(deleteResult.status, HabitFormDeleteStatus.deleted);
    verify(() => notificationService.cancelHabitReminder(result.habit!.reminderId))
        .called(1);
  });

  test('hasChanges flag resets after successful save', () async {
    final controller = buildController();

    controller.setName('Drink water');
    controller.setEmoji('💧');
    final firstState = readState();
    expect(firstState.hasChanges, isTrue);

    await controller.submit(reminderStrings: reminderStrings());
    final afterSave = readState();
    expect(afterSave.hasChanges, isFalse);
  });
}

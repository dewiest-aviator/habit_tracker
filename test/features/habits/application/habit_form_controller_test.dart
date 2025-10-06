import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:habit_tracker/features/habits/application/habit_form_controller.dart';
import 'package:habit_tracker/features/habits/application/habit_form_state.dart';
import 'package:habit_tracker/features/habits/data/repositories/habit_entries_repository.dart';
import 'package:habit_tracker/features/habits/data/repositories/habits_repository.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit.dart';
import 'package:habit_tracker/core/services/notification_service.dart';

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
  late _MockHabitsRepository habitsRepository;
  late _MockHabitEntriesRepository habitEntriesRepository;
  late _MockNotificationService notificationService;
  const analytics = _StubAnalytics();

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
    when(
      () => notificationService.cancelHabitReminder(any()),
    ).thenAnswer((_) async {});
    when(
      () => notificationService.scheduleHabitReminder(
        habitId: any(named: 'habitId'),
        title: any(named: 'title'),
        body: any(named: 'body'),
        days: any(named: 'days'),
        time: any(named: 'time'),
      ),
    ).thenAnswer((_) async {});
    when(
      () => notificationService.requestPermission(),
    ).thenAnswer((_) async => true);
    when(
      () => habitEntriesRepository.deleteEntriesForHabit(any()),
    ).thenAnswer((_) async {});
  });

  HabitFormController buildController({String? habitId}) {
    return HabitFormController(
      habitsRepository: habitsRepository,
      habitEntriesRepository: habitEntriesRepository,
      notificationService: notificationService,
      analytics: analytics,
      habitId: habitId,
    );
  }

  HabitReminderStrings reminderStrings() {
    return const HabitReminderStrings(title: 'Reminder', body: 'Time to act');
  }

  test('submit returns validation failure when name is invalid', () async {
    final controller = buildController();

    controller.setName(' ');
    controller.setEmoji('💧');
    final result = await controller.submit(reminderStrings: reminderStrings());

    expect(result.status, HabitFormSaveStatus.validationFailed);
    verifyNever(() => habitsRepository.saveHabit(any()));
  });

  test('submit returns limit reached when at max habits', () async {
    when(
      () => habitsRepository.countHabits(),
    ).thenAnswer((_) async => HabitsRepository.maxHabitsPerDay);
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

    final controller = buildController(habitId: 'habit-1');
    await Future<void>.delayed(Duration.zero);

    controller.setName('Evening stretch');
    final result = await controller.submit(reminderStrings: reminderStrings());

    expect(result.status, HabitFormSaveStatus.success);
    expect(result.isNew, isFalse);
  });

  test('submit cancels and reschedules reminders when editing reminder days',
      () async {
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

    final controller = buildController(habitId: 'habit-1');
    await Future<void>.delayed(Duration.zero);

    controller.setDays(const [0, 1]);
    final result = await controller.submit(reminderStrings: reminderStrings());

    expect(result.status, HabitFormSaveStatus.success);
    final results = verifyInOrder([
      () => notificationService.cancelHabitReminder('reminder-1'),
      () => notificationService.scheduleHabitReminder(
            habitId: 'reminder-1',
            title: any(named: 'title'),
            body: any(named: 'body'),
            days: captureAny(named: 'days'),
            time: captureAny(named: 'time'),
          ),
    ]);
    final captured = results.last.captured;
    expect(captured[0] as List<int>, equals(const [0, 1]));
    expect(captured[1] as String, equals('08:00'));
  });

  test('submit leaves existing reminders untouched when settings are unchanged',
      () async {
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

    final controller = buildController(habitId: 'habit-1');
    await Future<void>.delayed(Duration.zero);

    controller.setName('Morning stretch');
    final result = await controller.submit(reminderStrings: reminderStrings());

    expect(result.status, HabitFormSaveStatus.success);
    verifyNever(() => notificationService.cancelHabitReminder(any()));
    verifyNever(
      () => notificationService.scheduleHabitReminder(
        habitId: any(named: 'habitId'),
        title: any(named: 'title'),
        body: any(named: 'body'),
        days: any(named: 'days'),
        time: any(named: 'time'),
      ),
    );
  });

  test('deleteHabit removes persisted habit', () async {
    final habit = Habit(
      id: 'habit-1',
      name: 'Stretch',
      emoji: '🧘',
      color: 0xFF4F46E5,
      days: const [0, 1, 2, 3, 4, 5, 6],
      reminderId: 'habit-1',
      reminderTime: '',
      bestStreak: 0,
      currentStreak: 0,
    );
    when(
      () => habitsRepository.findById('habit-1'),
    ).thenAnswer((_) async => habit);
    when(
      () => habitsRepository.deleteHabit('habit-1'),
    ).thenAnswer((_) async {});

    final controller = buildController(habitId: 'habit-1');
    await Future<void>.delayed(Duration.zero);

    final result = await controller.deleteHabit();

    expect(result.status, HabitFormDeleteStatus.deleted);
    verify(() => habitsRepository.deleteHabit('habit-1')).called(1);
    verify(
      () => habitEntriesRepository.deleteEntriesForHabit('habit-1'),
    ).called(1);
    verify(() => notificationService.cancelHabitReminder('habit-1')).called(1);
  });
}

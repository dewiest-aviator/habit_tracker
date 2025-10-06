import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:habit_tracker/features/habits/application/habit_form_controller.dart';
import 'package:habit_tracker/features/habits/application/habit_form_state.dart';
import 'package:habit_tracker/features/habits/data/repositories/habit_entries_repository.dart';
import 'package:habit_tracker/features/habits/data/repositories/habits_repository.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit.dart';
import 'package:habit_tracker/features/habits/presentation/screens/habit_form_screen.dart';
import 'package:habit_tracker/l10n/app_localizations.dart';
import 'package:habit_tracker/core/services/notification_service.dart';

class _MockHabitsRepository extends Mock implements HabitsRepository {}

class _MockHabitEntriesRepository extends Mock
    implements HabitEntriesRepository {}

class _MockNotificationService extends Mock implements NotificationService {}

class _StubHabitFormAnalytics extends HabitFormAnalytics {
  const _StubHabitFormAnalytics();

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
  setUpAll(() {
    registerFallbackValue(HabitFormState.initial());
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

  group('HabitFormScreen', () {
    testWidgets('renders default create form', (tester) async {
      final habitsRepository = _MockHabitsRepository();
      when(() => habitsRepository.countHabits()).thenAnswer((_) async => 0);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            habitsRepositoryProvider.overrideWithValue(habitsRepository),
            habitEntriesRepositoryProvider.overrideWithValue(
              _MockHabitEntriesRepository(),
            ),
            notificationServiceProvider.overrideWithValue(
              _MockNotificationService(),
            ),
            habitFormAnalyticsProvider.overrideWithValue(
              const _StubHabitFormAnalytics(),
            ),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const HabitFormScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Create habit'), findsOneWidget);
      expect(find.text('Emoji'), findsOneWidget);
      expect(find.text('Habit name'), findsOneWidget);
      expect(find.text('Days of the week'), findsOneWidget);
      expect(find.text('Create habit'), findsOneWidget);
    });

    testWidgets('prefills data when editing a habit', (tester) async {
      final habitsRepository = _MockHabitsRepository();
      final habit = Habit(
        id: 'habit-1',
        name: 'Drink water',
        emoji: '💧',
        color: 0xFF4F46E5,
        days: const [0, 1, 2],
        reminderId: 'habit-1',
        reminderTime: '',
        bestStreak: 0,
        currentStreak: 0,
      );
      when(
        () => habitsRepository.findById('habit-1'),
      ).thenAnswer((_) async => habit);
      when(() => habitsRepository.countHabits()).thenAnswer((_) async => 1);
      when(() => habitsRepository.saveHabit(any())).thenAnswer((_) async {});

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            habitsRepositoryProvider.overrideWithValue(habitsRepository),
            habitEntriesRepositoryProvider.overrideWithValue(
              _MockHabitEntriesRepository(),
            ),
            notificationServiceProvider.overrideWithValue(
              _MockNotificationService(),
            ),
            habitFormAnalyticsProvider.overrideWithValue(
              const _StubHabitFormAnalytics(),
            ),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const HabitFormScreen(habitId: 'habit-1'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Edit habit'), findsOneWidget);
      expect(find.text('Drink water'), findsOneWidget);
      expect(find.byIcon(Icons.delete_outline), findsOneWidget);
    });

    testWidgets('shows reminder time when habit has reminder', (tester) async {
      final habitsRepository = _MockHabitsRepository();
      final habit = Habit(
        id: 'habit-2',
        name: 'Stretch',
        emoji: '🧘',
        color: 0xFF4F46E5,
        days: const [0, 1, 2, 3, 4, 5, 6],
        reminderId: 'habit-2',
        reminderTime: '09:30',
        bestStreak: 0,
        currentStreak: 0,
      );
      when(
        () => habitsRepository.findById('habit-2'),
      ).thenAnswer((_) async => habit);
      when(() => habitsRepository.countHabits()).thenAnswer((_) async => 1);
      when(() => habitsRepository.saveHabit(any())).thenAnswer((_) async {});

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            habitsRepositoryProvider.overrideWithValue(habitsRepository),
            habitEntriesRepositoryProvider.overrideWithValue(
              _MockHabitEntriesRepository(),
            ),
            notificationServiceProvider.overrideWithValue(
              _MockNotificationService(),
            ),
            habitFormAnalyticsProvider.overrideWithValue(
              const _StubHabitFormAnalytics(),
            ),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const HabitFormScreen(habitId: 'habit-2'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Reminder time'), findsOneWidget);
      expect(find.textContaining('9:30'), findsWidgets);
    });
  });
}

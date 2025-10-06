import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/core/router/app_router.dart';
import 'package:habit_tracker/core/services/analytics_service.dart';
import 'package:habit_tracker/core/telemetry/controllers/telemetry_controller.dart';
import 'package:habit_tracker/core/telemetry/providers/telemetry_provider.dart';
import 'package:habit_tracker/core/theme/app_theme.dart';
import 'package:habit_tracker/features/habits/data/repositories/habit_entries_repository.dart';
import 'package:habit_tracker/features/habits/data/repositories/habits_repository.dart';
import 'package:habit_tracker/features/habits/domain/domain.dart';
import 'package:habit_tracker/features/habits/domain/usecases/toggle_habit_completion.dart';
import 'package:habit_tracker/features/info/application/providers/app_info_provider.dart';
import 'package:habit_tracker/features/settings/application/controllers/notification_settings_controller.dart';
import 'package:habit_tracker/features/settings/application/controllers/theme_controller.dart';
import 'package:habit_tracker/features/settings/application/providers/notification_settings_provider.dart';
import 'package:habit_tracker/features/settings/application/providers/theme_provider.dart';
import 'package:habit_tracker/features/settings/application/controllers/language_controller.dart';
import 'package:habit_tracker/features/settings/application/providers/language_provider.dart';
import 'package:habit_tracker/l10n/app_localizations.dart';
import 'package:habit_tracker/l10n/app_localizations_en.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';

class _MockAnalytics extends Mock implements FirebaseAnalytics {}

class _MockCrashlytics extends Mock implements FirebaseCrashlytics {}

class _MockHabitsRepository extends Mock implements HabitsRepository {}

class _MockHabitEntriesRepository extends Mock
    implements HabitEntriesRepository {}

class _MockToggleHabitCompletion extends Mock
    implements ToggleHabitCompletion {}

void main() {
  late TelemetryController controller;
  late _MockAnalytics analytics;
  late _MockCrashlytics crashlytics;
  late ThemeController themeController;
  late NotificationSettingsController notificationController;
  late LanguageController languageController;
  late PackageInfo packageInfo;
  late _MockHabitsRepository habitsRepository;
  late _MockHabitEntriesRepository habitEntriesRepository;
  late _MockToggleHabitCompletion toggleHabitCompletion;
  late Habit sampleHabit;

  setUpAll(() {
    registerFallbackValue(DateTime(2024));
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'analytics_consent': true,
      'crash_consent': true,
      'notifications_enabled': true,
      'notifications_time': '08:00',
    });
    AnalyticsService.reset();

    analytics = _MockAnalytics();
    crashlytics = _MockCrashlytics();

    when(
      () => analytics.setAnalyticsCollectionEnabled(any()),
    ).thenAnswer((_) async {});
    when(() => analytics.logAppOpen()).thenAnswer((_) async {});
    when(
      () => analytics.logEvent(
        name: any(named: 'name'),
        parameters: any(named: 'parameters'),
      ),
    ).thenAnswer((_) async {});
    when(
      () => analytics.logScreenView(
        screenName: any(named: 'screenName'),
        screenClass: any(named: 'screenClass'),
      ),
    ).thenAnswer((_) async {});
    when(
      () => crashlytics.setCrashlyticsCollectionEnabled(any()),
    ).thenAnswer((_) async {});

    controller = TelemetryController(
      enableFirebase: true,
      analytics: analytics,
      crashlytics: crashlytics,
    );
    await controller.initialize();

    themeController = ThemeController();
    await themeController.load();

    notificationController = NotificationSettingsController();
    await notificationController.load();

    languageController = LanguageController();
    await languageController.load();

    packageInfo = PackageInfo(
      appName: 'Habit Tracker',
      packageName: 'com.example.habit',
      version: '1.2.3',
      buildNumber: '42',
      buildSignature: 'sig',
      installerStore: null,
    );

    habitsRepository = _MockHabitsRepository();
    habitEntriesRepository = _MockHabitEntriesRepository();
    toggleHabitCompletion = _MockToggleHabitCompletion();

    sampleHabit = Habit(
      id: 'habit-1',
      name: 'Hydrate',
      emoji: '💧',
      color: 0xFF42A5F5,
      days: List<int>.generate(7, (index) => index),
      reminderId: 'reminder-1',
      reminderTime: '08:00',
      bestStreak: 3,
      currentStreak: 1,
    );

    when(
      () => habitsRepository.getTodayHabits(any()),
    ).thenAnswer((_) async => [sampleHabit]);
    when(
      () => habitsRepository.watchTodayHabits(any()),
    ).thenAnswer((_) => Stream.value([sampleHabit]));
    when(
      () => habitEntriesRepository.fetchEntriesForDate(any()),
    ).thenAnswer((_) async => <HabitEntry>[]);
    when(
      () => habitEntriesRepository.watchEntriesForDate(any()),
    ).thenAnswer((_) => Stream.value(<HabitEntry>[]));
    when(
      () => toggleHabitCompletion.call(
        habitId: any(named: 'habitId'),
        date: any(named: 'date'),
      ),
    ).thenAnswer((invocation) async {
      final date = invocation.namedArguments[#date] as DateTime;
      return ToggleHabitResult(
        habit: sampleHabit,
        entry: HabitEntry(habitId: sampleHabit.id, date: date, done: true),
      );
    });
  });

  testWidgets('navigates from Home to Settings', (WidgetTester tester) async {
    final router = createAppRouter(
      observers: [
        if (controller.analyticsObserver != null) controller.analyticsObserver!,
      ],
    );
    final l10n = AppLocalizationsEn();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          telemetryControllerProvider.overrideWith((ref) => controller),
          themeControllerProvider.overrideWith((ref) => themeController),
          languageControllerProvider.overrideWith((ref) => languageController),
          notificationSettingsProvider.overrideWith(
            (ref) => notificationController,
          ),
          appInfoProvider.overrideWith((ref) async => packageInfo),
          habitsRepositoryProvider.overrideWithValue(habitsRepository),
          habitEntriesRepositoryProvider.overrideWithValue(
            habitEntriesRepository,
          ),
          toggleHabitCompletionProvider.overrideWithValue(
            toggleHabitCompletion,
          ),
        ],
        child: MaterialApp.router(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text(l10n.homeTodayTitle), findsOneWidget);

    final settingsNav = find.descendant(
      of: find.byType(NavigationBar),
      matching: find.text(l10n.navSettingsLabel),
    );
    expect(settingsNav, findsOneWidget);
    await tester.tap(settingsNav);
    await tester.pumpAndSettle();

    final settingsTitleFinder = find.descendant(
      of: find.byType(AppBar),
      matching: find.text(l10n.settingsTitle),
    );
    expect(settingsTitleFinder, findsOneWidget);

    final homeNav = find.descendant(
      of: find.byType(NavigationBar),
      matching: find.text(l10n.navHomeLabel),
    );
    await tester.tap(homeNav);
    await tester.pumpAndSettle();

    final fab = find.byType(FloatingActionButton);
    expect(fab, findsOneWidget);
    await tester.tap(fab);
    await tester.pumpAndSettle();

    expect(find.byTooltip('Back'), findsOneWidget);

    router.pop();
    await tester.pumpAndSettle();
    expect(find.text(l10n.homeTodayTitle), findsOneWidget);
  });

  testWidgets('shows not found page for unknown routes', (
    WidgetTester tester,
  ) async {
    final router = createAppRouter(
      observers: [
        if (controller.analyticsObserver != null) controller.analyticsObserver!,
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          telemetryControllerProvider.overrideWith((ref) => controller),
          themeControllerProvider.overrideWith((ref) => themeController),
          languageControllerProvider.overrideWith((ref) => languageController),
          appInfoProvider.overrideWith((ref) async => packageInfo),
          habitsRepositoryProvider.overrideWithValue(habitsRepository),
          habitEntriesRepositoryProvider.overrideWithValue(
            habitEntriesRepository,
          ),
          toggleHabitCompletionProvider.overrideWithValue(
            toggleHabitCompletion,
          ),
        ],
        child: MaterialApp.router(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );

    router.go('/missing');
    await tester.pumpAndSettle();

    expect(find.text('Not found'), findsOneWidget);
  });
}

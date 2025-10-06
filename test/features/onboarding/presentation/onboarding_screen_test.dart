import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:habit_tracker/features/habits/data/repositories/habits_repository.dart';
import 'package:habit_tracker/features/habits/domain/entities/habit.dart';
import 'package:habit_tracker/features/onboarding/application/onboarding_controller.dart';
import 'package:habit_tracker/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:habit_tracker/features/settings/application/controllers/notification_settings_controller.dart';
import 'package:habit_tracker/features/settings/application/providers/notification_settings_provider.dart';
import 'package:habit_tracker/l10n/app_localizations.dart';
import 'package:habit_tracker/l10n/app_localizations_en.dart';
import 'package:habit_tracker/core/services/notification_service.dart';
import 'package:habit_tracker/core/telemetry/controllers/telemetry_controller.dart';
import 'package:habit_tracker/core/telemetry/providers/telemetry_provider.dart';

class _MockHabitsRepository extends Mock implements HabitsRepository {}

class _MockNotificationService extends Mock implements NotificationService {}

class _TestNotificationSettingsController
    extends NotificationSettingsController {
  _TestNotificationSettingsController({required SharedPreferences prefs})
    : super(preferences: prefs);
  int setEnabledCallCount = 0;
  bool? lastEnabledValue;

  @override
  Future<void> setEnabled(bool value) {
    setEnabledCallCount += 1;
    lastEnabledValue = value;
    return super.setEnabled(value);
  }
}

Future<void> _pumpOnboarding(
  WidgetTester tester, {
  required GoRouter router,
  required HabitsRepository habitsRepository,
  required NotificationService notificationService,
  required NotificationSettingsController notificationSettings,
  required TelemetryController telemetryController,
  required SharedPreferences prefs,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        habitsRepositoryProvider.overrideWithValue(habitsRepository),
        notificationServiceProvider.overrideWithValue(notificationService),
        notificationSettingsProvider.overrideWith((ref) {
          return notificationSettings;
        }),
        telemetryControllerProvider.overrideWith((ref) => telemetryController),
        onboardingControllerProvider.overrideWith((ref) {
          final controller = OnboardingController(
            habitsRepository: habitsRepository,
            notificationService: notificationService,
            notificationSettings: notificationSettings,
            telemetryController: telemetryController,
            preferences: prefs,
          );
          return controller;
        }),
      ],
      child: MaterialApp.router(
        routerConfig: router,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _MockHabitsRepository habitsRepository;
  late _MockNotificationService notificationService;
  late _TestNotificationSettingsController notificationSettings;
  late TelemetryController telemetryController;
  late SharedPreferences prefs;
  final l10n = AppLocalizationsEn();

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
    notificationSettings = _TestNotificationSettingsController(prefs: prefs);
    telemetryController = TelemetryController(enableFirebase: false);
    await telemetryController.initialize();
    addTearDown(telemetryController.dispose);

    when(() => habitsRepository.saveHabit(any())).thenAnswer((_) async {});
  });

  testWidgets('completes onboarding when notifications are granted', (
    tester,
  ) async {
    final permissionCompleter = Completer<bool>();
    when(
      () => notificationService.requestPermission(),
    ).thenAnswer((_) => permissionCompleter.future);

    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          name: 'onboarding',
          builder: (context, state) => const OnboardingScreen(),
        ),
        GoRoute(
          path: '/home',
          name: 'home',
          builder: (context, state) =>
              const Scaffold(body: Center(child: Text('Home Screen'))),
        ),
      ],
    );
    addTearDown(router.dispose);

    await _pumpOnboarding(
      tester,
      router: router,
      habitsRepository: habitsRepository,
      notificationService: notificationService,
      notificationSettings: notificationSettings,
      telemetryController: telemetryController,
      prefs: prefs,
    );

    expect(find.text(l10n.onboardingTagline), findsOneWidget);

    await tester.tap(find.text(l10n.onboardingGetStarted));
    await tester.pumpAndSettle();

    expect(find.text(l10n.onboardingHabitsTitle), findsOneWidget);

    await tester.tap(find.text(l10n.onboardingHabitMeditate));
    await tester.tap(find.text(l10n.onboardingHabitWalk));
    await tester.pump();

    final continueFinder = find.widgetWithText(
      ElevatedButton,
      l10n.onboardingContinue,
    );
    expect(tester.widget<ElevatedButton>(continueFinder).onPressed, isNotNull);

    await tester.tap(continueFinder);
    await tester.pumpAndSettle();

    expect(find.text(l10n.onboardingNotificationsTitle), findsOneWidget);

    final enableFinder = find.widgetWithText(
      ElevatedButton,
      l10n.onboardingEnableReminders,
    );
    await tester.tap(enableFinder);
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    permissionCompleter.complete(true);
    await tester.pumpAndSettle();

    expect(find.text(l10n.onboardingNotificationsGranted), findsOneWidget);

    final finishFinder = find.widgetWithText(
      ElevatedButton,
      l10n.onboardingFinishCta,
    );
    await tester.ensureVisible(finishFinder);
    await tester.tap(finishFinder);
    await tester.pumpAndSettle();

    expect(find.text('Home Screen'), findsOneWidget);
    expect(prefs.getBool(OnboardingController.hasOnboardedKey), isTrue);
    expect(notificationSettings.lastEnabledValue, isTrue);
    expect(telemetryController.isAnalyticsEnabled, isTrue);
    expect(telemetryController.isCrashEnabled, isTrue);
    verify(() => notificationService.requestPermission()).called(1);
    verify(() => habitsRepository.saveHabit(any())).called(2);
  });

  testWidgets('later button declines reminders without requesting permission', (
    tester,
  ) async {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          name: 'onboarding',
          builder: (context, state) => const OnboardingScreen(),
        ),
        GoRoute(
          path: '/home',
          name: 'home',
          builder: (context, state) =>
              const Scaffold(body: Center(child: Text('Home Screen'))),
        ),
      ],
    );
    addTearDown(router.dispose);

    await _pumpOnboarding(
      tester,
      router: router,
      habitsRepository: habitsRepository,
      notificationService: notificationService,
      notificationSettings: notificationSettings,
      telemetryController: telemetryController,
      prefs: prefs,
    );

    await tester.tap(find.text(l10n.onboardingGetStarted));
    await tester.pumpAndSettle();

    await tester.tap(find.text(l10n.onboardingHabitMeditate));
    await tester.pump();

    final continueFinder = find.widgetWithText(
      ElevatedButton,
      l10n.onboardingContinue,
    );
    await tester.tap(continueFinder);
    await tester.pumpAndSettle();

    final laterFinder = find.widgetWithText(
      TextButton,
      l10n.onboardingMaybeLater,
    );
    await tester.tap(laterFinder);
    await tester.pumpAndSettle();

    expect(find.text(l10n.onboardingNotificationsDenied), findsOneWidget);
    expect(find.text(l10n.settingsAnalyticsToggle), findsOneWidget);
    expect(find.text(l10n.settingsCrashToggle), findsOneWidget);

    final finishFinder = find.widgetWithText(
      ElevatedButton,
      l10n.onboardingFinishCta,
    );
    expect(tester.widget<ElevatedButton>(finishFinder).onPressed, isNotNull);
    await tester.ensureVisible(finishFinder);

    await tester.tap(finishFinder);
    await tester.pumpAndSettle();

    expect(find.text('Home Screen'), findsOneWidget);
    expect(notificationSettings.lastEnabledValue, isFalse);
    expect(telemetryController.isAnalyticsEnabled, isTrue);
    expect(telemetryController.isCrashEnabled, isTrue);
    verifyNever(() => notificationService.requestPermission());
    verify(() => habitsRepository.saveHabit(any())).called(1);
  });

  testWidgets('skip completes onboarding immediately', (tester) async {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          name: 'onboarding',
          builder: (context, state) => const OnboardingScreen(),
        ),
        GoRoute(
          path: '/home',
          name: 'home',
          builder: (context, state) =>
              const Scaffold(body: Center(child: Text('Home Screen'))),
        ),
      ],
    );
    addTearDown(router.dispose);

    await _pumpOnboarding(
      tester,
      router: router,
      habitsRepository: habitsRepository,
      notificationService: notificationService,
      notificationSettings: notificationSettings,
      telemetryController: telemetryController,
      prefs: prefs,
    );

    await tester.tap(find.text(l10n.onboardingSkip));
    await tester.pumpAndSettle();

    expect(find.text('Home Screen'), findsOneWidget);
    expect(notificationSettings.setEnabledCallCount, 1);
    expect(notificationSettings.lastEnabledValue, isFalse);
    expect(telemetryController.isAnalyticsEnabled, isTrue);
    expect(telemetryController.isCrashEnabled, isTrue);
    expect(prefs.getBool(OnboardingController.hasOnboardedKey), isTrue);
  });
}

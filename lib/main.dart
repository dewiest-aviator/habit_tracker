import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:habit_tracker/core/config/env/selector.dart' as env_selector;
import 'core/config/app_config.dart';
import 'core/router/app_router.dart';
import 'core/telemetry/controllers/telemetry_controller.dart';
import 'core/telemetry/providers/telemetry_provider.dart';
import 'core/database/habit_database.dart';
import 'core/services/notification_service.dart';
import 'features/onboarding/application/onboarding_controller.dart';
import 'features/settings/application/providers/theme_provider.dart';
import 'features/settings/application/providers/language_provider.dart';
import 'features/settings/application/providers/notification_settings_provider.dart';
import 'features/settings/application/providers/time_preferences_provider.dart';
import 'features/settings/application/controllers/time_preferences_controller.dart';
import 'core/theme/app_theme.dart';
import 'core/services/analytics_service.dart';
import 'l10n/app_localizations.dart';

// Gate Firebase/Crashlytics behind a compile-time flag.
// Locally (default) this is false. In CI PR builds, pass:
//   --dart-define=FIREBASE_ENABLED=true
// In **release** builds, Firebase is always enabled regardless of the flag.
const bool kFirebaseEnabled = bool.fromEnvironment(
  'FIREBASE_ENABLED',
  defaultValue: false,
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final enableFirebase = kFirebaseEnabled || kReleaseMode;
  final rootNavigatorKey = GlobalKey<NavigatorState>();
  final database = HabitDatabase();
  await database.initialize();
  if (enableFirebase) {
    try {
      await Firebase.initializeApp(options: env_selector.firebaseOptionsFor());
    } catch (e, st) {
      debugPrint('Firebase init skipped/failed: $e');
      debugPrintStack(stackTrace: st);
    }
  }

  final prefs = await SharedPreferences.getInstance();
  final hasOnboarded =
      prefs.getBool(OnboardingController.hasOnboardedKey) ?? false;
  final notificationService = NotificationService();
  final container = ProviderContainer(
    overrides: [
      telemetryConfigProvider.overrideWithValue(
        TelemetryConfig(enableFirebase: enableFirebase),
      ),
      habitDatabaseProvider.overrideWithValue(database),
      notificationServiceProvider.overrideWithValue(notificationService),
    ],
  );

  await container.read(telemetryControllerProvider.notifier).initialize();
  await container.read(themeControllerProvider.notifier).load();
  await container.read(languageControllerProvider.notifier).load();
  await container.read(notificationSettingsProvider.notifier).load();
  await container.read(timePreferencesProvider.notifier).load();

  if (enableFirebase) {
    // Forward Flutter framework errors
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      FirebaseCrashlytics.instance.recordFlutterFatalError(details);
    };

    // Uncaught errors from the engine / platform
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };

    // Uncaught async errors
    Isolate.current.addErrorListener(
      RawReceivePort((pair) async {
        final List<dynamic> errorAndStacktrace = pair;
        await FirebaseCrashlytics.instance.recordError(
          errorAndStacktrace.first,
          errorAndStacktrace.last as StackTrace,
          fatal: true,
        );
      }).sendPort,
    );
  } else {
    FlutterError.onError = FlutterError.presentError;
  }

  final observers = <NavigatorObserver>[];
  final observer = AnalyticsService.observer;
  if (observer != null) {
    observers.add(observer);
  }

  final router = createAppRouter(
    observers: observers,
    navigatorKey: rootNavigatorKey,
    hasCompletedOnboarding: hasOnboarded,
  );

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: HabitTrackerApp(
        router: router,
        rootNavigatorKey: rootNavigatorKey,
      ),
    ),
  );
}

class HabitTrackerApp extends ConsumerWidget {
  const HabitTrackerApp({
    super.key,
    required this.router,
    required this.rootNavigatorKey,
  });

  final GoRouter router;
  final GlobalKey<NavigatorState> rootNavigatorKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeControllerProvider).themeMode;
    final locale = ref.watch(languageControllerProvider).locale;
    final timePreferences = ref.watch(timePreferencesProvider);

    final baseTitle =
        Localizations.of<AppLocalizations>(
          context,
          AppLocalizations,
        )?.appTitle ??
        'Habit Tracker';
    final effectiveTitle = '$baseTitle${AppConfig.nameSuffix}';

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: effectiveTitle,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
      builder: (context, child) {
        final body = child ?? const SizedBox.shrink();
        final existing = MediaQuery.maybeOf(context);
        final mediaQuery = existing ?? MediaQueryData.fromView(
          WidgetsBinding.instance.platformDispatcher.views.first,
        );
        final use24HourFormat = _resolveUse24HourFormat(
          mediaQuery,
          timePreferences,
        );
        return MediaQuery(
          data: mediaQuery.copyWith(alwaysUse24HourFormat: use24HourFormat),
          child: body,
        );
      },
    );
  }

  bool _resolveUse24HourFormat(
    MediaQueryData mediaQuery,
    TimePreferencesState state,
  ) {
    switch (state.preference) {
      case TimeFormatPreference.system:
        return mediaQuery.alwaysUse24HourFormat;
      case TimeFormatPreference.h12:
        return false;
      case TimeFormatPreference.h24:
        return true;
    }
  }
}

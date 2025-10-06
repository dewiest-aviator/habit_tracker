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
import 'core/localization/l10n_extensions.dart';
import 'core/router/app_router.dart';
import 'core/telemetry/controllers/telemetry_controller.dart';
import 'core/telemetry/providers/telemetry_provider.dart';
import 'core/database/habit_database.dart';
import 'core/services/notification_service.dart';
import 'features/onboarding/application/onboarding_controller.dart';
import 'features/settings/application/controllers/theme_controller.dart';
import 'features/settings/application/controllers/language_controller.dart';
import 'features/settings/application/providers/theme_provider.dart';
import 'features/settings/application/controllers/notification_settings_controller.dart';
import 'features/settings/application/providers/language_provider.dart';
import 'features/settings/application/providers/notification_settings_provider.dart';
import 'core/theme/app_theme.dart';
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

  final telemetryController = TelemetryController(
    enableFirebase: enableFirebase,
  );
  await telemetryController.initialize();

  final themeController = ThemeController();
  await themeController.load();

  final languageController = LanguageController();
  await languageController.load();

  final notificationSettingsController = NotificationSettingsController();
  await notificationSettingsController.load();

  final prefs = await SharedPreferences.getInstance();
  final hasOnboarded =
      prefs.getBool(OnboardingController.hasOnboardedKey) ?? false;
  final notificationService = NotificationService();

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
  final observer = telemetryController.analyticsObserver;
  if (observer != null) {
    observers.add(observer);
  }

  final router = createAppRouter(
    observers: observers,
    navigatorKey: rootNavigatorKey,
    hasCompletedOnboarding: hasOnboarded,
  );

  runApp(
    ProviderScope(
      overrides: [
        telemetryControllerProvider.overrideWith((ref) => telemetryController),
        themeControllerProvider.overrideWith((ref) => themeController),
        languageControllerProvider.overrideWith((ref) => languageController),
        notificationSettingsProvider.overrideWith(
          (ref) => notificationSettingsController,
        ),
        habitDatabaseProvider.overrideWithValue(database),
        notificationServiceProvider.overrideWithValue(notificationService),
      ],
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

    final baseTitle =
        Localizations.of<AppLocalizations>(context, AppLocalizations)
                ?.appTitle ??
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
      builder: (context, child) =>
          _ConsentPromptOverlay(navigatorKey: rootNavigatorKey, child: child),
    );
  }
}

class _ConsentPromptOverlay extends ConsumerStatefulWidget {
  const _ConsentPromptOverlay({
    required this.child,
    required this.navigatorKey,
  });

  final Widget? child;
  final GlobalKey<NavigatorState> navigatorKey;

  @override
  ConsumerState<_ConsentPromptOverlay> createState() =>
      _ConsentPromptOverlayState();
}

class _ConsentPromptOverlayState extends ConsumerState<_ConsentPromptOverlay> {
  TelemetryController? _controller;
  bool _dialogShown = false;
  ProviderSubscription<TelemetryController>? _subscription;

  @override
  void initState() {
    super.initState();
    _attachController(ref.read(telemetryControllerProvider));
    _maybeShowDialog();

    _subscription = ref.listenManual<TelemetryController>(
      telemetryControllerProvider,
      (previous, controller) {
        _attachController(controller);
        _maybeShowDialog();
      },
    );
  }

  @override
  void dispose() {
    _controller?.removeListener(_handleControllerChanged);
    _subscription?.close();
    super.dispose();
  }

  void _attachController(TelemetryController controller) {
    if (!identical(controller, _controller)) {
      _controller?.removeListener(_handleControllerChanged);
      _controller = controller..addListener(_handleControllerChanged);
    }
  }

  void _handleControllerChanged() {
    _maybeShowDialog();
  }

  void _maybeShowDialog() {
    final controller = _controller;
    if (controller == null) return;
    if (_dialogShown) return;
    if (!controller.isLoaded) return;
    if (controller.hasRecordedDecision) return;

    final navigatorContext = widget.navigatorKey.currentContext;
    if (navigatorContext == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _maybeShowDialog();
        }
      });
      return;
    }

    _dialogShown = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      showDialog<void>(
        context: navigatorContext,
        barrierDismissible: false,
        builder: (dialogContext) {
          final l10n = dialogContext.l10n;

          return AlertDialog(
            title: Text(l10n.consentDialogTitle),
            content: Text(l10n.consentDialogBody),
            actions: [
              TextButton(
                onPressed: () async {
                  await ref
                      .read(telemetryControllerProvider)
                      .updateConsent(false);
                  if (navigatorContext.mounted) {
                    Navigator.of(navigatorContext).pop();
                  }
                },
                child: Text(l10n.consentNotNow),
              ),
              FilledButton(
                onPressed: () async {
                  await ref
                      .read(telemetryControllerProvider)
                      .updateConsent(true);
                  if (navigatorContext.mounted) {
                    Navigator.of(navigatorContext).pop();
                  }
                },
                child: Text(l10n.consentShare),
              ),
            ],
          );
        },
      ).whenComplete(() {
        if (!mounted) return;
        // If the user dismissed via system back, keep showing next frame.
        final controller = _controller;
        if (controller != null && !controller.hasRecordedDecision) {
          _dialogShown = false;
          _maybeShowDialog();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child ?? const SizedBox.shrink();
  }
}

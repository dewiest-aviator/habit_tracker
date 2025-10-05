import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:go_router/go_router.dart';

import 'firebase_options_dev.dart' as dev;
import 'firebase_options_staging.dart' as stg;
import 'firebase_options_prod.dart' as prod;
import 'app_config.dart';
import 'app_router.dart';
import 'state/telemetry_controller.dart';
import 'state/telemetry_provider.dart';
import 'state/theme_controller.dart';
import 'state/theme_provider.dart';
import 'state/notification_settings_controller.dart';
import 'state/notification_settings_provider.dart';
import 'theme/app_theme.dart';

FirebaseOptions get firebaseOptions {
  if (AppConfig.isProd) return prod.DefaultFirebaseOptions.currentPlatform;
  if (AppConfig.isStaging) return stg.DefaultFirebaseOptions.currentPlatform;
  return dev.DefaultFirebaseOptions.currentPlatform;
}

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
  if (enableFirebase) {
    try {
      await Firebase.initializeApp(options: firebaseOptions);
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

  final notificationSettingsController = NotificationSettingsController();
  await notificationSettingsController.load();

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
  );

  runApp(
    ProviderScope(
      overrides: [
        telemetryControllerProvider.overrideWith((ref) => telemetryController),
        themeControllerProvider.overrideWith((ref) => themeController),
        notificationSettingsProvider.overrideWith(
          (ref) => notificationSettingsController,
        ),
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

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Habit Tracker${AppConfig.nameSuffix}',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
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
        builder: (context) {
          return AlertDialog(
            title: const Text('Share Anonymous Usage Data?'),
            content: const Text(
              'Help us improve Habit Tracker by sharing anonymized usage metrics '
              'and crash reports. You can change this later in Settings.',
            ),
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
                child: const Text('Not now'),
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
                child: const Text('Share'),
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

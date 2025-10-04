import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

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

  final router = createAppRouter(observers: observers);

  runApp(
    HabitTrackerApp(router: router, telemetryController: telemetryController),
  );
}

class HabitTrackerApp extends StatelessWidget {
  const HabitTrackerApp({
    super.key,
    required this.router,
    required this.telemetryController,
  });

  final GoRouter router;
  final TelemetryController telemetryController;

  @override
  Widget build(BuildContext context) {
    return TelemetryProvider(
      controller: telemetryController,
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'Habit Tracker${AppConfig.nameSuffix}',
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        routerConfig: router,
        builder: (context, child) => _ConsentPromptOverlay(child: child),
      ),
    );
  }
}

class _ConsentPromptOverlay extends StatefulWidget {
  const _ConsentPromptOverlay({required this.child});

  final Widget? child;

  @override
  State<_ConsentPromptOverlay> createState() => _ConsentPromptOverlayState();
}

class _ConsentPromptOverlayState extends State<_ConsentPromptOverlay> {
  TelemetryController? _controller;
  bool _dialogShown = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final controller = TelemetryProvider.of(context);
    if (!identical(controller, _controller)) {
      _controller?.removeListener(_handleControllerChanged);
      _controller = controller..addListener(_handleControllerChanged);
      _maybeShowDialog();
    }
  }

  @override
  void dispose() {
    _controller?.removeListener(_handleControllerChanged);
    super.dispose();
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

    _dialogShown = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      showDialog<void>(
        context: context,
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
                  await TelemetryProvider.of(context).updateConsent(false);
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                },
                child: const Text('Not now'),
              ),
              FilledButton(
                onPressed: () async {
                  await TelemetryProvider.of(context).updateConsent(true);
                  if (context.mounted) {
                    Navigator.of(context).pop();
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
        if (!_controller!.hasRecordedDecision) {
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

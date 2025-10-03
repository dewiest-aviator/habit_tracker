import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'app_config.dart';
import 'app_router.dart';
import 'theme/app_theme.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import 'firebase_options_dev.dart' as dev;
import 'firebase_options_staging.dart' as stg;
import 'firebase_options_prod.dart' as prod;

FirebaseOptions get firebaseOptions {
  if (AppConfig.isProd) return prod.DefaultFirebaseOptions.currentPlatform;
  if (AppConfig.isStaging) return stg.DefaultFirebaseOptions.currentPlatform;
  return dev.DefaultFirebaseOptions.currentPlatform;
}

// Gate Firebase/Crashlytics behind a compile-time flag.
// Locally (default) this is false. In CI PR builds, pass:
//   --dart-define=FIREBASE_ENABLED=true
// In **release** builds, Firebase is always enabled regardless of the flag.
const bool kFirebaseEnabled =
    bool.fromEnvironment('FIREBASE_ENABLED', defaultValue: false);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kFirebaseEnabled || kReleaseMode) {
    try {
      await Firebase.initializeApp(
        options: firebaseOptions,
      );

      // Enable Crashlytics collection for CI/test builds
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);

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
    } catch (e, st) {
      // If configs are missing (e.g., local dev), fail gracefully
      debugPrint('Firebase init skipped/failed: $e');
      debugPrintStack(stackTrace: st);
      FlutterError.onError = FlutterError.presentError;
    }
  } else {
    // Local dev: no Firebase/Crashlytics
    FlutterError.onError = FlutterError.presentError;
  }

  runApp(const HabitTrackerApp());
}

class HabitTrackerApp extends StatelessWidget {
  const HabitTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Habit Tracker${AppConfig.nameSuffix}',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      routerConfig: appRouter,
    );
  }
}
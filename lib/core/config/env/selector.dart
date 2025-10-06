import 'package:firebase_core/firebase_core.dart';
import 'package:habit_tracker/core/config/app_config.dart';
import 'dev/env.dart' as dev;
import 'staging/env.dart' as stg;
import 'prod/env.dart' as prod;

/// Returns the correct [FirebaseOptions] for the given flavor.
FirebaseOptions firebaseOptionsFor([AppEnv? env]) {
  final targetEnv = env ?? AppConfig.environment;
  switch (targetEnv) {
    case AppEnv.dev:
      return dev.DefaultFirebaseOptions.currentPlatform;
    case AppEnv.staging:
      return stg.DefaultFirebaseOptions.currentPlatform;
    case AppEnv.prod:
      return prod.DefaultFirebaseOptions.currentPlatform;
  }
}

import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/core/config/app_config.dart';
import 'package:habit_tracker/core/config/env/selector.dart' as selector;
import 'package:habit_tracker/core/config/env/dev/firebase_options.dart' as dev;
import 'package:habit_tracker/core/config/env/staging/firebase_options.dart' as stg;
import 'package:habit_tracker/core/config/env/prod/firebase_options.dart' as prod;

void main() {
  group('firebaseOptionsFor', () {
    test('returns dev options for AppEnv.dev', () {
      final opts = selector.firebaseOptionsFor(AppEnv.dev);
      expect(opts.appId, dev.DefaultFirebaseOptions.currentPlatform.appId);
    });

    test('returns staging options for AppEnv.staging', () {
      final opts = selector.firebaseOptionsFor(AppEnv.staging);
      expect(opts.appId, stg.DefaultFirebaseOptions.currentPlatform.appId);
    });

    test('returns prod options for AppEnv.prod', () {
      final opts = selector.firebaseOptionsFor(AppEnv.prod);
      expect(opts.appId, prod.DefaultFirebaseOptions.currentPlatform.appId);
    });

    test('defaults to AppConfig.environment when null', () {
      final opts = selector.firebaseOptionsFor();
      expect(
        [
          dev.DefaultFirebaseOptions.currentPlatform.appId,
          stg.DefaultFirebaseOptions.currentPlatform.appId,
          prod.DefaultFirebaseOptions.currentPlatform.appId,
        ],
        contains(opts.appId),
      );
    });
  });
}
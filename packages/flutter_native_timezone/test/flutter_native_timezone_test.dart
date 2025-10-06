import 'package:flutter/services.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:flutter_native_timezone/flutter_native_timezone_web.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel channel = MethodChannel('flutter_native_timezone');
  final TestDefaultBinaryMessenger messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  tearDown(() {
    messenger.setMockMethodCallHandler(channel, null);
  });

  group('FlutterNativeTimezone', () {
    setUp(() {
      messenger.setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        switch (methodCall.method) {
          case 'getLocalTimezone':
            return 'America/New_York';
          case 'getAvailableTimezones':
            return <String>['America/New_York', 'Europe/London'];
        }
        return null;
      });
    });

    test('getLocalTimezone returns native value', () async {
      expect(await FlutterNativeTimezone.getLocalTimezone(), 'America/New_York');
    });

    test('getAvailableTimezones returns native list', () async {
      expect(
        await FlutterNativeTimezone.getAvailableTimezones(),
        <String>['America/New_York', 'Europe/London'],
      );
    });
  });

  test('getLocalTimezone throws when platform returns null', () async {
    messenger.setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      return null;
    });

    expect(
      FlutterNativeTimezone.getLocalTimezone(),
      throwsArgumentError,
    );
  });

  test('getAvailableTimezones throws when platform returns null', () async {
    messenger.setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      return null;
    });

    expect(
      FlutterNativeTimezone.getAvailableTimezones(),
      throwsArgumentError,
    );
  });

  group('FlutterNativeTimezonePlugin', () {
    late FlutterNativeTimezonePlugin plugin;

    setUp(() {
      plugin = FlutterNativeTimezonePlugin();
    });

    test('handleMethodCall returns UTC when Intl is unavailable', () async {
      final dynamic timezone = await plugin.handleMethodCall(
        const MethodCall('getLocalTimezone'),
      );

      expect(timezone, 'UTC');
    });

    test('handleMethodCall returns list of timezones', () async {
      final dynamic timezones = await plugin.handleMethodCall(
        const MethodCall('getAvailableTimezones'),
      );

      expect(timezones, <String>['UTC']);
    });

    test('handleMethodCall throws for unknown methods', () {
      expect(
        plugin.handleMethodCall(const MethodCall('unknown')),
        throwsA(isA<PlatformException>()),
      );
    });
  });
}

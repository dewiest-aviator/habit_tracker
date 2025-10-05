import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:habit_tracker/core/services/notification_service.dart';

class _MockFlutterLocalNotificationsPlugin extends Mock
    implements FlutterLocalNotificationsPlugin {}

class _MockAndroidFlutterLocalNotificationsPlugin extends Mock
    implements AndroidFlutterLocalNotificationsPlugin {}

class _MockIOSFlutterLocalNotificationsPlugin extends Mock
    implements IOSFlutterLocalNotificationsPlugin {}

class _MockMacFlutterLocalNotificationsPlugin extends Mock
    implements MacOSFlutterLocalNotificationsPlugin {}

void main() {
  late _MockFlutterLocalNotificationsPlugin plugin;
  late NotificationService service;

  setUpAll(() {
    registerFallbackValue<bool>(false);
  });

  setUp(() {
    plugin = _MockFlutterLocalNotificationsPlugin();
    service = NotificationService(plugin: plugin);
  });

  test('treats null Android permission result as granted', () async {
    final androidPlugin = _MockAndroidFlutterLocalNotificationsPlugin();
    when(() => plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>())
        .thenReturn(androidPlugin);
    when(() => androidPlugin.requestNotificationsPermission())
        .thenAnswer((_) async => null);

    final granted = await service.requestPermission();

    expect(granted, isTrue);
  });

  test('returns false when every platform denies notifications', () async {
    final androidPlugin = _MockAndroidFlutterLocalNotificationsPlugin();
    final iosPlugin = _MockIOSFlutterLocalNotificationsPlugin();
    final macPlugin = _MockMacFlutterLocalNotificationsPlugin();

    when(() => plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>())
        .thenReturn(androidPlugin);
    when(() => plugin.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>())
        .thenReturn(iosPlugin);
    when(() => plugin.resolvePlatformSpecificImplementation<
            MacOSFlutterLocalNotificationsPlugin>())
        .thenReturn(macPlugin);

    when(() => androidPlugin.requestNotificationsPermission())
        .thenAnswer((_) async => false);
    when(() => iosPlugin.requestPermissions(
          alert: any(named: 'alert'),
          badge: any(named: 'badge'),
          sound: any(named: 'sound'),
        )).thenAnswer((_) async => false);
    when(() => macPlugin.requestPermissions(
          alert: any(named: 'alert'),
          badge: any(named: 'badge'),
          sound: any(named: 'sound'),
        )).thenAnswer((_) async => false);

    final granted = await service.requestPermission();

    expect(granted, isFalse);
  });
}

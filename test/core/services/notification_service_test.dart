import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

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

  setUp(() {
    plugin = _MockFlutterLocalNotificationsPlugin();
    service = NotificationService(plugin: plugin);
  });

  setUpAll(() {
    tzdata.initializeTimeZones();
    registerFallbackValue(
      tz.TZDateTime(tz.UTC, 2024, 1, 1),
    );
    registerFallbackValue(const NotificationDetails());
  });

  tearDown(() {
    NotificationService.resetInitialization();
    tz.setLocalLocation(tz.getLocation('UTC'));
  });

  test('treats null Android permission result as granted', () async {
    final androidPlugin = _MockAndroidFlutterLocalNotificationsPlugin();
    when(
      () => plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >(),
    ).thenReturn(androidPlugin);
    when(
      () => androidPlugin.requestNotificationsPermission(),
    ).thenAnswer((_) async => null);

    final granted = await service.requestPermission();

    expect(granted, isTrue);
  });

  test('returns false when every platform denies notifications', () async {
    final androidPlugin = _MockAndroidFlutterLocalNotificationsPlugin();
    final iosPlugin = _MockIOSFlutterLocalNotificationsPlugin();
    final macPlugin = _MockMacFlutterLocalNotificationsPlugin();

    when(
      () => plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >(),
    ).thenReturn(androidPlugin);
    when(
      () => plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >(),
    ).thenReturn(iosPlugin);
    when(
      () => plugin
          .resolvePlatformSpecificImplementation<
            MacOSFlutterLocalNotificationsPlugin
          >(),
    ).thenReturn(macPlugin);

    when(
      () => androidPlugin.requestNotificationsPermission(),
    ).thenAnswer((_) async => false);
    when(
      () => iosPlugin.requestPermissions(
        alert: any(named: 'alert'),
        badge: any(named: 'badge'),
        sound: any(named: 'sound'),
      ),
    ).thenAnswer((_) async => false);
    when(
      () => macPlugin.requestPermissions(
        alert: any(named: 'alert'),
        badge: any(named: 'badge'),
        sound: any(named: 'sound'),
      ),
    ).thenAnswer((_) async => false);

    final granted = await service.requestPermission();

    expect(granted, isFalse);
  });

  group('scheduleHabitReminder', () {
    setUp(() {
      when(
        () => plugin.zonedSchedule(
          any(),
          any(),
          any(),
          any(),
          any(),
          androidScheduleMode: any(named: 'androidScheduleMode'),
          uiLocalNotificationDateInterpretation:
              any(named: 'uiLocalNotificationDateInterpretation'),
          matchDateTimeComponents: any(named: 'matchDateTimeComponents'),
        ),
      ).thenAnswer((_) async {});
    });

    test('initializes timezone using provided name', () async {
      final tzService = NotificationService(
        plugin: plugin,
        timeZoneNameProvider: () async => 'America/New_York',
      );

      await tzService.scheduleHabitReminder(
        habitId: 'habit',
        title: 'title',
        body: 'body',
        days: const [0],
        time: '09:00',
      );

      expect(tz.local.name, 'America/New_York');
    });

    test('falls back to UTC when timezone lookup fails', () async {
      final tzService = NotificationService(
        plugin: plugin,
        timeZoneNameProvider: () async => 'Invalid/Zone',
      );

      tz.setLocalLocation(tz.getLocation('America/Los_Angeles'));

      await tzService.scheduleHabitReminder(
        habitId: 'habit',
        title: 'title',
        body: 'body',
        days: const [0],
        time: '09:00',
      );

      expect(tz.local.name, 'UTC');
    });
  });
}

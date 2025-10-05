import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationService {
  NotificationService({FlutterLocalNotificationsPlugin? plugin})
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;

  FlutterLocalNotificationsPlugin get plugin => _plugin;

  Future<bool> requestPermission() async {
    var granted = false;

    final androidImpl = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    final iosImpl = _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
    final macImpl = _plugin
        .resolvePlatformSpecificImplementation<
            MacOSFlutterLocalNotificationsPlugin>();

    final androidResult = await androidImpl?.requestNotificationsPermission();
    if (androidImpl != null) {
      if (androidResult == null || androidResult == true) {
        granted = true;
      }
    }

    final iosResult = await iosImpl?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
    if (iosResult == true) {
      granted = true;
    }

    final macResult = await macImpl?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
    if (macResult == true) {
      granted = true;
    }

    return granted;
  }
}

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

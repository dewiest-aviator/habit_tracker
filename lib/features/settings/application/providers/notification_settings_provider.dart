import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/notification_settings_controller.dart';

final notificationSettingsProvider =
    ChangeNotifierProvider<NotificationSettingsController>((ref) {
      throw UnimplementedError(
        'Override notificationSettingsProvider before reading it.',
      );
    });

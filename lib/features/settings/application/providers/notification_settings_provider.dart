import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/notification_settings_controller.dart';

final notificationSettingsProvider =
    NotifierProvider<NotificationSettingsController, NotificationSettingsState>(
      NotificationSettingsController.new,
    );

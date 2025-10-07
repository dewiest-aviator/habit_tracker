import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/time_preferences_controller.dart';

final timePreferencesProvider =
    NotifierProvider<TimePreferencesController, TimePreferencesState>(
      TimePreferencesController.new,
    );

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/theme_controller.dart';

final themeControllerProvider =
    NotifierProvider<ThemeController, ThemeState>(ThemeController.new);

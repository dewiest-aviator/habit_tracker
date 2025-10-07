import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/language_controller.dart';

final languageControllerProvider =
    NotifierProvider<LanguageController, LanguageState>(LanguageController.new);

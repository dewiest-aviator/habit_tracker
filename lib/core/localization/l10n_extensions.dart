import 'package:flutter/widgets.dart';
import 'package:habit_tracker/l10n/app_localizations.dart';

extension LocalizationContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

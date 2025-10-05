import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

enum HtmlThemePreference { system, light, dark }

ColorScheme htmlColorSchemeForPreference(
  BuildContext context,
  HtmlThemePreference preference,
) {
  switch (preference) {
    case HtmlThemePreference.system:
      return Theme.of(context).colorScheme;
    case HtmlThemePreference.light:
      return ThemeData.light().colorScheme;
    case HtmlThemePreference.dark:
      return ThemeData.dark().colorScheme;
  }
}

Map<String, Style> htmlStylesForColorScheme(ColorScheme scheme) {
  return {
    'body': Style(
      backgroundColor: scheme.surface,
      color: scheme.onSurface,
      margin: Margins.zero,
      padding: HtmlPaddings.zero,
    ),
    'a': Style(color: scheme.primary),
  };
}

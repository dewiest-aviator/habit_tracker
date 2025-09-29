import 'package:flutter/material.dart';

@immutable
class AppBrandColors extends ThemeExtension<AppBrandColors> {
  const AppBrandColors({
    required this.brand,
    required this.success,
    required this.warning,
    required this.danger,
  });

  final Color brand;
  final Color success;
  final Color warning;
  final Color danger;

  @override
  AppBrandColors copyWith({
    Color? brand,
    Color? success,
    Color? warning,
    Color? danger,
  }) => AppBrandColors(
        brand: brand ?? this.brand,
        success: success ?? this.success,
        warning: warning ?? this.warning,
        danger: danger ?? this.danger,
      );

  @override
  AppBrandColors lerp(ThemeExtension<AppBrandColors>? other, double t) {
    if (other is! AppBrandColors) return this;
    return AppBrandColors(
      brand: Color.lerp(brand, other.brand, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
    );
  }

  static const light = AppBrandColors(
    brand: Color(0xFF4F46E5),
    success: Color(0xFF16A34A),
    warning: Color(0xFFF59E0B),
    danger: Color(0xFFDC2626),
  );

  static const dark = AppBrandColors(
    brand: Color(0xFF8B87F8),
    success: Color(0xFF22C55E),
    warning: Color(0xFFFBBF24),
    danger: Color(0xFFEF4444),
  );
}

class AppTheme {
  static ThemeData light = ThemeData(
    brightness: Brightness.light,
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4F46E5)),
    textTheme: _textTheme,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    extensions: const <ThemeExtension<dynamic>>[
      AppBrandColors.light,
    ],
  );

  static ThemeData dark = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF4F46E5),
      brightness: Brightness.dark,
    ),
    textTheme: _textTheme,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    extensions: const <ThemeExtension<dynamic>>[
      AppBrandColors.dark,
    ],
  );
}

final TextTheme _textTheme = const TextTheme(
  headlineLarge: TextStyle(fontWeight: FontWeight.w700),
  titleLarge: TextStyle(fontWeight: FontWeight.w600),
  bodyLarge: TextStyle(fontSize: 16),
  bodyMedium: TextStyle(fontSize: 14),
);
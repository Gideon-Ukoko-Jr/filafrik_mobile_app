import 'package:flutter/material.dart';

import 'app_color_scheme.dart';

class AppTheme {
  static ThemeData dark() {
    final colors = AppColorScheme.dark();
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: colors.background,
      fontFamily: 'DM Sans',
      colorScheme: ColorScheme(
        brightness: Brightness.dark,
        primary: colors.gold,
        onPrimary: colors.background,
        secondary: colors.green,
        onSecondary: colors.text,
        error: colors.red,
        onError: colors.text,
        surface: colors.surface,
        onSurface: colors.text,
      ),
      extensions: [colors],
    );
  }

  static ThemeData light() {
    final colors = AppColorScheme.light();
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: colors.background,
      fontFamily: 'DM Sans',
      colorScheme: ColorScheme(
        brightness: Brightness.light,
        primary: colors.gold,
        onPrimary: colors.background,
        secondary: colors.green,
        onSecondary: colors.text,
        error: colors.red,
        onError: colors.text,
        surface: colors.surface,
        onSurface: colors.text,
      ),
      extensions: [colors],
    );
  }
}

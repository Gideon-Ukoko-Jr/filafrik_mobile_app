import 'package:flutter/material.dart';

class AppColorScheme extends ThemeExtension<AppColorScheme> {
  const AppColorScheme({
    required this.background,
    required this.surface,
    required this.navBar,
    required this.text,
    required this.muted,
    required this.dim,
    required this.gold,
    required this.lightGold,
    required this.forest,
    required this.green,
    required this.red,
  });

  final Color background;
  final Color surface;
  final Color navBar;
  final Color text;
  final Color muted;
  final Color dim;
  final Color gold;
  final Color lightGold;
  final Color forest;
  final Color green;
  final Color red;

  static AppColorScheme dark() => const AppColorScheme(
    background: Color(0xFF060A07),
    surface: Color(0xFF0D150F),
    navBar: Color(0xFF0A0805),
    text: Color(0xFFF2E8D0),
    muted: Color(0xFF8A7A62),
    dim: Color(0xFF4A3E2E),
    gold: Color(0xFFC8993A),
    lightGold: Color(0xFFF5E0B0),
    forest: Color(0xFF1D3A25),
    green: Color(0xFF3A7A4A),
    red: Color(0xFFCC2200),
  );

  static AppColorScheme light() => const AppColorScheme(
    background: Color(0xFFFAF7F2),
    surface: Color(0xFFFFFFFF),
    navBar: Color(0xFFFFFFFF),
    text: Color(0xFF1A1208),
    muted: Color(0xFF5A4A30),
    dim: Color(0xFF9A8A70),
    gold: Color(0xFFB8820A),
    lightGold: Color(0xFFF5E0B0),
    forest: Color(0xFF1D3A25),
    green: Color(0xFF3A7A4A),
    red: Color(0xFFCC2200),
  );

  static AppColorScheme of(BuildContext context) =>
      Theme.of(context).extension<AppColorScheme>()!;

  @override
  AppColorScheme copyWith({
    Color? background,
    Color? surface,
    Color? navBar,
    Color? text,
    Color? muted,
    Color? dim,
    Color? gold,
    Color? lightGold,
    Color? forest,
    Color? green,
    Color? red,
  }) {
    return AppColorScheme(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      navBar: navBar ?? this.navBar,
      text: text ?? this.text,
      muted: muted ?? this.muted,
      dim: dim ?? this.dim,
      gold: gold ?? this.gold,
      lightGold: lightGold ?? this.lightGold,
      forest: forest ?? this.forest,
      green: green ?? this.green,
      red: red ?? this.red,
    );
  }

  @override
  AppColorScheme lerp(AppColorScheme? other, double t) {
    if (other is! AppColorScheme) return this;
    return AppColorScheme(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      navBar: Color.lerp(navBar, other.navBar, t)!,
      text: Color.lerp(text, other.text, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      dim: Color.lerp(dim, other.dim, t)!,
      gold: Color.lerp(gold, other.gold, t)!,
      lightGold: Color.lerp(lightGold, other.lightGold, t)!,
      forest: Color.lerp(forest, other.forest, t)!,
      green: Color.lerp(green, other.green, t)!,
      red: Color.lerp(red, other.red, t)!,
    );
  }
}

extension AppColorsExt on BuildContext {
  AppColorScheme get colors => AppColorScheme.of(this);
}

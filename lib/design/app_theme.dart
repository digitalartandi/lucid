import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'lucid_tokens.dart';

class AppTheme {
  static ThemeData dark() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: Lc.bg,
      colorScheme: const ColorScheme.dark(
        surface: Lc.bg,
        surfaceContainer: Lc.blackish,
        primary: Lc.violetA,     // Violett
        secondary: Lc.pinkA,     // Pink
        tertiary: Lc.cyan,       // Cyan
        outline: Lc.glassStroke,
        onSurface: Lc.textHi,    // überall Weiß
        onPrimary: Lc.textHi,
        onSecondary: Lc.textHi,
        onTertiary: Lc.textHi,
      ),
      dividerColor: Lc.glassStroke,
      visualDensity: VisualDensity.comfortable,
    );

    final dm = GoogleFonts.dmSansTextTheme().apply(
      bodyColor: Lc.textHi,
      displayColor: Lc.textHi,
    );

    return base.copyWith(
      textTheme: dm,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        foregroundColor: Lc.textHi,
      ),
      cardTheme: const CardThemeData( // deine Flutter-Version erwartet CardThemeData
        color: Lc.blackish,
        margin: EdgeInsets.zero,
      ),
      navigationBarTheme: NavigationBarThemeData(
        indicatorColor: Colors.white.withOpacity(.10),
        backgroundColor: Colors.transparent,
      ),
      splashFactory: InkSparkle.splashFactory,
    );
  }
}

// lib/ui/tokens.dart
//
// Zentrale Design-Tokens. Jede neue Oberfläche bezieht Farben, Abstände,
// Radien und Schrift ausschließlich von hier.
import 'package:flutter/cupertino.dart';

/// Farben. Leitidee: Nacht als Grundton, Iris für alles Bedienbare,
/// Mondlicht (Bernstein) ausschließlich für "klar/luzid".
class LC {
  LC._();

  // Flächen
  static const Color night = Color(0xFF0B0D1F);
  static const Color surface = Color(0xFF14172E);
  static const Color surfaceHi = Color(0xFF1D2142);
  static const Color line = Color(0xFF2B3058);

  // Text
  static const Color text = Color(0xFFEEF0FF);
  static const Color muted = Color(0xFFA4A9CF);
  static const Color faint = Color(0xFF6F7499);

  // Bedienung
  static const Color iris = Color(0xFF8B8CFF);
  static const Color irisDeep = Color(0xFF5456D6);
  static const Color irisSoft = Color(0x268B8CFF);

  // Bedeutung
  static const Color moon = Color(0xFFF2C879); // Klartraum, Klarheit
  static const Color moonSoft = Color(0x26F2C879);
  static const Color mint = Color(0xFF6FD6B0); // erledigt, gut belegt
  static const Color mintSoft = Color(0x266FD6B0);
  static const Color rose = Color(0xFFF08BA0); // Vorsicht
  static const Color roseSoft = Color(0x26F08BA0);

  // Nachtmodus: tiefrot, damit die Dunkeladaption erhalten bleibt.
  static const Color redBg = Color(0xFF080203);
  static const Color redText = Color(0xFFB5403A);
  static const Color redDim = Color(0xFF5C1F1C);
  static const Color redLine = Color(0xFF2A0E0D);

  // Glasflächen über dem Sternenhintergrund
  static const Color glass = Color(0xB8171B38);
  static const Color glassHi = Color(0xCC20254C);
  static const Color glassLine = Color(0x24C9CCFF);
  static const Color bar = Color(0xD90B0D1F);

  // Himmel: Grundverlauf und Lichtschleier
  static const Color skyTop = Color(0xFF070816);
  static const Color skyMid = Color(0xFF0E1030);
  static const Color skyLow = Color(0xFF1A1440);
  static const Color veilViolet = Color(0xFF7B5CFF);
  static const Color veilTeal = Color(0xFF3FD0C9);
  static const Color veilRose = Color(0xFFE77BD0);

  static const Color black = Color(0xFF000000);
  static const Color transparent = Color(0x00000000);
}

/// Abstände im 4er-Raster.
class LS {
  LS._();
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;

  /// Seitenrand der Inhalte.
  static const double page = 20;

  /// Maximale Inhaltsbreite (Web/Tablet).
  static const double maxWidth = 640;
}

class LRad {
  LRad._();
  static const BorderRadius sm = BorderRadius.all(Radius.circular(10));
  static const BorderRadius md = BorderRadius.all(Radius.circular(16));
  static const BorderRadius lg = BorderRadius.all(Radius.circular(24));
  static const BorderRadius pill = BorderRadius.all(Radius.circular(999));
}

/// Bilder für Bühnenflächen. Alle aus assets/slider/.
class LImg {
  LImg._();
  static const String splash = 'assets/slider/violetter-sonnenuntergang-ruhiger-see.webp';
  static const String morning = 'assets/slider/sternhimmel-ueber-einsamen-berg-rosa-horizont.webp';
  static const String day = 'assets/slider/polarleuchten-ueber-bergkamm-pastell.webp';
  static const String evening = 'assets/slider/sternennacht-silhouette-gebirgskette.webp';
  static const String night = 'assets/slider/mondsichel-ueber-bergkette-blaue-stunde.webp';
  static const String door = 'assets/slider/lichttor-in-wolken-goldene-stunde.webp';
  static const String wordmark = 'assets/logo/logo-text.svg';
  static const String signet = 'assets/logo/logo-signet.svg';
}

/// Schrift: Cormorant Garamond für große Überschriften (passt zur Wortmarke),
/// DM Sans für alles, was gelesen und bedient wird.
class LT {
  LT._();
  static const String family = 'DM Sans';
  static const String displayFamily = 'Cormorant Garamond';
  static const List<String> fallback = <String>['SF Pro Text', 'Roboto', 'Arial'];

  static const TextStyle _base = TextStyle(
    inherit: false,
    fontFamily: family,
    fontFamilyFallback: fallback,
    color: LC.text,
    decoration: TextDecoration.none,
  );

  static final TextStyle display = _base.copyWith(
    fontFamily: displayFamily,
    fontFamilyFallback: const <String>['Georgia', 'Times New Roman', 'serif'],
    fontSize: 40,
    height: 1.05,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
  );
  static final TextStyle title = _base.copyWith(
    fontFamily: displayFamily,
    fontFamilyFallback: const <String>['Georgia', 'Times New Roman', 'serif'],
    fontSize: 27,
    height: 1.15,
    fontWeight: FontWeight.w600,
  );
  static final TextStyle heading = _base.copyWith(
    fontSize: 17,
    height: 1.3,
    fontWeight: FontWeight.w600,
  );
  static final TextStyle body = _base.copyWith(
    fontSize: 16,
    height: 1.5,
    fontWeight: FontWeight.w400,
  );
  static final TextStyle bodyMuted = body.copyWith(color: LC.muted);
  static final TextStyle label = _base.copyWith(
    fontSize: 14,
    height: 1.35,
    fontWeight: FontWeight.w500,
  );
  static final TextStyle labelMuted = label.copyWith(color: LC.muted);
  static final TextStyle caption = _base.copyWith(
    fontSize: 12.5,
    height: 1.35,
    fontWeight: FontWeight.w500,
    color: LC.muted,
  );
  static final TextStyle number = _base.copyWith(
    fontSize: 28,
    height: 1.0,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
  );
}

/// Theme für die CupertinoApp.
CupertinoThemeData lucidTheme() {
  return CupertinoThemeData(
    brightness: Brightness.dark,
    primaryColor: LC.iris,
    scaffoldBackgroundColor: LC.night,
    barBackgroundColor: LC.bar,
    textTheme: CupertinoTextThemeData(
      primaryColor: LC.iris,
      textStyle: LT.body,
      actionTextStyle: LT.body.copyWith(color: LC.iris, fontWeight: FontWeight.w600),
      navTitleTextStyle: LT.heading,
      navLargeTitleTextStyle: LT.display.copyWith(fontSize: 34),
      navActionTextStyle: LT.body.copyWith(color: LC.iris),
      tabLabelTextStyle: LT.caption.copyWith(fontSize: 11, color: LC.faint),
      pickerTextStyle: LT.body.copyWith(fontSize: 21),
      dateTimePickerTextStyle: LT.body.copyWith(fontSize: 21),
    ),
  );
}

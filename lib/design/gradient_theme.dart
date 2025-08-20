// lib/design/gradient_theme.dart
import 'package:flutter/cupertino.dart';
import '../services/app_prefs.dart';

/// Deutlich unterscheidbare, dunkle Verlaufs-Themes.
/// Alle Farben sind so gewählt, dass Weiß (E9EAFF/FFFFFF) gut lesbar bleibt.
enum GradientStyle {
  aurora,   // Violett + Cyan (Standard)
  ocean,    // Blau + Türkis
  sunset,   // Warm, Abendrot
  forest,   // Waldgrün
  mono,     // dezent einfarbig
  midnight, // Nachtblau
  magma,    // Dunkelrot / Lava
  glacier,  // Tiefblau / Kalt
  berry,    // Beeren-Töne
  cyber,    // Deep Teal / Neon-Anmutung
}

class Gradients {
  final GradientStyle style;
  const Gradients(this.style);

  // Primäre App-Highlights (Hero, große CTAs)
  List<Color> get primary => switch (style) {
        GradientStyle.aurora  => const [Color(0xFF7C83FF), Color(0xFF52CAEB)],
        GradientStyle.ocean   => const [Color(0xFF3F7DFF), Color(0xFF2ED1B8)],
        GradientStyle.sunset  => const [Color(0xFFCC4F69), Color(0xFFFF8A3C)],
        GradientStyle.forest  => const [Color(0xFF2E8C6A), Color(0xFF167052)],
        GradientStyle.mono    => const [Color(0xFF5F6FFF), Color(0xFF5F6FFF)],

        // neue Sets – dunkel, hohe Weiß-Kontraste
        GradientStyle.midnight => const [Color(0xFF1B1F4E), Color(0xFF0B0E2E)],
        GradientStyle.magma    => const [Color(0xFF6A1B1B), Color(0xFFB33A2E)],
        GradientStyle.glacier  => const [Color(0xFF0C3B66), Color(0xFF0D6B8A)],
        GradientStyle.berry    => const [Color(0xFF3B0F3F), Color(0xFF8E1C62)],
        GradientStyle.cyber    => const [Color(0xFF0B2A3B), Color(0xFF0E6C6C)],
      };

  // Sekundäre Karten (z. B. Night Lite)
  List<Color> get secondary => switch (style) {
        GradientStyle.aurora  => const [Color(0xFF926AB7), Color(0xFF7149CD)],
        GradientStyle.ocean   => const [Color(0xFF2F62C7), Color(0xFF2997D1)],
        GradientStyle.sunset  => const [Color(0xFFB74386), Color(0xFF933269)],
        GradientStyle.forest  => const [Color(0xFF3FA178), Color(0xFF2B7A5B)],
        GradientStyle.mono    => const [Color(0xFF6B7BFF), Color(0xFF6B7BFF)],

        GradientStyle.midnight => const [Color(0xFF28337A), Color(0xFF1B1F4E)],
        GradientStyle.magma    => const [Color(0xFF7A1B1B), Color(0xFF9A2D24)],
        GradientStyle.glacier  => const [Color(0xFF0A2E52), Color(0xFF0C3B66)],
        GradientStyle.berry    => const [Color(0xFF4E1655), Color(0xFF7A1E78)],
        GradientStyle.cyber    => const [Color(0xFF162C44), Color(0xFF159A9A)],
      };

  // Tertiäre Karten (z. B. Journal)
  List<Color> get tertiary => switch (style) {
        GradientStyle.aurora  => const [Color(0xFFED68BE), Color(0xFFEE2B71)],
        GradientStyle.ocean   => const [Color(0xFF0F6C9A), Color(0xFF12A8BF)],
        GradientStyle.sunset  => const [Color(0xFFB23B7A), Color(0xFFDA5858)],
        GradientStyle.forest  => const [Color(0xFF49B27F), Color(0xFF2E8C6A)],
        GradientStyle.mono    => const [Color(0xFF7A88FF), Color(0xFF7A88FF)],

        GradientStyle.midnight => const [Color(0xFF3B4B9E), Color(0xFF28337A)],
        GradientStyle.magma    => const [Color(0xFF8A1038), Color(0xFFB33939)],
        GradientStyle.glacier  => const [Color(0xFF0F5C7E), Color(0xFF1593A6)],
        GradientStyle.berry    => const [Color(0xFF5C1E6B), Color(0xFFD04A8F)],
        GradientStyle.cyber    => const [Color(0xFF1E3A5F), Color(0xFF22B3B3)],
      };

  // Banner/Accent
  List<Color> get accent => switch (style) {
        GradientStyle.aurora  => const [Color(0xFF7C83FF), Color(0xFFED68BE)],
        GradientStyle.ocean   => const [Color(0xFF2997D1), Color(0xFF2DE2A7)],
        GradientStyle.sunset  => const [Color(0xFFFF7E6B), Color(0xFFED68BE)],
        GradientStyle.forest  => const [Color(0xFF57C38F), Color(0xFF2F8F6E)],
        GradientStyle.mono    => const [Color(0xFF8793FF), Color(0xFF8793FF)],

        GradientStyle.midnight => const [Color(0xFF2B2E7F), Color(0xFF5A1E8A)],
        GradientStyle.magma    => const [Color(0xFFB33939), Color(0xFFCC4B2E)],
        GradientStyle.glacier  => const [Color(0xFF0C5A8A), Color(0xFF1AADC9)],
        GradientStyle.berry    => const [Color(0xFF7A1E78), Color(0xFFE16AB1)],
        GradientStyle.cyber    => const [Color(0xFF1F2A68), Color(0xFF22B3B3)],
      };
}

/// Zentrale Steuerung + Persistenz.
/// Verwende: GradientTheme.style (ValueNotifier), GradientTheme.of(style).
class GradientTheme {
  static final ValueNotifier<GradientStyle> style = ValueNotifier(GradientStyle.aurora);

  static Gradients of(GradientStyle s) => Gradients(s);

  static Future<void> load() async {
    final p = await AppPrefs.instance();
    style.value = p.readGradientStyle();
  }

  static Future<void> set(GradientStyle s) async {
    final p = await AppPrefs.instance();
    await p.saveGradientStyle(s);
    style.value = s;
  }

  static Future<void> reset() async {
    final p = await AppPrefs.instance();
    await p.reset();
    style.value = GradientStyle.aurora;
  }
}

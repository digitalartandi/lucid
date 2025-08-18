import 'package:flutter/material.dart';

class Lc {
  // ── Hintergrund (extra dunkel)
  static const Color bg = Color(0xFF080B23);   // #080B23

  // ── Primärfarben (aus deinem Screenshot)
  static const Color violetA = Color(0xFF7C83FF); // #7C83FF
  static const Color violetB = Color(0xFFA179EF); // #A179EF

  static const Color violet2_0 = Color(0xFF080B23); // #080B23 (Start)
  static const Color violet2_1 = Color(0xFF926AB7); // #926AB7
  static const Color violet2_2 = Color(0xFF7149CD); // #7149CD

  static const Color pinkA = Color(0xFFED68BE);     // #ED68BE
  static const Color pinkB = Color(0xFFEE2B71);     // #EE2B71

  // weitere Akzente
  static const Color violetAlt = Color(0xFF935BEE); // #935BEE
  static const Color cyan      = Color(0xFF52CAEB); // #52CAEB
  static const Color deepViolet= Color(0xFF4E45D0); // #4E45D0
  static const Color blackish  = Color(0xFF0A0A23); // #0A0A23

  // Text
  static const Color textHi  = Color(0xFFFFFFFF);   // #fff
  static const Color textMed = Color(0xCCFFFFFF);   // 80 %
  static const Color textLo  = Color(0x99FFFFFF);   // 60 %

  // Hairline/Glass
  static const Color glassStroke = Color(0x33FFFFFF);

  // Hintergründe (ganz ruhig, sehr dunkel)
  static const List<Color> bgGradient = [
    bg, Color(0xFF0A0A23), Color(0xFF0B0F2D),
  ];

  // Karten-/CTA-Gradients (kräftig & modern)
  static const List<Color> gradViolet    = [violetA, violetB];
  static const List<Color> gradViolet2   = [violet2_0, violet2_1, violet2_2];
  static const List<Color> gradPink      = [pinkA, pinkB];
  static const List<Color> gradVioletCyan= [violetA, cyan];

  // (Legacy-Aliasse für ältere Stellen im Code – optional)
  static const List<Color> gradIrisBlue  = gradVioletCyan;
}

import 'package:flutter/material.dart';

class Lc {
  static const bg = Color(0xFF080B23);

  static const violetA = Color(0xFF7C83FF);
  static const violetB = Color(0xFFA179EF);

  static const violet2_0 = Color(0xFF080B23);
  static const violet2_1 = Color(0xFF926AB7);
  static const violet2_2 = Color(0xFF7149CD);

  static const pinkA = Color(0xFFED68BE);
  static const pinkB = Color(0xFFEE2B71);

  static const cyan   = Color(0xFF52CAEB);
  static const white  = Color(0xFFFFFFFF);

  static const glassStroke = Color(0x33FFFFFF);
  static const textHi  = white;
  static const textMed = Color(0xCCFFFFFF);
}

class BankTheme {
  static const bg     = Lc.bg;
  static const ink    = Lc.textHi;
  static const subInk = Lc.textMed;
  static const blue   = Lc.cyan;

  static const BorderRadius radiusXL = BorderRadius.all(Radius.circular(20));
  static const BorderRadius radiusL  = BorderRadius.all(Radius.circular(16));

  // neue kräftige Gradients unter den alten Keys
  static const List<Color> cardGradBlue   = [Lc.violetA, Lc.cyan];
  static const List<Color> cardGradViolet = [Lc.violet2_0, Lc.violet2_2];
  static const List<Color> cardGradPink   = [Lc.pinkA, Lc.pinkB];

  static Decoration glass([double opacity = .75]) {
    return BoxDecoration(
      borderRadius: const BorderRadius.all(Radius.circular(20)),
      border: const Border.fromBorderSide(BorderSide(color: Lc.glassStroke)),
      color: const Color(0xFFFFFFFF).withOpacity(0.16),
    );
  }

  static Decoration gradientCard(List<Color> colors) {
    // Nur noch als Fallback genutzt – Hauptfarbe kommt jetzt via GlassCard.tint
    return BoxDecoration(
      borderRadius: const BorderRadius.all(Radius.circular(20)),
      border: const Border.fromBorderSide(BorderSide(color: Lc.glassStroke)),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          colors.first.withOpacity(0.42),
          colors.last.withOpacity(0.34),
        ],
      ),
    );
  }
}

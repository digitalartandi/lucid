import 'package:flutter/cupertino.dart';

/// Sehr dunkler Hintergrund bleibt bestehen.
const kA11yBg = Color(0xFF080B23);

/// Panel/Section-Hintergründe – klar vom Bg abgesetzt.
const kA11yPanel   = Color(0xFF111631);  // Karten / Sections
const kA11yPanelHi = Color(0xFF171C3F);  // Hover/Thumb/ausgewähltes Tab

/// Textfarben mit hohem Kontrast.
const kA11yText      = Color(0xFFF5F7FF);  // Primär
const kA11yTextSub   = Color(0xFFCCD4FF);  // Sekundär
const kA11yTextMute  = Color(0xFF9FA9D6);  // Tertiär / Labels
const kA11yDivider   = Color(0x33FFFFFF);  // Hairline

/// Akzent (dein Violett) + inaktiv.
const kA11yAccent     = Color(0xFF7A6CFF);
const kA11yAccentSoft = Color(0x667A6CFF);

/// Empfohlene TextStyles (DM Sans).
const kTitle = TextStyle(
  color: kA11yText, fontWeight: FontWeight.w700, fontSize: 16, height: 1.2,
);
const kSub   = TextStyle(
  color: kA11yTextSub, fontWeight: FontWeight.w500, fontSize: 13, height: 1.25,
);
const kLabel = TextStyle(
  color: kA11yTextMute, fontWeight: FontWeight.w600, fontSize: 12, letterSpacing: .2,
);

/// Standard Panel-Deko für Karten/Listen.
BoxDecoration panelBox({BorderRadius radius = const BorderRadius.all(Radius.circular(16))}) {
  return BoxDecoration(
    color: kA11yPanel,
    borderRadius: radius,
    border: Border.all(color: kA11yDivider, width: .8),
    boxShadow: const [
      BoxShadow(color: Color(0x33000000), blurRadius: 16, offset: Offset(0, 8)),
    ],
  );
}

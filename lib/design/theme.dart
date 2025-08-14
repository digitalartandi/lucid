import 'package:flutter/cupertino.dart';

class Brand {
  static const Color primary = Color(0xFF6C7CFF);
  static const Color primaryDark = Color(0xFF4757E8);
  static const Color secondary = Color(0xFF42D6A4);
  static const Color accent = Color(0xFFFAC748);

  static const Color bg = Color(0xFFF6F7FB);
  static const Color card = Color(0xFFFFFFFF);
  static const Color cardTint = Color(0x66FFFFFF);

  static const Color text = Color(0xFF0F172A);
  static const Color textMuted = Color(0xFF6B7280);

  static const List<Color> heroGradient = [Color(0xFF8EA2FF), Color(0xFF6C7CFF), Color(0xFF42D6A4)];
  static const List<Color> chipGradient = [Color(0xFF6C7CFF), Color(0xFF42D6A4)];
}

class T {
  static const titleXL = TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: Brand.text);
  static const titleL = TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Brand.text);
  static const body = TextStyle(fontSize: 16, color: Brand.text);
  static const bodyMuted = TextStyle(fontSize: 14, color: Brand.textMuted);
  static const chip = TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF0F172A));
}







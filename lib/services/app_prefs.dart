// lib/services/app_prefs.dart
import 'package:shared_preferences/shared_preferences.dart';
import '../design/gradient_theme.dart';

class AppPrefs {
  static const _kGradientStyle = 'gradient_style_v1';

  AppPrefs._(this._sp);
  final SharedPreferences _sp;

  static SharedPreferences? _cached;
  static Future<AppPrefs> instance() async {
    _cached ??= await SharedPreferences.getInstance();
    return AppPrefs._(_cached!);
  }

  Future<void> saveGradientStyle(GradientStyle style) async {
    await _sp.setString(_kGradientStyle, style.name);
  }

  GradientStyle readGradientStyle() {
    final raw = _sp.getString(_kGradientStyle);
    return GradientStyle.values.firstWhere(
      (e) => e.name == raw,
      orElse: () => GradientStyle.aurora,
    );
  }

  Future<void> reset() async {
    await _sp.remove(_kGradientStyle);
  }
}

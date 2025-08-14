import 'package:shared_preferences/shared_preferences.dart';
class LangPrefs {
  static const _k = 'wissen.lang'; // 'de' | 'en'
  static Future<String> get() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_k) ?? 'de';
  }
  static Future<void> set(String lang) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_k, lang);
  }
}

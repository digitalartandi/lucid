import 'package:shared_preferences/shared_preferences.dart';

class AutoUpdatePrefs {
  static const _kEnabled = 'autoUpdate.enabled';
  static const _kFreqMins = 'autoUpdate.freqMins';
  static const _kQuery = 'autoUpdate.query';

  static Future<void> setEnabled(bool v) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kEnabled, v);
  }
  static Future<bool> isEnabled() async {
    final p = await SharedPreferences.getInstance();
    return p.getBool(_kEnabled) ?? false;
  }

  static Future<void> setFreqMins(int mins) async {
    final p = await SharedPreferences.getInstance();
    await p.setInt(_kFreqMins, mins);
  }
  static Future<int> getFreqMins() async {
    final p = await SharedPreferences.getInstance();
    return p.getInt(_kFreqMins) ?? 1440; // default daily
  }

  static Future<void> setQuery(String q) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_kQuery, q);
  }
  static Future<String> getQuery() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_kQuery) ?? 'lucid dreaming OR lucid dream OR targeted memory reactivation dream';
  }
}

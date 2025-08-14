import 'package:shared_preferences/shared_preferences.dart';

class FirstRunPrefs {
  static const _kWissenCoach = 'firstRun.wissenCoachSeen';
  static Future<bool> isWissenCoachSeen() async {
    final p = await SharedPreferences.getInstance();
    return p.getBool(_kWissenCoach) ?? false;
  }
  static Future<void> setWissenCoachSeen(bool v) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kWissenCoach, v);
  }
}

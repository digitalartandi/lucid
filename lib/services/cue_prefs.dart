import 'package:shared_preferences/shared_preferences.dart';

class CuePrefsKeys {
  static const volume   = 'cue_tuning_volume_v1';
  static const interval = 'cue_tuning_interval_min_v1';
  static const asset    = 'cue_tuning_asset_v1';
}

class CueConfig {
  final double volume;        // 0..1
  final double intervalMin;   // Minuten
  final String? asset;        // assets/audio/cues/*.mp3
  const CueConfig({required this.volume, required this.intervalMin, required this.asset});
}

class CuePrefs {
  static Future<CueConfig> load() async {
    final p = await SharedPreferences.getInstance();
    final volume   = p.getDouble(CuePrefsKeys.volume)   ?? 0.8;
    final interval = p.getDouble(CuePrefsKeys.interval) ?? 10.0;
    final asset    = p.getString(CuePrefsKeys.asset);
    return CueConfig(volume: volume, intervalMin: interval, asset: asset);
  }
}

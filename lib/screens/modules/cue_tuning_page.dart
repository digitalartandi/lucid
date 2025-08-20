import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../screens/cues/cue_library_page.dart';
import '../../services/cue_player.dart';
import '../../models/cue_models.dart';

class CueTuningPage extends StatefulWidget {
  const CueTuningPage({super.key});
  @override
  State<CueTuningPage> createState() => _CueTuningPageState();
}

class _CueTuningPageState extends State<CueTuningPage> {
  // Persistenz-Keys
  static const _kVolume = 'cue_tuning_volume_v1';
  static const _kInterval = 'cue_tuning_interval_min_v1';
  static const _kAsset = 'cue_tuning_asset_v1';

  // Zustand
  double _volume = 0.8;     // 0..1
  double _interval = 10.0;  // Minuten
  CueSound? _selected;
  String? _selectedAssetPath; // falls _selected nicht geladen ist (z. B. nach App-Neustart)
  bool _playing = false;

  final _cuePlayer = CueLoopPlayer.instance;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  @override
  void dispose() {
    _cuePlayer.stop();
    super.dispose();
  }

  Future<void> _loadPrefs() async {
    final p = await SharedPreferences.getInstance();
    setState(() {
      _volume = p.getDouble(_kVolume) ?? 0.8;
      _interval = p.getDouble(_kInterval) ?? 10.0;
      _selectedAssetPath = p.getString(_kAsset);
    });
  }

  Future<void> _saveVolume(double v) async {
    final p = await SharedPreferences.getInstance();
    await p.setDouble(_kVolume, v);
  }

  Future<void> _saveInterval(double v) async {
    final p = await SharedPreferences.getInstance();
    await p.setDouble(_kInterval, v);
  }

  Future<void> _saveAsset(String asset) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_kAsset, asset);
  }

  // Helfer: hübscher Anzeigename aus Asset-Pfad
  String _displayNameFromAsset(String assetPath) {
    final base = assetPath.split('/').last.replaceAll('.mp3', '');
    final clean = base.replaceAll('_', ' ').replaceAll('-', ' ');
    return clean.split(' ').where((w) => w.isNotEmpty).map((w) {
      final lower = w.toLowerCase();
      return '${lower[0].toUpperCase()}${lower.substring(1)}';
    }).join(' ');
  }

  Future<void> _pickCue() async {
    final pick = await Navigator.of(context).push<CueSound>(
      CupertinoPageRoute(builder: (_) => const CueLibraryPage(returnOnPick: true)),
    );
    if (pick != null) {
      setState(() {
        _selected = pick;
        _selectedAssetPath = pick.id;
      });
      await _saveAsset(pick.id);
      await _cuePlayer.playLoop(pick.id, volume: _volume);
      setState(() => _playing = true);
    }
  }

  Future<void> _play() async {
    final asset = _selected?.id ?? _selectedAssetPath;
    if (asset == null) return;
    await _cuePlayer.playLoop(asset, volume: _volume);
    setState(() => _playing = true);
  }

  Future<void> _stop() async {
    await _cuePlayer.stop();
    setState(() => _playing = false);
  }

  Future<void> _probe() async {
    await _play();
    // kurze Probe (5s), dann leise ausblenden und stoppen
    await Future.delayed(const Duration(seconds: 5));
    if (mounted) await _stop();
  }

  @override
  Widget build(BuildContext context) {
    final chosenName = _selected != null
        ? _selected!.name
        : (_selectedAssetPath != null ? _displayNameFromAsset(_selectedAssetPath!) : 'Kein Cue gewählt');

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Cue-Tuning'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _playing ? _stop : _play,
          child: Icon(_playing ? CupertinoIcons.pause_fill : CupertinoIcons.play_fill),
        ),
      ),
      child: SafeArea(
        child: ListView(
          children: [
            // Auswahl & Vorschau
            CupertinoListSection.insetGrouped(
              header: const Text('Cue'),
              children: [
                CupertinoListTile(
                  title: const Text('Gewählter Cue'),
                  subtitle: Text(chosenName),
                  trailing: CupertinoButton(
                    onPressed: _pickCue,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: const Text('Auswählen'),
                  ),
                ),
                CupertinoListTile(
                  title: const Text('Probe abspielen'),
                  subtitle: const Text('5 Sekunden mit aktueller Lautstärke'),
                  trailing: CupertinoButton(
                    onPressed: (_selected != null || _selectedAssetPath != null) ? _probe : null,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: const Text('Probe-Cue'),
                  ),
                ),
                CupertinoListTile(
                  title: const Text('Wiedergabe'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CupertinoButton(
                        onPressed: (_selected != null || _selectedAssetPath != null) ? _play : null,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        child: const Text('Play'),
                      ),
                      const SizedBox(width: 6),
                      CupertinoButton(
                        onPressed: _playing ? _stop : null,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        child: const Text('Stop'),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Lautstärke / Intervall
            CupertinoListSection.insetGrouped(
              header: const Text('Feinabstimmung'),
              children: [
                CupertinoListTile(
                  title: const Text('Lautstärke'),
                  trailing: SizedBox(
                    width: 200,
                    child: CupertinoSlider(
                      value: _volume,
                      onChanged: (v) async {
                        setState(() => _volume = v);
                        await _cuePlayer.setVolume(v);
                        await _saveVolume(v);
                      },
                    ),
                  ),
                ),
                CupertinoListTile(
                  title: Text('Intervall: ${_interval.toStringAsFixed(0)} min'),
                  subtitle: const Text('Zeit zwischen zwei Cues'),
                  trailing: SizedBox(
                    width: 200,
                    child: CupertinoSlider(
                      min: 5,
                      max: 30,
                      value: _interval,
                      onChanged: (v) async {
                        setState(() => _interval = v);
                        await _saveInterval(v);
                      },
                    ),
                  ),
                ),
              ],
            ),

            // Hinweise
            CupertinoListSection.insetGrouped(
              children: const [
                CupertinoListTile(
                  title: Text('Hinweis'),
                  subtitle: Text(
                    'Die Auswahl und Einstellungen werden automatisch gespeichert '
                    'und in RC-Reminder / Night Lite+ verwendet.',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

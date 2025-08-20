import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/cue_player.dart';
import '../../services/cue_prefs.dart';

const _bg = Color(0xFF0A0A23);
const _title = Color(0xFFE9EAFF);
const _hint = Color(0xCCFFFFFF);

class RcReminderPage extends StatefulWidget {
  const RcReminderPage({super.key});

  @override
  State<RcReminderPage> createState() => _RcReminderPageState();
}

class _RcReminderPageState extends State<RcReminderPage> {
  final _cuePlayer = CueLoopPlayer.instance;

  CueConfig _cfg = const CueConfig(volume: 0.8, intervalMin: 10.0, asset: null);
  double _interval = 10.0; // Minuten – wir synchronisieren mit CuePrefs
  bool _running = false;
  bool _playImmediately = true;
  double _pulseSeconds = 4; // Dauer eines kurzen RC-Hinweises

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadCue();
  }

  @override
  void dispose() {
    _stopReminders();
    super.dispose();
  }

  Future<void> _loadCue() async {
    final cfg = await CuePrefs.load();
    if (!mounted) return;
    setState(() {
      _cfg = cfg;
      _interval = cfg.intervalMin;
    });
  }

  Future<void> _saveInterval(double min) async {
    final p = await SharedPreferences.getInstance();
    await p.setDouble(CuePrefsKeys.interval, min);
    setState(() {
      _interval = min;
      _cfg = CueConfig(volume: _cfg.volume, intervalMin: min, asset: _cfg.asset);
    });
  }

  Future<void> _startReminders() async {
    if (_cfg.asset == null) {
      _askForCue();
      return;
    }
    setState(() => _running = true);

    if (_playImmediately) {
      unawaited(_playPulse());
    }

    _timer?.cancel();
    _timer = Timer.periodic(
      Duration(minutes: _interval.clamp(1, 180).round()),
      (_) => _playPulse(),
    );
  }

  Future<void> _playPulse() async {
    if (_cfg.asset == null) return;
    await _cuePlayer.playLoop(_cfg.asset!, volume: _cfg.volume);
    await Future.delayed(Duration(seconds: _pulseSeconds.round()));
    await _cuePlayer.stop();
  }

  Future<void> _stopReminders() async {
    _timer?.cancel();
    _timer = null;
    await _cuePlayer.stop();
    if (mounted) setState(() => _running = false);
  }

  Future<void> _probe5s() async {
    if (_cfg.asset == null) {
      _askForCue();
      return;
    }
    await _cuePlayer.playLoop(_cfg.asset!, volume: _cfg.volume);
    await Future.delayed(const Duration(seconds: 5));
    await _cuePlayer.stop();
  }

  void _askForCue() {
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('Cue auswählen'),
        content: const Text('Bitte wähle zuerst einen Cue in Cue-Tuning aus.'),
        actions: [
          CupertinoDialogAction(
            child: const Text('Später'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text('Jetzt auswählen'),
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed('/cuetuning');
            },
          ),
        ],
      ),
    );
  }

  String get _assetName {
    final a = _cfg.asset;
    if (a == null) return 'Kein Cue gewählt';
    final base = a.split('/').last.replaceAll('.mp3', '');
    final clean = base.replaceAll('_', ' ').replaceAll('-', ' ');
    return clean
        .split(' ')
        .where((w) => w.isNotEmpty)
        .map((w) => w[0].toUpperCase() + w.substring(1))
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: _bg,
      navigationBar: CupertinoNavigationBar(
        middle: const Text('RC-Reminder'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _running ? _stopReminders : _startReminders,
          child: Icon(_running ? CupertinoIcons.pause_fill : CupertinoIcons.play_fill),
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            CupertinoListSection.insetGrouped(
              header: const Text('Cue'),
              children: [
                CupertinoListTile(
                  title: const Text('Gewählter Cue', style: TextStyle(color: _title)),
                  subtitle: Text(_assetName, style: const TextStyle(color: _hint)),
                  trailing: CupertinoButton(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    onPressed: () => Navigator.of(context).pushNamed('/cuetuning'),
                    child: const Text('Ändern'),
                  ),
                ),
                CupertinoListTile(
                  title: const Text('Probe (5 Sekunden)', style: TextStyle(color: _title)),
                  subtitle: const Text('Spielt den aktuellen Cue kurz an.', style: TextStyle(color: _hint)),
                  trailing: CupertinoButton(
                    onPressed: _probe5s,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: const Text('Probe'),
                  ),
                ),
              ],
            ),

            CupertinoListSection.insetGrouped(
              header: const Text('Erinnerungen'),
              children: [
                CupertinoListTile(
                  title: Text('Intervall: ${_interval.round()} min',
                      style: const TextStyle(color: _title)),
                  subtitle: const Text('Zeit zwischen zwei RC-Cues (wird in Cue-Tuning übernommen)',
                      style: TextStyle(color: _hint)),
                  trailing: SizedBox(
                    width: 200,
                    child: CupertinoSlider(
                      min: 5,
                      max: 60,
                      value: _interval,
                      onChanged: (v) => _saveInterval(v),
                    ),
                  ),
                ),
                CupertinoListTile(
                  title: Text('Cue-Dauer: ${_pulseSeconds.round()} s',
                      style: const TextStyle(color: _title)),
                  subtitle: const Text('Wie lange der Hinweis klingt.', style: TextStyle(color: _hint)),
                  trailing: SizedBox(
                    width: 200,
                    child: CupertinoSlider(
                      min: 2,
                      max: 12,
                      value: _pulseSeconds,
                      onChanged: (v) => setState(() => _pulseSeconds = v),
                    ),
                  ),
                ),
                CupertinoListTile(
                  title: const Text('Sofort starten', style: TextStyle(color: _title)),
                  subtitle: const Text('Ersten Cue direkt nach „Play“ abspielen.',
                      style: TextStyle(color: _hint)),
                  trailing: CupertinoSwitch(
                    value: _playImmediately,
                    onChanged: (v) => setState(() => _playImmediately = v),
                  ),
                ),
              ],
            ),

            CupertinoListSection.insetGrouped(
              children: [
                CupertinoListTile(
                  title: Text(_running ? 'Erinnerungen aktiv' : 'Bereit',
                      style: const TextStyle(color: _title)),
                  subtitle: Text(
                    _running
                        ? 'Intervall: ${_interval.round()} min – tippe oben rechts, um zu pausieren.'
                        : 'Tippe oben rechts auf Play, um zu starten.',
                    style: const TextStyle(color: _hint),
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

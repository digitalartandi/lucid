import 'dart:async';
import 'package:flutter/cupertino.dart';

import '../../services/cue_player.dart';
import '../../services/cue_prefs.dart';

const _bg = Color(0xFF0B0F2A);
const _title = Color(0xFFF7F8FF);
const _muted = Color(0xCCFFFFFF);
const _card = Color(0x161C2A66);
const _stroke = Color(0x33FFFFFF);

class NightLitePage extends StatefulWidget {
  const NightLitePage({super.key});

  @override
  State<NightLitePage> createState() => _NightLitePageState();
}

class _NightLitePageState extends State<NightLitePage> {
  final _cuePlayer = CueLoopPlayer.instance;

  CueConfig _cfg = const CueConfig(volume: 0.8, intervalMin: 10.0, asset: null);

  bool _active = false;
  bool _loopAllNight = true;
  double _burstSeconds = 10; // wenn nicht loop: Dauer eines Burst-Cues
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadCue();
  }

  Future<void> _loadCue({bool showToast = false}) async {
    final cfg = await CuePrefs.load();
    if (!mounted) return;
    setState(() => _cfg = cfg);

    if (showToast) {
      await showCupertinoDialog(
        context: context,
        builder: (_) => CupertinoAlertDialog(
          title: const Text('Cue übernommen'),
          content: Text(_assetName),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              child: const Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
    }
  }

  @override
  void dispose() {
    _stopNightLite();
    super.dispose();
  }

  Future<void> _startNightLite() async {
    if (_cfg.asset == null) {
      _askForCue();
      return;
    }
    setState(() => _active = true);

    if (_loopAllNight) {
      await _cuePlayer.playLoop(_cfg.asset!, volume: _cfg.volume); // startet jetzt sofort (Player-Fix)
    } else {
      await _runBurst();
      _timer?.cancel();
      _timer = Timer.periodic(
        Duration(minutes: _cfg.intervalMin.clamp(1, 120).round()),
        (_) => _runBurst(),
      );
    }
  }

  Future<void> _runBurst() async {
    if (_cfg.asset == null) return;
    await _cuePlayer.playLoop(_cfg.asset!, volume: _cfg.volume);
    await Future.delayed(Duration(seconds: _burstSeconds.round()));
    await _cuePlayer.stop();
  }

  Future<void> _stopNightLite() async {
    _timer?.cancel();
    _timer = null;
    await _cuePlayer.stop();
    if (mounted) setState(() => _active = false);
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
              Navigator.of(context).pushNamed('/cuetuning').then((_) => _loadCue(showToast: true));
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
    final sectionDecoration = BoxDecoration(
      color: _card,
      borderRadius: const BorderRadius.all(Radius.circular(16)),
      border: Border.all(color: _stroke),
    );

    return CupertinoPageScaffold(
      backgroundColor: _bg,
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Night Lite+'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _active ? _stopNightLite : _startNightLite,
          child: Icon(_active ? CupertinoIcons.pause_fill : CupertinoIcons.play_fill),
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            // Cue
            Container(
              decoration: sectionDecoration,
              child: CupertinoListSection(
                header: const Text('Cue', style: TextStyle(color: _muted)),
                backgroundColor: _card,
                children: [
                  CupertinoListTile(
                    title: const Text('Gewählter Cue', style: TextStyle(color: _title)),
                    subtitle: Text(_assetName, style: const TextStyle(color: _muted)),
                    trailing: CupertinoButton(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      onPressed: () => Navigator.of(context).pushNamed('/cuetuning').then((_) => _loadCue(showToast: true)),
                      child: const Text('Ändern'),
                    ),
                  ),
                  CupertinoListTile(
                    title: const Text('Probe (5 Sekunden)', style: TextStyle(color: _title)),
                    subtitle: const Text('Spielt den aktuellen Cue kurz an.', style: TextStyle(color: _muted)),
                    trailing: CupertinoButton(
                      onPressed: _probe5s,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: const Text('Probe'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Modus
            Container(
              decoration: sectionDecoration,
              child: CupertinoListSection(
                header: const Text('Modus', style: TextStyle(color: _muted)),
                backgroundColor: _card,
                children: [
                  CupertinoListTile(
                    title: const Text('Durchgehend loopen', style: TextStyle(color: _title)),
                    subtitle: const Text('Spielt den Cue dauerhaft im Loop.', style: TextStyle(color: _muted)),
                    trailing: CupertinoSwitch(
                      value: _loopAllNight,
                      onChanged: (v) {
                        if (_active) {
                          _stopNightLite();
                        }
                        setState(() => _loopAllNight = v);
                      },
                    ),
                  ),
                  if (!_loopAllNight)
                    CupertinoListTile(
                      title: Text('Cue-Dauer: ${_burstSeconds.round()} s', style: const TextStyle(color: _title)),
                      subtitle: const Text('Abspielzeit pro Burst', style: TextStyle(color: _muted)),
                      trailing: SizedBox(
                        width: 200,
                        child: CupertinoSlider(
                          min: 3,
                          max: 20,
                          value: _burstSeconds,
                          onChanged: (v) => setState(() => _burstSeconds = v),
                        ),
                      ),
                    ),
                  if (!_loopAllNight)
                    CupertinoListTile(
                      title: Text('Intervall: ${_cfg.intervalMin.round()} min', style: const TextStyle(color: _title)),
                      subtitle: const Text('Zeit zwischen zwei Bursts (aus Cue-Tuning)', style: TextStyle(color: _muted)),
                      trailing: CupertinoButton(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        onPressed: () => Navigator.of(context).pushNamed('/cuetuning').then((_) => _loadCue()),
                        child: const Text('Ändern'),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Status
            Container(
              decoration: sectionDecoration,
              child: CupertinoListSection(
                backgroundColor: _card,
                children: [
                  CupertinoListTile(
                    title: Text(_active ? 'Nacht-Session läuft' : 'Bereit', style: const TextStyle(color: _title)),
                    subtitle: Text(
                      _active
                          ? (_loopAllNight
                              ? 'Loop aktiv – tippe oben rechts, um zu pausieren.'
                              : 'Burst-Modus aktiv – Intervall & Dauer siehe oben.')
                          : 'Tippe oben rechts auf Play, um zu starten.',
                      style: const TextStyle(color: _muted),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

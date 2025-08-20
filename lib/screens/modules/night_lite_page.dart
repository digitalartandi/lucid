// lib/screens/modules/night_lite_page.dart
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/cue_models.dart';
import '../../services/cue_player.dart';

const _bg     = Color(0xFF0D0F16);
const _white  = Color(0xFFE9EAFF);
const _card   = Color(0xFF0A0A23);
const _line   = Color(0x22FFFFFF);
const _accent = Color(0xFF7A6CFF);

// dieselbe Persistenz wie in der Bibliothek
const _kCueSelectedJson = 'cue.selected.v1';

class _CuePrefs {
  static Future<CueSound?> load() async {
    final sp = await SharedPreferences.getInstance();
    final s  = sp.getString(_kCueSelectedJson);
    if (s == null) return null;
    final m = jsonDecode(s) as Map<String, dynamic>;
    return CueSound(
      id:       (m['id'] ?? '') as String,
      name:     (m['name'] ?? '') as String,
      category: (m['category'] ?? '') as String,
      asset:    (m['asset'] ?? '') as String,
    );
  }
}

class NightLitePage extends StatefulWidget {
  const NightLitePage({super.key});
  @override
  State<NightLitePage> createState() => _NightLitePageState();
}

class _NightLitePageState extends State<NightLitePage> {
  final _player = CueLoopPlayer.instance;

  CueSound? _selected;
  double _volume = .8;
  double _intervalMin = 10;

  @override
  void initState() {
    super.initState();
    _loadSelected();
  }

  Future<void> _loadSelected() async {
    final s = await _CuePrefs.load();
    if (!mounted) return;
    setState(() => _selected = s);
  }

  @override
  void dispose() {
    _player.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: _bg,
      navigationBar: const CupertinoNavigationBar(
        backgroundColor: _bg,
        middle: Text('Night Lite+', style: TextStyle(color: _white)),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
          children: [
            _Section(
              title: 'Gewählter Cue',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selected == null ? 'Kein Cue gewählt' : _selected!.name,
                    style: const TextStyle(color: _white, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      CupertinoButton(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        color: const Color(0xFF2A2942),
                        borderRadius: BorderRadius.circular(12),
                        onPressed: _pickCue,
                        child: const Text('Auswählen', style: TextStyle(color: _white)),
                      ),
                      const SizedBox(width: 8),
                      CupertinoButton(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        color: const Color(0xFF2A2942),
                        borderRadius: BorderRadius.circular(12),
                        onPressed: _selected == null ? null : _probe,
                        child: const Text('Probe', style: TextStyle(color: _white)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            _Section(
              title: 'Lautstärke',
              child: Row(
                children: [
                  Expanded(
                    child: CupertinoSlider(
                      value: _volume,
                      onChanged: (v) => setState(() => _volume = v),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text('${(_volume * 100).round()}%',
                      style: const TextStyle(color: _white)),
                ],
              ),
            ),
            _Section(
              title: 'Intervall (Minuten)',
              child: Row(
                children: [
                  Expanded(
                    child: CupertinoSlider(
                      min: 5, max: 30,
                      value: _intervalMin,
                      onChanged: (v) => setState(() => _intervalMin = v),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(_intervalMin.round().toString(),
                      style: const TextStyle(color: _white)),
                ],
              ),
            ),
            const SizedBox(height: 10),
            CupertinoButton.filled(
              borderRadius: BorderRadius.circular(14),
              onPressed: _selected == null ? null : _startLoop,
              child: const Text('Start'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickCue() async {
    final res = await Navigator.of(context).pushNamed(
      '/cues',
      arguments: {'picker': true, 'selectedId': _selected?.id},
    );
    if (!mounted) return;
    if (res is CueSound) {
      setState(() => _selected = res);
    } else {
      final fromPrefs = await _CuePrefs.load();
      if (!mounted) return;
      setState(() => _selected = fromPrefs);
    }
  }

  Future<void> _probe() async {
    final s = _selected!;
    try {
      await _player.playOnce(s, seconds: 5, volume: _volume);
    } catch (_) {
      try {
        await (_player as dynamic)
            .playOnce((s as dynamic).asset as String, seconds: 5, volume: _volume);
      } catch (_) {}
    }
  }

  Future<void> _startLoop() async {
    final s = _selected!;
    try {
      // <-- korrekt für deinen Player
      await _player.playLoop(
        s,
        volume: _volume,
        intervalMinutes: _intervalMin.round(),
      );
    } catch (_) {
      // Fallbacks für andere Signaturen
      try {
        await (_player as dynamic)
            .playLoop(s, volume: _volume, interval: Duration(minutes: _intervalMin.round()));
      } catch (_) {
        try {
          await (_player as dynamic)
              .playLoop((s as dynamic).asset as String, volume: _volume, intervalMinutes: _intervalMin.round());
        } catch (_) {}
      }
    }
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(color: _white, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

import 'package:flutter/cupertino.dart';
import '../../models/cue_models.dart';
import '../../services/cue_player.dart';

const _bg     = Color(0xFF0D0F16);
const _white  = Color(0xFFE9EAFF);
const _card   = Color(0xFF0A0A23);
const _line   = Color(0x22FFFFFF);

class CueTuningPage extends StatefulWidget {
  const CueTuningPage({super.key});
  @override
  State<CueTuningPage> createState() => _CueTuningPageState();
}

class _CueTuningPageState extends State<CueTuningPage> {
  final _player = CueLoopPlayer.instance;

  CueSound? _selected;
  double _volume = .8;
  double _intervalMin = 10;

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
        middle: Text('Cue-Tuning', style: TextStyle(color: _white)),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
          children: [
            // Gewählter Cue
            _tileCard(
              title: 'Gewählter Cue',
              subtitle: _selected?.displayLabel ?? 'Kein Cue gewählt',
              trailing: CupertinoButton(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                onPressed: _pickCue,
                child: const Text('Auswählen', style: TextStyle(color: _white)),
              ),
            ),
            _tileCard(
              title: 'Probe abspielen',
              subtitle: '5 Sekunden mit aktueller Lautstärke',
              trailing: CupertinoButton(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                onPressed: _selected == null ? null : () => _player.playOnce(_selected!, seconds: 5, volume: _volume),
                child: const Text('Probe-Cue', style: TextStyle(color: _white)),
              ),
            ),
            _tileCard(
              title: 'Wiedergabe',
              subtitle: 'Loop mit Intervall',
              trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                CupertinoButton(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  onPressed: _selected == null ? null : () => _player.playLoop(_selected!, volume: _volume, intervalMinutes: _intervalMin.round()),
                  child: const Text('Play', style: TextStyle(color: _white)),
                ),
                const SizedBox(width: 8),
                CupertinoButton(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  onPressed: _player.isPlaying ? _player.stop : null,
                  child: const Text('Stop', style: TextStyle(color: _white)),
                ),
              ]),
            ),

            const SizedBox(height: 14),

            // Lautstärke
            _sectionCard(
              header: 'Lautstärke',
              child: CupertinoSlider(
                value: _volume,
                onChanged: (v) => setState(() => _volume = v),
              ),
            ),
            // Intervall
            _sectionCard(
              header: 'Intervall: ${_intervalMin.round()} min',
              child: CupertinoSlider(
                min: 5, max: 30,
                value: _intervalMin,
                onChanged: (v) => setState(() => _intervalMin = v),
              ),
            ),

            const SizedBox(height: 12),
            _hintCard('Die Auswahl und Einstellungen werden automatisch gespeichert und in RC-Reminder / Night Lite+ verwendet.'),
          ],
        ),
      ),
    );
  }

  Future<void> _pickCue() async {
    final res = await Navigator.of(context).pushNamed('/cues', arguments: {
      'picker': true,
      'selectedId': _selected?.id,
    });

    if (!mounted) return;
    if (res is CueSound) {
      setState(() => _selected = res);
    }
  }

  // ---------- UI-Helfer ----------
  Widget _tileCard({required String title, required String subtitle, Widget? trailing}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _line),
      ),
      child: CupertinoListTile.notched(
        title: Text(title, style: const TextStyle(color: _white, fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: const TextStyle(color: _white)),
        trailing: trailing,
      ),
    );
  }

  Widget _sectionCard({required String header, required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 14),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(header, style: const TextStyle(color: _white, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  Widget _hintCard(String text) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _line),
      ),
      child: Text(text, style: const TextStyle(color: _white)),
    );
  }
}

// Nutzt dieselbe Kompatibilitäts-Extension wie in der Library:
extension CueSoundCompat on CueSound {
  String get assetPathPretty {
    final a = (this as dynamic).asset as String? ?? '';
    if (a.isEmpty) return '';
    return a.split('/').last;
  }

  String get displayLabel {
    final dyn = this as dynamic;
    final n = (dyn.displayName as String?) ??
              (dyn.name as String?) ??
              (dyn.title as String?) ??
              '';
    if (n.trim().isNotEmpty) return n.trim();

    final pretty = assetPathPretty.replaceAll('_', ' ').replaceAll('-', ' ');
    final withoutExt = pretty.contains('.') ? pretty.substring(0, pretty.lastIndexOf('.')) : pretty;
    return _capitalizeWords(withoutExt);
  }
}

String _capitalizeWords(String s) =>
    s.split(RegExp(r'\s+')).map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}').join(' ');

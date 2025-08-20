// lib/screens/modules/cue_tuning_page.dart
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/cue_models.dart';
import '../../services/cue_player.dart';
import '../cues/cue_library_page.dart' show kCueBase;

const _bg     = Color(0xFF0D0F16);
const _white  = Color(0xFFE9EAFF);
const _card   = Color(0xFF0A0A23);
const _line   = Color(0x22FFFFFF);
const _violet = Color(0xFF7A6CFF);

const _selectedCueKey = 'selected_cue_id';

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
  void initState() {
    super.initState();
    _restore();
  }

  Future<void> _restore() async {
    final sp = await SharedPreferences.getInstance();
    final id = sp.getString(_selectedCueKey);
    if (id != null) {
      // Aus der gespeicherten ID einen vollwertigen Cue bauen (inkl. Asset-Pfad)
      setState(() => _selected = CueSound(
            id: id,
            name: _labelFromId(id),
            category: '',
            asset: '$kCueBase$id.mp3',
          ));
    }
  }

  String _labelFromId(String id) {
    final base = id.replaceAll('_', ' ').replaceAll('-', ' ');
    return base.substring(0, 1).toUpperCase() + base.substring(1);
  }

  Future<void> _pickCue() async {
    final result = await Navigator.of(context).pushNamed(
      '/cues',
      arguments: {'picker': true, 'selectedId': _selected?.id},
    );

    if (!mounted) return;
    if (result is CueSound) {
      setState(() => _selected = result);
      final sp = await SharedPreferences.getInstance();
      await sp.setString(_selectedCueKey, result.id);

      showCupertinoDialog(
        context: context,
        builder: (_) => CupertinoAlertDialog(
          title: const Text('Gespeichert'),
          content: Text('„${result.name}“ wird ab jetzt verwendet.'),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
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
        middle: Text('Cue-Tuning', style: TextStyle(color: _white)),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 32),
          children: [
            _cardBox(
              child: CupertinoListTile.notched(
                title: const Text('Gewählter Cue', style: TextStyle(color: _white)),
                subtitle: Text(_selected?.name ?? 'Kein Cue gewählt',
                    style: const TextStyle(color: _white)),
                trailing: CupertinoButton(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  onPressed: _pickCue,
                  child: const Text('Auswählen', style: TextStyle(color: _white)),
                ),
              ),
            ),
            const SizedBox(height: 10),

            _cardBox(
              child: CupertinoListTile.notched(
                title: const Text('Probe abspielen', style: TextStyle(color: _white)),
                subtitle: const Text('5 Sekunden mit aktueller Lautstärke',
                    style: TextStyle(color: _white)),
                trailing: CupertinoButton(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  onPressed: _selected == null
                      ? null
                      : () => _player.playOnce(_selected!, seconds: 5, volume: _volume),
                  child: const Text('Probe-Cue', style: TextStyle(color: _white)),
                ),
              ),
            ),
            const SizedBox(height: 10),

            _cardBox(
              child: CupertinoListTile.notched(
                title: const Text('Wiedergabe', style: TextStyle(color: _white)),
                trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                  CupertinoButton(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    onPressed: _selected == null
                        ? null
                        : () => _player.playLoop(_selected!, volume: _volume),
                    child: const Text('Play', style: TextStyle(color: _white)),
                  ),
                  const SizedBox(width: 8),
                  CupertinoButton(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    onPressed: _player.isPlaying ? _player.stop : null,
                    child: const Text('Stop', style: TextStyle(color: _white)),
                  ),
                ]),
              ),
            ),
            const SizedBox(height: 16),

            _sectionLabel('Lautstärke'),
            _cardBox(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Row(
                children: [
                  const Icon(CupertinoIcons.speaker_2, color: _white, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: CupertinoSlider(
                      value: _volume,
                      onChanged: (v) => setState(() => _volume = v),
                      min: 0, max: 1,
                      activeColor: _violet,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            _sectionLabel('Intervall: ${_intervalMin.round()} min'),
            _cardBox(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Row(
                children: [
                  const Icon(CupertinoIcons.timer, color: _white, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: CupertinoSlider(
                      value: _intervalMin,
                      onChanged: (v) => setState(() => _intervalMin = v),
                      min: 5, max: 30,
                      activeColor: _violet,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),
            _cardBox(
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  'Die Auswahl und Einstellungen werden automatisch gespeichert '
                  'und in RC-Reminder / Night Lite+ verwendet.',
                  style: TextStyle(color: _white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String t) =>
      Padding(padding: const EdgeInsets.only(bottom: 8, left: 2), child: Text(
        t, style: const TextStyle(color: _white, fontWeight: FontWeight.w700)));

  Widget _cardBox({required Widget child, EdgeInsets padding = EdgeInsets.zero}) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: _card, borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _line),
      ),
      child: child,
    );
  }
}

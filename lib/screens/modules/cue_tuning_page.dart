// lib/screens/modules/cue_tuning_page.dart
import 'dart:convert' show jsonDecode, jsonEncode;
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/cue_models.dart' show CueSound;
import '../../services/cue_player.dart';

// Farben
const _bg     = Color(0xFF0D0F16);
const _white  = Color(0xFFE9EAFF);
const _card   = Color(0xFF0A0A23);
const _line   = Color(0x22FFFFFF);
const _accent = Color(0xFF7A6CFF);

// Persistenz-Keys
const _kCueSelectedJson = 'cue.selected.v1';
const _kBgAssetV1       = 'cue.bg.asset.v1';

class CueTuningPage extends StatefulWidget {
  const CueTuningPage({super.key});
  @override
  State<CueTuningPage> createState() => _CueTuningPageState();
}

class _CueTuningPageState extends State<CueTuningPage> {
  final _player = CueLoopPlayer.instance;

  CueSound? _selected; // gewählter Cue
  String? _bgAsset;    // optionaler Hintergrund

  double _volume = .8;
  double _intervalMin = 10;

  @override
  void initState() {
    super.initState();
    _restoreSelection();
  }

  Future<void> _restoreSelection() async {
    final sp = await SharedPreferences.getInstance();

    // Cue laden
    final json = sp.getString(_kCueSelectedJson);
    if (json != null) {
      final m = jsonDecode(json) as Map<String, dynamic>;
      _selected = CueSound(
        id:       (m['id'] ?? '') as String,
        name:     (m['name'] ?? '') as String,
        category: (m['category'] ?? '') as String,
        asset:    (m['asset'] ?? '') as String,
      );
    } else {
      _selected = null;
    }

    // Hintergrund laden
    _bgAsset = sp.getString(_kBgAssetV1);

    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _player.stop(); // beides stoppen
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: _bg,
      navigationBar: const CupertinoNavigationBar(
        backgroundColor: _bg,
        middle: Text('Cue–Tuning', style: TextStyle(color: _white)),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
          children: [
            // Gewählter Cue
            _tileCard(
              title: 'Gewählter Cue',
              subtitle: _selected?.name ?? 'Kein Cue gewählt',
              trailing: CupertinoButton(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                onPressed: _pickCue,
                child: const Text('Auswählen', style: TextStyle(color: _white)),
              ),
            ),

            // Hintergrund (optional)
            _tileCard(
              title: 'Hintergrund (optional)',
              subtitle: _bgAsset == null || _bgAsset!.isEmpty
                  ? 'Kein Hintergrund gewählt'
                  : _bgAsset!.split('/').last,
              trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                CupertinoButton(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  onPressed: _pickBackground,
                  child: const Text('Auswählen', style: TextStyle(color: _white)),
                ),
                const SizedBox(width: 8),
                CupertinoButton(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  onPressed: (_bgAsset == null || _bgAsset!.isEmpty)
                      ? null
                      : () async {
                          final sp = await SharedPreferences.getInstance();
                          await sp.remove(_kBgAssetV1);
                          if (!mounted) return;
                          setState(() => _bgAsset = null);
                        },
                  child: const Text('Entfernen', style: TextStyle(color: _white)),
                ),
              ]),
            ),

            // Probe
            _tileCard(
              title: 'Probe abspielen',
              subtitle: '5 Sekunden mit aktueller Lautstärke',
              trailing: CupertinoButton(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                onPressed: _selected == null
                    ? null
                    : () => _player.playOnce(_selected!, seconds: 5, volume: _volume),
                child: const Text('Probe–Cue', style: TextStyle(color: _white)),
              ),
            ),

            // Wiedergabe
            _tileCard(
              title: 'Wiedergabe',
              subtitle: 'Loop oder Intervall',
              trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                CupertinoButton(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  onPressed: _selected == null
                      ? null
                      : () async {
                          // 1) Hintergrund-Loop (falls gesetzt)
                          if (_bgAsset != null && _bgAsset!.isNotEmpty) {
                            await _player.startBedAsset(_bgAsset!, volume: 0.35);
                          }
                          // 2) Cue: Dauerloop (<=0) oder Intervall (>0)
                          final minutes = _intervalMin.round();
                          await _player.playLoop(
                            _selected!,
                            volume: _volume,
                            intervalMinutes: (minutes <= 0) ? null : minutes,
                          );
                          if (mounted) setState(() {});
                        },
                  child: const Text('Play', style: TextStyle(color: _white)),
                ),
                const SizedBox(width: 8),
                CupertinoButton(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  onPressed: _player.isPlaying || _player.isBedPlaying
                      ? () async {
                          await _player.stop();
                          if (mounted) setState(() {});
                        }
                      : null,
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
              header: 'Intervall: ${_intervalMin.round()} min (0 = Dauerloop)',
              child: CupertinoSlider(
                min: 0, max: 30,
                value: _intervalMin,
                onChanged: (v) => setState(() => _intervalMin = v),
              ),
            ),

            const SizedBox(height: 12),
            _hintCard('Die Auswahl und Einstellungen werden automatisch gespeichert '
                'und in RC-Reminder / Night Lite+ verwendet.'),
          ],
        ),
      ),
    );
  }

  // ----------------- Aktionen -----------------

  Future<void> _pickCue() async {
    final res = await Navigator.of(context).pushNamed('/cues', arguments: {
      'picker': true,
      'selectedId': _selected?.id,
    });

    if (!mounted) return;

    if (res is CueSound) {
      setState(() => _selected = res);

      // Persistenz spiegeln (wie in der Library)
      final sp = await SharedPreferences.getInstance();
      await sp.setString(_kCueSelectedJson, jsonEncode({
        'id': res.id,
        'name': res.name,
        'category': res.category,
        'asset': res.asset,
      }));
    } else {
      await _restoreSelection();
    }
  }

  Future<void> _pickBackground() async {
    final res = await Navigator.of(context).pushNamed(
      '/cues/background',
      arguments: {'selectedAsset': _bgAsset},
    );
    if (!mounted) return;
    if (res is String && res.isNotEmpty) {
      final sp = await SharedPreferences.getInstance();
      await sp.setString(_kBgAssetV1, res);
      setState(() => _bgAsset = res);
    }
  }

  // ----------------- UI Helfer -----------------

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

// ──────────────────────────────────────────────────────────────────────────────
// Hintergrund-Auswahlseite (Route: '/cues/background') – mit Preview-Button
// ──────────────────────────────────────────────────────────────────────────────
class CueBackgroundPickerPage extends StatefulWidget {
  const CueBackgroundPickerPage({super.key});

  @override
  State<CueBackgroundPickerPage> createState() => _CueBackgroundPickerPageState();
}

class _CueBackgroundPickerPageState extends State<CueBackgroundPickerPage> {
  final _player = CueLoopPlayer.instance;

  String? _selectedAsset;
  List<String> _assets = const [];
  bool _loaded = false;
  String? _previewing; // aktuell vorhörendes Asset

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map && args['selectedAsset'] is String) {
      _selectedAsset = args['selectedAsset'] as String?;
    }
    _loadAssetsOnce();
  }

  Future<void> _loadAssetsOnce() async {
    if (_loaded) return;
    _loaded = true;
    try {
      final manifestJson = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifest = jsonDecode(manifestJson);

      final candidates = manifest.keys.where((k) {
        final lk = k.toLowerCase();
        final isAudio = lk.endsWith('.mp3') || lk.endsWith('.m4a') || lk.endsWith('.wav');
        final isMeditation = lk.contains('/meditation') || lk.contains('/soundscape') || lk.contains('/ambience');
        final isUnderAssets = lk.startsWith('assets/');
        return isAudio && isUnderAssets && isMeditation;
      }).toList()
        ..sort();

      if (mounted) setState(() => _assets = candidates);
    } catch (_) {}
  }

  @override
  void dispose() {
    _player.stop(); // Preview stoppen, falls noch aktiv
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: _bg,
      navigationBar: const CupertinoNavigationBar(
        backgroundColor: _bg,
        middle: Text('Hintergrund wählen', style: TextStyle(color: _white)),
      ),
      child: SafeArea(
        child: _assets.isEmpty
            ? const Center(child: CupertinoActivityIndicator())
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
                itemCount: _assets.length,
                itemBuilder: (_, i) {
                  final a = _assets[i];
                  final isSel = a == _selectedAsset;
                  final isPrev = a == _previewing;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: _card,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isSel ? _accent : _line, width: isSel ? 1.5 : 1),
                    ),
                    child: CupertinoListTile.notched(
                      title: Text(_nice(a), style: const TextStyle(color: _white)),
                      subtitle: Text(a, style: const TextStyle(color: _white)),
                      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                        CupertinoButton(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          onPressed: () async {
                            if (isPrev) {
                              await _player.stop();
                              if (mounted) setState(() => _previewing = null);
                              return;
                            }
                            setState(() => _previewing = a);
                            await _player.playOnceAsset(a, seconds: 5, volume: .8);
                            if (mounted && _previewing == a) setState(() => _previewing = null);
                          },
                          child: Icon(
                            isPrev ? CupertinoIcons.stop_fill : CupertinoIcons.play_fill,
                            color: _white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          isSel
                              ? CupertinoIcons.check_mark_circled_solid
                              : CupertinoIcons.chevron_right,
                          color: isSel ? _accent : _white,
                        ),
                      ]),
                      onTap: () => Navigator.of(context).pop(a),
                    ),
                  );
                },
              ),
      ),
    );
  }

  String _nice(String asset) {
    final file = asset.split('/').last;
    final base = file.contains('.') ? file.substring(0, file.lastIndexOf('.')) : file;
    return base.replaceAll(RegExp(r'[_\-]+'), ' ');
  }
}

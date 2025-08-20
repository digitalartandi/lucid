// lib/screens/account/account_settings_page.dart
import 'package:flutter/cupertino.dart';

import '../../design/gradient_theme.dart';
import '../../services/cue_prefs.dart';
import '../../services/cue_player.dart';

const _bgDark = Color(0xFF080B23);
const _white  = Color(0xFFFFFFFF);
const _muted  = Color(0xCCFFFFFF);
const _card   = Color(0x161C2A66);
const _stroke = Color(0x22FFFFFF);

class AccountSettingsPage extends StatelessWidget {
  const AccountSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: _bgDark,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: _bgDark,
        middle: const Text('Account & Einstellungen', style: TextStyle(color: _white)),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Fertig', style: TextStyle(color: _white)),
        ),
        border: const Border(bottom: BorderSide(color: _stroke, width: .5)),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: const [
            _AudioCueSection(),
            SizedBox(height: 24),
            _GradientStyleSection(),
            SizedBox(height: 24),
            _GradientResetNote(),
          ],
        ),
      ),
    );
  }
}

/// ---------- AUDIO-CUE (gewählter Cue anzeigen + Probe + Ändern) ----------
class _AudioCueSection extends StatefulWidget {
  const _AudioCueSection();

  @override
  State<_AudioCueSection> createState() => _AudioCueSectionState();
}

class _AudioCueSectionState extends State<_AudioCueSection> {
  CueConfig _cfg = const CueConfig(volume: 0.8, intervalMin: 10.0, asset: null);
  final _player = CueLoopPlayer.instance;
  bool _probing = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool toast = false}) async {
    final cfg = await CuePrefs.load();
    if (!mounted) return;
    setState(() => _cfg = cfg);

    if (toast) {
      await showCupertinoDialog(
        context: context,
        builder: (_) => CupertinoAlertDialog(
          title: const Text('Cue übernommen'),
          content: Text(_assetName),
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

  Future<void> _probe5s() async {
    if (_cfg.asset == null || _probing) return;
    setState(() => _probing = true);
    await _player.playLoop(_cfg.asset!, volume: _cfg.volume);
    await Future.delayed(const Duration(seconds: 5));
    await _player.stop();
    if (mounted) setState(() => _probing = false);
  }

  Future<void> _openCueTuning() async {
    await Navigator.of(context).pushNamed('/cuetuning');
    if (!mounted) return;
    await _load(toast: true); // nach Rückkehr sofort aktualisieren + Feedback
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
  void dispose() {
    _player.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Audio-Cue',
      child: CupertinoListSection(
        header: const Text('Audio-Cue', style: TextStyle(color: _muted)),
        backgroundColor: _card,
        children: [
          CupertinoListTile(
            title: const Text('Gewählter Cue', style: TextStyle(color: _white)),
            subtitle: Text(_assetName, style: const TextStyle(color: _muted)),
            trailing: CupertinoButton(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              onPressed: _openCueTuning,
              child: const Text('Ändern'),
            ),
          ),
          CupertinoListTile(
            title: const Text('Probe (5 Sekunden)', style: TextStyle(color: _white)),
            subtitle: const Text('Spielt den aktuellen Cue kurz an.', style: TextStyle(color: _muted)),
            trailing: CupertinoButton(
              onPressed: _probe5s,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Text(_probing ? '…' : 'Probe'),
            ),
          ),
        ],
      ),
    );
  }
}

/// ---------- FARBSTIL (Verläufe) ----------
class _GradientStyleSection extends StatelessWidget {
  const _GradientStyleSection();

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Farbstil (Verläufe)',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Farbstil (Verläufe)',
              style: TextStyle(color: _white, fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          _GradientStyleGrid(),
          const SizedBox(height: 16),
          CupertinoButton(
            color: const Color(0xFF242742),
            borderRadius: BorderRadius.circular(14),
            onPressed: () => GradientTheme.reset(),
            child: const Text('Standard wiederherstellen', style: TextStyle(color: _white)),
          ),
        ],
      ),
    );
  }
}

class _GradientStyleGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final styles = GradientStyle.values;
    return ValueListenableBuilder<GradientStyle>(
      valueListenable: GradientTheme.style,
      builder: (_, current, __) {
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final s in styles) _StyleSwatch(style: s, selected: s == current),
          ],
        );
      },
    );
  }
}

class _StyleSwatch extends StatelessWidget {
  const _StyleSwatch({required this.style, required this.selected});
  final GradientStyle style;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final g = GradientTheme.of(style);
    return GestureDetector(
      onTap: () => GradientTheme.set(style),
      child: Container(
        width: 148,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: selected ? const Color(0xFF7A6CFF) : _stroke, width: selected ? 1.5 : 1),
          color: const Color(0xFF0A0A23),
          boxShadow: const [BoxShadow(color: Color(0x66000000), blurRadius: 12, offset: Offset(0, 6))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Vorschau-Streifen
            Container(
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: g.primary,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _label(style),
              style: const TextStyle(color: _white, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              _desc(style),
              style: const TextStyle(color: _white),
            ),
          ],
        ),
      ),
    );
  }

  String _label(GradientStyle s) => switch (s) {
        GradientStyle.aurora   => 'Aurora (Standard)',
        GradientStyle.ocean    => 'Ocean',
        GradientStyle.sunset   => 'Sunset',
        GradientStyle.forest   => 'Forest',
        GradientStyle.mono     => 'Mono',
        GradientStyle.midnight => 'Midnight',
        GradientStyle.magma    => 'Magma',
        GradientStyle.glacier  => 'Glacier',
        GradientStyle.berry    => 'Berry',
        GradientStyle.cyber    => 'Cyber',
      };

  String _desc(GradientStyle s) => switch (s) {
        GradientStyle.aurora   => 'Violett + Cyan',
        GradientStyle.ocean    => 'Blau + Türkis',
        GradientStyle.sunset   => 'Warm, Abendrot',
        GradientStyle.forest   => 'Grün, erdend',
        GradientStyle.mono     => 'Dezent, einfarbig',
        GradientStyle.midnight => 'Tiefes Nachtblau',
        GradientStyle.magma    => 'Dunkelrot, Lava',
        GradientStyle.glacier  => 'Kalt, Tiefblau',
        GradientStyle.berry    => 'Beeren-Töne',
        GradientStyle.cyber    => 'Teal/Neon-inspiriert',
      };
}

/// ---------- Hinweis ----------
class _GradientResetNote extends StatelessWidget {
  const _GradientResetNote();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Hinweis: Die App bleibt dunkel. Der Farbstil passt ausschließlich die Akzent-Verläufe an.',
      style: TextStyle(color: _white),
    );
  }
}

/// ---------- Section Card Wrapper (Kontrast + Border) ----------
class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _stroke),
      ),
      padding: const EdgeInsets.all(12),
      child: child,
    );
  }
}

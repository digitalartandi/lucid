import 'package:flutter/cupertino.dart';
import '../../design/gradient_theme.dart';
import '../../services/cue_prefs.dart';
import '../../services/cue_player.dart';

const _bgDark = Color(0xFF080B23);
const _white = Color(0xFFFFFFFF);
const _stroke = Color(0x22FFFFFF);

class AccountSettingsPage extends StatelessWidget {
  const AccountSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: _bgDark,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: _bgDark,
        middle: const Text('Account & Einstellungen',
            style: TextStyle(color: _white)),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Fertig', style: TextStyle(color: _white)),
        ),
        border:
            const Border(bottom: BorderSide(color: _stroke, width: .5)),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            const Text('Farbstil (Verläufe)',
                style: TextStyle(
                    color: _white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            _GradientStyleGrid(),

            const SizedBox(height: 24),
            _SelectedCueCard(),

            const SizedBox(height: 24),
            CupertinoButton(
              color: const Color(0xFF242742),
              borderRadius: BorderRadius.circular(14),
              onPressed: () => GradientTheme.reset(),
              child: const Text('Standard wiederherstellen',
                  style: TextStyle(color: _white)),
            ),
            const SizedBox(height: 24),
            const Text(
              'Hinweis: Die App bleibt dunkel. Der Farbstil passt ausschließlich die Akzent-Verläufe an.',
              style: TextStyle(color: _white),
            ),
          ],
        ),
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
        return LayoutBuilder(builder: (_, c) {
          // 2 Spalten (klein), 3 auf Tablets+
          final maxW = c.maxWidth;
          final columns = maxW < 420 ? 2 : 3;
          final gap = 12.0;
          final w = (maxW - gap * (columns - 1)) / columns;

          return Wrap(
            spacing: gap,
            runSpacing: gap,
            children: [
              for (final s in styles)
                SizedBox(
                  width: w,
                  child: _StyleSwatch(style: s, selected: s == current),
                ),
            ],
          );
        });
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
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: selected ? const Color(0xFF7A6CFF) : _stroke,
              width: selected ? 1.5 : 1),
          color: const Color(0xFF0A0A23),
          boxShadow: const [
            BoxShadow(
                color: Color(0x66000000),
                blurRadius: 12,
                offset: Offset(0, 6))
          ],
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
                    end: Alignment.bottomRight),
              ),
            ),
            const SizedBox(height: 10),
            Text(_label(style),
                style: const TextStyle(
                    color: _white, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(_desc(style), style: const TextStyle(color: _white)),
          ],
        ),
      ),
    );
  }

  String _label(GradientStyle s) => switch (s) {
        GradientStyle.aurora => 'Aurora (Standard)',
        GradientStyle.ocean => 'Ocean',
        GradientStyle.sunset => 'Sunset',
        GradientStyle.forest => 'Forest',
        GradientStyle.mono => 'Mono',
        GradientStyle.midnight => 'Midnight',
        GradientStyle.magma => 'Magma',
        GradientStyle.glacier => 'Glacier',
        GradientStyle.berry => 'Berry',
        GradientStyle.cyber => 'Cyber',
      };

  String _desc(GradientStyle s) => switch (s) {
        GradientStyle.aurora => 'Violett → Cyan',
        GradientStyle.ocean => 'Blau → Türkis',
        GradientStyle.sunset => 'Orange → Pink',
        GradientStyle.forest => 'Moosgrün → Mint',
        GradientStyle.mono => 'Dunkelgrau → Eisblau',
        GradientStyle.midnight => 'Nachtblau → Lila',
        GradientStyle.magma => 'Rotbraun → Lava',
        GradientStyle.glacier => 'Eisblau → Tiefblau',
        GradientStyle.berry => 'Pink → Violett',
        GradientStyle.cyber => 'Teal → Neon',
      };
}

class _SelectedCueCard extends StatelessWidget {
  final _player = CueLoopPlayer.instance;

  _SelectedCueCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: CuePrefs.selection,
      builder: (_, sel, __) {
        final name = sel?.name ?? 'Kein Cue gewählt';
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF0A0A23),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _stroke),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Gewählter Cue',
                        style: TextStyle(
                            color: _white, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    Text(name, style: const TextStyle(color: _white)),
                  ],
                ),
              ),
              CupertinoButton(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                color: const Color(0x1AFFFFFF),
                borderRadius: BorderRadius.circular(10),
                onPressed: sel == null
                    ? null
                    : () => _player.playOnceAsset(sel.asset,
                        seconds: 5, volume: .8),
                child: const Text('Probe',
                    style: TextStyle(color: _white)),
              )
            ],
          ),
        );
      },
    );
  }
}

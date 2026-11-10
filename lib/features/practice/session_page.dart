// lib/features/practice/session_page.dart
//
// Geführte Übung: ein Schritt pro Bildschirm, ruhiger Atemring,
// optional im roten Nachtstil.
import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/cupertino.dart';

import '../../core/practice_store.dart';
import '../../core/sessions.dart';
import '../../services/cue_player.dart';
import '../../ui/tokens.dart';
import '../../ui/widgets.dart';

class SessionPage extends StatefulWidget {
  const SessionPage({super.key, required this.id, this.night = false});

  final String id;

  /// Roter, sehr dunkler Stil für die Nacht.
  final bool night;

  @override
  State<SessionPage> createState() => _SessionPageState();
}

class _SessionPageState extends State<SessionPage> with SingleTickerProviderStateMixin {
  static const String _chimeAsset = 'assets/audio/cues/soft-chim.mp3';

  late final SessionScript? _script = sessionById(widget.id);
  late final AnimationController _breath = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 10),
  );

  int _index = -1; // -1 Einleitung, steps.length Abschluss
  int _remaining = 0;
  Timer? _timer;
  bool _sound = true;

  Color get _bg => widget.night ? LC.redBg : LC.night;
  Color get _fg => widget.night ? LC.redText : LC.text;
  Color get _dim => widget.night ? LC.redDim : LC.muted;
  Color get _accent => widget.night ? LC.redText : LC.iris;

  @override
  void initState() {
    super.initState();
    _breath.repeat();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _breath.dispose();
    super.dispose();
  }

  String _fill(String text) =>
      text.replaceAll('{intention}', PracticeStore.instance.profile.intention);

  void _enter(int i) {
    _timer?.cancel();
    final SessionScript s = _script!;
    if (i >= s.steps.length) {
      setState(() => _index = s.steps.length);
      _complete();
      return;
    }
    final SessionStep step = s.steps[i];
    setState(() {
      _index = i;
      _remaining = step.seconds;
    });
    if (step.chime && _sound) {
      CueLoopPlayer.instance
          .playOnceAsset(_chimeAsset, seconds: 3, volume: widget.night ? 0.12 : 0.25)
          .catchError((Object _) {});
    }
    if (step.seconds > 0) {
      _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
        if (!mounted) {
          t.cancel();
          return;
        }
        if (_remaining <= 1) {
          t.cancel();
          _enter(_index + 1);
        } else {
          setState(() => _remaining -= 1);
        }
      });
    }
  }

  Future<void> _complete() async {
    final String? tech = _script?.techniqueId;
    final PracticeStore store = PracticeStore.instance;
    if (tech == 'rc') {
      await store.addRealityCheck();
    } else if (tech != null && tech != 'journal') {
      await store.addTechnique(tech);
    }
  }

  @override
  Widget build(BuildContext context) {
    final SessionScript? s = _script;
    if (s == null) {
      return const LPage(
        title: 'Übung',
        child: LEmpty(
          icon: CupertinoIcons.question_circle,
          title: 'Nicht gefunden',
          text: 'Diese Übung gibt es nicht.',
        ),
      );
    }
    final bool intro = _index < 0;
    final bool finished = _index >= s.steps.length;
    final SessionStep? step = (!intro && !finished) ? s.steps[_index] : null;

    return CupertinoPageScaffold(
      backgroundColor: _bg,
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: LS.maxWidth),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(LS.page, LS.md, LS.page, LS.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      LTap(
                        onTap: () => Navigator.of(context).maybePop(),
                        semanticLabel: 'Schließen',
                        child: Padding(
                          padding: const EdgeInsets.all(LS.sm),
                          child: Icon(CupertinoIcons.xmark, color: _dim, size: 22),
                        ),
                      ),
                      const SizedBox(width: LS.sm),
                      Expanded(
                        child: _Dots(
                          count: s.steps.length,
                          index: _index,
                          on: _accent,
                          off: widget.night ? LC.redLine : LC.line,
                          dense: s.steps.length > 8,
                        ),
                      ),
                      if (s.eyesClosed) ...<Widget>[
                        const SizedBox(width: LS.sm),
                        LTap(
                          onTap: () => setState(() => _sound = !_sound),
                          semanticLabel: _sound ? 'Ton aus' : 'Ton an',
                          child: Padding(
                            padding: const EdgeInsets.all(LS.sm),
                            child: Icon(
                              _sound ? CupertinoIcons.speaker_2 : CupertinoIcons.speaker_slash,
                              color: _dim,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        AnimatedBuilder(
                          animation: _breath,
                          builder: (BuildContext context, Widget? _) {
                            // 4 s ein, 6 s aus.
                            final double t = _breath.value;
                            final double phase = t < 0.4 ? t / 0.4 : 1 - (t - 0.4) / 0.6;
                            final double eased = 0.5 - 0.5 * math.cos(phase * math.pi);
                            final double size = 120 + 60 * eased;
                            return SizedBox(
                              height: 190,
                              child: Center(
                                child: Container(
                                  width: size,
                                  height: size,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _accent.withValues(alpha: 0.10 + 0.10 * eased),
                                    border: Border.all(color: _accent.withValues(alpha: 0.55), width: 1.5),
                                  ),
                                  child: step != null && step.seconds > 0
                                      ? Text('$_remaining', style: LT.number.copyWith(color: _fg))
                                      : null,
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: LS.xl),
                        Text(
                          intro ? s.title : (finished ? 'Geschafft' : step!.title),
                          style: LT.display.copyWith(color: _fg, fontSize: 32),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: LS.md),
                        Text(
                          intro ? s.intro : (finished ? s.closing : _fill(step!.text)),
                          style: LT.body.copyWith(color: widget.night ? LC.redText : LC.muted, fontSize: 17),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  if (intro)
                    _SessionButton(
                      label: 'Beginnen',
                      night: widget.night,
                      onPressed: () => _enter(0),
                    )
                  else if (finished)
                    _SessionButton(
                      label: widget.night ? 'Schlafen' : 'Fertig',
                      night: widget.night,
                      onPressed: () => Navigator.of(context).maybePop(true),
                    )
                  else
                    _SessionButton(
                      label: step!.seconds > 0 ? 'Überspringen' : 'Weiter',
                      night: widget.night,
                      quiet: step.seconds > 0,
                      onPressed: () => _enter(_index + 1),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SessionButton extends StatelessWidget {
  const _SessionButton({
    required this.label,
    required this.night,
    required this.onPressed,
    this.quiet = false,
  });

  final String label;
  final bool night;
  final bool quiet;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    if (!night) {
      return LButton(
        label: label,
        kind: quiet ? LButtonKind.quiet : LButtonKind.primary,
        onPressed: onPressed,
      );
    }
    return LTap(
      onTap: onPressed,
      child: Container(
        constraints: const BoxConstraints(minHeight: 52),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: LRad.md,
          border: Border.all(color: LC.redDim),
          color: quiet ? LC.transparent : LC.redLine,
        ),
        child: Text(label, style: LT.heading.copyWith(color: LC.redText, fontSize: 16)),
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots({
    required this.count,
    required this.index,
    required this.on,
    required this.off,
    this.dense = false,
  });

  final int count;
  final int index;
  final Color on;
  final Color off;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        for (int i = 0; i < count; i++)
          Expanded(
            child: Container(
              height: 3,
              margin: EdgeInsets.symmetric(horizontal: dense ? 1 : 2),
              decoration: BoxDecoration(
                color: i <= index ? on : off,
                borderRadius: LRad.pill,
              ),
            ),
          ),
      ],
    );
  }
}

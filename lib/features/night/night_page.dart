// lib/features/night/night_page.dart
//
// Nachtmodus: Einrichtung, Schlafansicht, Wachphase, Klangsignale.
// Web: Die App muss geöffnet bleiben; der Bildschirm wird wach gehalten
// und fast schwarz dargestellt.
import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/night_plan.dart';
import '../../core/practice_store.dart';
import '../../models/journal_models.dart';
import '../../platform/wake_lock.dart';
import '../../services/cue_player.dart';
import '../../services/journal_repo.dart';
import '../../ui/tokens.dart';
import '../../ui/widgets.dart';
import '../practice/session_page.dart';
import '../shell/app_shell.dart';

const String _kCueSelectedJson = 'cue.selected.v1';

class _Cue {
  const _Cue(this.name, this.asset);
  final String name;
  final String asset;
}

Future<_Cue> _loadCue() async {
  try {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    final String? raw = sp.getString(_kCueSelectedJson);
    if (raw != null) {
      final Map<String, dynamic> m = jsonDecode(raw) as Map<String, dynamic>;
      final String asset = (m['asset'] ?? '') as String;
      if (asset.isNotEmpty) {
        return _Cue((m['name'] ?? 'Eigener Ton') as String, asset);
      }
    }
  } catch (_) {
    // Standardton verwenden.
  }
  return const _Cue('Sanfter Glockenton', NightConfig.defaultCueAsset);
}

String _clock(DateTime d) => hhmm(d.hour, d.minute);

// ---------------------------------------------------------------- Einrichtung

class NightSetupPage extends StatefulWidget {
  const NightSetupPage({super.key});

  @override
  State<NightSetupPage> createState() => _NightSetupPageState();
}

class _NightSetupPageState extends State<NightSetupPage> {
  final PracticeStore _store = PracticeStore.instance;

  late bool _wbtb = !_store.profile.lightSleeper;
  int _wbtbAfter = 330;
  String _technique = 'mild';
  bool _cues = false;
  int _cuesAfter = 360;
  int _cueInterval = 5;
  double _alarmVol = 0.5;
  double _cueVol = 0.15;
  _Cue _cue = const _Cue('Sanfter Glockenton', NightConfig.defaultCueAsset);

  @override
  void initState() {
    super.initState();
    _loadCue().then((_Cue c) {
      if (mounted) setState(() => _cue = c);
    });
  }

  @override
  void dispose() {
    CueLoopPlayer.instance.stop();
    super.dispose();
  }

  Future<void> _pickCue() async {
    await Navigator.of(context).pushNamed<Object?>(
      '/cues',
      arguments: <String, Object?>{'picker': true},
    );
    final _Cue c = await _loadCue();
    if (mounted) setState(() => _cue = c);
  }

  void _probe(double volume) {
    CueLoopPlayer.instance
        .playOnceAsset(_cue.asset, seconds: 4, volume: volume)
        .catchError((Object _) {});
  }

  Future<void> _start() async {
    final NightConfig config = NightConfig(
      start: DateTime.now(),
      wbtb: _wbtb,
      wbtbAfterMinutes: _wbtbAfter,
      technique: _technique,
      cues: _cues,
      cuesAfterMinutes: _cuesAfter,
      cueIntervalMinutes: _cueInterval,
      alarmVolume: _alarmVol,
      cueVolume: _cueVol,
      cueAsset: _cue.asset,
    );
    // Ein hörbarer Ton nach dem Tippen: bestätigt die Lautstärke und erlaubt
    // dem Browser, später ohne weitere Eingabe Töne abzuspielen.
    _probe(_cues ? _cueVol : 0.2);
    await Navigator.of(context).pushReplacement<void, void>(
      CupertinoPageRoute<void>(builder: (_) => NightRunPage(config: config)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();
    final int week = _store.wbtbNightsInLast(7);
    final bool nothing = !_wbtb && !_cues;
    return LPage(
      title: 'Nachtmodus',
      leading: LTap(
        onTap: () => Navigator.of(context).maybePop(),
        semanticLabel: 'Schließen',
        child: const Icon(CupertinoIcons.xmark, color: LC.muted, size: 22),
      ),
      child: LScroll(
        children: <Widget>[
          Text('Heute Nacht', style: LT.display),
          const SizedBox(height: LS.sm),
          Text(
            'Richte die Nacht ein, wenn du im Bett liegst. Die Zeiten zählen ab jetzt.',
            style: LT.bodyMuted,
          ),
          if (week >= 3) ...<Widget>[
            const SizedBox(height: LS.lg),
            LNote(
              tone: LC.rose,
              icon: CupertinoIcons.exclamationmark_triangle,
              text: 'In den letzten sieben Tagen hattest du schon $week Nächte mit Wachphase. Mehr als drei pro Woche gehen auf Kosten des Schlafs.',
            ),
          ],
          const LSection('Wachphase'),
          LCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text('Nachts kurz wecken', style: LT.heading.copyWith(fontSize: 16)),
                          const SizedBox(height: 2),
                          Text('Traum notieren, Technik, weiterschlafen', style: LT.labelMuted),
                        ],
                      ),
                    ),
                    LSwitch(value: _wbtb, onChanged: (bool v) => setState(() => _wbtb = v)),
                  ],
                ),
                if (_wbtb) ...<Widget>[
                  const SizedBox(height: LS.lg),
                  Text('Wecken nach', style: LT.labelMuted),
                  const SizedBox(height: LS.sm),
                  Wrap(
                    spacing: LS.sm,
                    runSpacing: LS.sm,
                    children: <Widget>[
                      for (final int m in const <int>[300, 330, 360])
                        LChip(
                          label: '${m ~/ 60}${m % 60 == 0 ? '' : ',5'} Std.',
                          selected: _wbtbAfter == m,
                          onTap: () => setState(() => _wbtbAfter = m),
                        ),
                    ],
                  ),
                  const SizedBox(height: LS.sm),
                  Text(
                    'Wecksignal gegen ${_clock(now.add(Duration(minutes: _wbtbAfter)))} Uhr. Im Schlaflabor wirkte die Wachphase nach sechs Stunden besser als nach viereinhalb.',
                    style: LT.caption,
                  ),
                  const SizedBox(height: LS.lg),
                  Text('Technik danach', style: LT.labelMuted),
                  const SizedBox(height: LS.sm),
                  Wrap(
                    spacing: LS.sm,
                    children: <Widget>[
                      LChip(
                        label: 'MILD',
                        selected: _technique == 'mild',
                        onTap: () => setState(() => _technique = 'mild'),
                      ),
                      LChip(
                        label: 'SSILD',
                        selected: _technique == 'ssild',
                        onTap: () => setState(() => _technique = 'ssild'),
                      ),
                    ],
                  ),
                  const SizedBox(height: LS.lg),
                  _VolumeRow(
                    label: 'Lautstärke Wecksignal',
                    value: _alarmVol,
                    onChanged: (double v) => setState(() => _alarmVol = v),
                    onProbe: () => _probe(_alarmVol),
                  ),
                ],
              ],
            ),
          ),
          const LSection('Klangsignale'),
          LCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Flexible(
                                child: Text('Leise Töne am Morgen', style: LT.heading.copyWith(fontSize: 16)),
                              ),
                              const SizedBox(width: LS.sm),
                              const LBadge('Experimentell'),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text('Erinnern im Traum an deine Absicht', style: LT.labelMuted),
                        ],
                      ),
                    ),
                    LSwitch(value: _cues, onChanged: (bool v) => setState(() => _cues = v)),
                  ],
                ),
                if (_cues) ...<Widget>[
                  const SizedBox(height: LS.lg),
                  LNote(
                    text:
                        'Die Töne wirken nur, wenn du sie vorher mit wacher Aufmerksamkeit verknüpft hast. Mach das Training direkt vor dem Einschlafen.',
                    icon: CupertinoIcons.bell,
                  ),
                  const SizedBox(height: LS.md),
                  LButton(
                    label: 'Training starten (etwa 9 Min.)',
                    kind: LButtonKind.secondary,
                    onPressed: () => Navigator.of(context).push<void>(
                      CupertinoPageRoute<void>(
                        builder: (_) => TlrTrainingPage(cueAsset: _cue.asset, volume: _cueVol),
                      ),
                    ),
                  ),
                  const SizedBox(height: LS.lg),
                  Text('Erster Ton nach', style: LT.labelMuted),
                  const SizedBox(height: LS.sm),
                  Wrap(
                    spacing: LS.sm,
                    runSpacing: LS.sm,
                    children: <Widget>[
                      for (final int m in const <int>[330, 360, 390, 420])
                        LChip(
                          label: '${m ~/ 60}${m % 60 == 0 ? '' : ',5'} Std.',
                          selected: _cuesAfter == m,
                          onTap: () => setState(() => _cuesAfter = m),
                        ),
                    ],
                  ),
                  const SizedBox(height: LS.lg),
                  Text('Abstand zwischen den Tönen', style: LT.labelMuted),
                  const SizedBox(height: LS.sm),
                  Wrap(
                    spacing: LS.sm,
                    runSpacing: LS.sm,
                    children: <Widget>[
                      for (final int m in const <int>[3, 5, 10])
                        LChip(
                          label: '$m Min.',
                          selected: _cueInterval == m,
                          onTap: () => setState(() => _cueInterval = m),
                        ),
                    ],
                  ),
                  const SizedBox(height: LS.lg),
                  _VolumeRow(
                    label: 'Lautstärke Klangsignal',
                    value: _cueVol,
                    max: 0.5,
                    onChanged: (double v) => setState(() => _cueVol = v),
                    onProbe: () => _probe(_cueVol),
                  ),
                  const SizedBox(height: LS.sm),
                  Text(
                    'So leise, dass du den Ton im stillen Raum gerade noch hörst. Die Töne laufen 90 Minuten lang und werden nur langsam lauter.',
                    style: LT.caption,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: LS.lg),
          LGroup(
            children: <Widget>[
              LRow(
                icon: CupertinoIcons.music_note_2,
                title: 'Ton',
                subtitle: _cue.name,
                onTap: _pickCue,
              ),
            ],
          ),
          const SizedBox(height: LS.lg),
          LNote(
            text: wakeLockSupported
                ? 'Lass die App geöffnet und häng das Gerät ans Ladekabel. Der Bildschirm bleibt an und wird fast schwarz. Schalte Benachrichtigungen stumm.'
                : 'Lass die App im Vordergrund und häng das Gerät ans Ladekabel. Stell die automatische Bildschirmsperre für heute Nacht aus, sonst kann die App dich nicht wecken.',
          ),
          const SizedBox(height: LS.xl),
          LButton(
            label: nothing ? 'Wähle Wachphase oder Klangsignale' : 'Nacht beginnen',
            icon: nothing ? null : CupertinoIcons.moon_zzz,
            onPressed: nothing ? null : _start,
          ),
        ],
      ),
    );
  }
}

class _VolumeRow extends StatelessWidget {
  const _VolumeRow({
    required this.label,
    required this.value,
    required this.onChanged,
    required this.onProbe,
    this.max = 1.0,
  });

  final String label;
  final double value;
  final double max;
  final ValueChanged<double> onChanged;
  final VoidCallback onProbe;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(label, style: LT.labelMuted),
        Row(
          children: <Widget>[
            Expanded(
              child: CupertinoSlider(
                value: value.clamp(0.02, max).toDouble(),
                min: 0.02,
                max: max,
                activeColor: LC.iris,
                onChanged: onChanged,
              ),
            ),
            const SizedBox(width: LS.sm),
            LTap(
              onTap: onProbe,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: LS.sm, vertical: LS.sm),
                child: Text('Anhören', style: LT.label.copyWith(color: LC.iris)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// -------------------------------------------------------------- Klang-Training

/// Verknüpft den Ton vor dem Einschlafen mit wacher, prüfender Aufmerksamkeit
/// (angelehnt an das Vorgehen bei Targeted Lucidity Reactivation).
class TlrTrainingPage extends StatefulWidget {
  const TlrTrainingPage({super.key, required this.cueAsset, required this.volume});

  final String cueAsset;
  final double volume;

  @override
  State<TlrTrainingPage> createState() => _TlrTrainingPageState();
}

class _TlrTrainingPageState extends State<TlrTrainingPage> {
  static const int _total = 10;
  static const List<String> _guided = <String>[
    'Du hörst gleich einen Ton. Jedes Mal, wenn er erklingt: werde wach und aufmerksam.',
    'Ton. Achte auf deine Gedanken. Was geht dir gerade durch den Kopf?',
    'Ton. Spür deinen Körper. Wo liegt er auf? Wie fühlt er sich an?',
    'Ton. Achte auf den Atem. Und frag dich: Träume ich gerade?',
  ];
  // Abstände in Sekunden: erst kurz und angeleitet, dann länger.
  static const List<int> _gaps = <int>[40, 40, 40, 45, 55, 70, 60, 80, 65, 0];

  int _played = 0;
  bool _done = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 8), _next);
  }

  void _next() {
    if (!mounted) return;
    if (_played >= _total) {
      setState(() => _done = true);
      PracticeStore.instance.addTechnique('tlr');
      return;
    }
    CueLoopPlayer.instance
        .playOnceAsset(widget.cueAsset, seconds: 4, volume: widget.volume)
        .catchError((Object _) {});
    final int gap = _gaps[_played];
    setState(() => _played += 1);
    _timer = Timer(Duration(seconds: gap > 0 ? gap : 6), _next);
  }

  @override
  void dispose() {
    _timer?.cancel();
    CueLoopPlayer.instance.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String text = _done
        ? 'Die Verknüpfung steht. Schlaf jetzt ein. Hörst du den Ton später im Traum, weißt du, was er bedeutet.'
        : (_played < _guided.length
            ? _guided[_played]
            : 'Bei jedem Ton: kurz wach werden, Gedanken, Körper, Atem prüfen. Träume ich? Du darfst dabei einschlafen.');
    return CupertinoPageScaffold(
      backgroundColor: LC.redBg,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(LS.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Align(
                alignment: Alignment.centerLeft,
                child: LTap(
                  onTap: () => Navigator.of(context).maybePop(),
                  semanticLabel: 'Schließen',
                  child: const Icon(CupertinoIcons.xmark, color: LC.redDim, size: 22),
                ),
              ),
              const Spacer(),
              Text(
                _done ? 'Training beendet' : 'Ton $_played von $_total',
                style: LT.label.copyWith(color: LC.redDim),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: LS.lg),
              Text(
                text,
                style: LT.title.copyWith(color: LC.redText, fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              if (_done)
                LTap(
                  onTap: () => Navigator.of(context).maybePop(),
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 52),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: LRad.md,
                      border: Border.all(color: LC.redDim),
                    ),
                    child: Text('Zurück', style: LT.heading.copyWith(color: LC.redText, fontSize: 16)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ------------------------------------------------------------------- Die Nacht

enum _NightPhase { sleeping, alarm, awake, morning }

class NightRunPage extends StatefulWidget {
  const NightRunPage({super.key, required this.config});
  final NightConfig config;

  @override
  State<NightRunPage> createState() => _NightRunPageState();
}

class _NightRunPageState extends State<NightRunPage> with WidgetsBindingObserver {
  final CueLoopPlayer _player = CueLoopPlayer.instance;
  final TextEditingController _note = TextEditingController();

  _NightPhase _phase = _NightPhase.sleeping;
  Timer? _tick;
  bool _wbtbDone = false;
  bool _wakeLock = false;

  DateTime? _alarmSince;
  DateTime? _lastAlarmTone;
  DateTime? _awakeSince;

  DateTime? _lastCue;
  DateTime? _cuesEarliest;
  DateTime? _cuesPausedUntil;
  int _cueCount = 0;
  late double _cueBase = widget.config.cueVolume;

  NightConfig get _c => widget.config;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _acquire();
    _tick = Timer.periodic(const Duration(seconds: 5), (_) => _onTick());
  }

  Future<void> _acquire() async {
    final bool ok = await acquireWakeLock();
    if (mounted) setState(() => _wakeLock = ok);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _acquire();
      _onTick();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tick?.cancel();
    _player.stop();
    releaseWakeLock();
    _note.dispose();
    super.dispose();
  }

  void _onTick() {
    if (!mounted) return;
    final DateTime now = DateTime.now();
    switch (_phase) {
      case _NightPhase.sleeping:
        final DateTime? wbtbAt = _c.wbtbAt;
        if (!_wbtbDone && wbtbAt != null && !now.isBefore(wbtbAt)) {
          setState(() {
            _phase = _NightPhase.alarm;
            _alarmSince = now;
            _lastAlarmTone = null;
          });
          _alarmTone(now);
          return;
        }
        if (cueDue(
          config: _c,
          now: now,
          lastCue: _lastCue,
          earliest: _cuesEarliest,
          pausedUntil: _cuesPausedUntil,
        )) {
          _player
              .playOnceAsset(_c.cueAsset, seconds: 4, volume: cueVolumeAt(_cueCount, _cueBase))
              .catchError((Object _) {});
          _lastCue = now;
          _cueCount += 1;
        }
        break;
      case _NightPhase.alarm:
        _alarmTone(now);
        break;
      case _NightPhase.awake:
        setState(() {}); // Wachzeit-Anzeige aktualisieren
        break;
      case _NightPhase.morning:
        break;
    }
  }

  void _alarmTone(DateTime now) {
    final DateTime since = _alarmSince ?? now;
    if (_lastAlarmTone != null && now.difference(_lastAlarmTone!).inSeconds < 9) return;
    _lastAlarmTone = now;
    _player
        .playOnceAsset(
          _c.cueAsset,
          seconds: 6,
          volume: alarmVolumeAt(now.difference(since).inSeconds, _c.alarmVolume),
        )
        .catchError((Object _) {});
  }

  void _stopAlarm() {
    _player.stop();
    setState(() {
      _phase = _NightPhase.awake;
      _awakeSince = DateTime.now();
      _wbtbDone = true;
    });
    PracticeStore.instance.addTechnique('wbtb');
  }

  Future<void> _saveNote() async {
    final String text = _note.text.trim();
    if (text.isEmpty) return;
    final JournalEntry draft = JournalEntry.newDraft().copyWith(
      title: 'Notiz aus der Nacht',
      body: text,
      technique: _c.technique,
    );
    await JournalRepo.instance.upsert(draft);
    _note.clear();
  }

  Future<void> _backToSleep({required bool withTechnique}) async {
    await _saveNote();
    if (withTechnique && mounted) {
      await Navigator.of(context).push<Object?>(
        CupertinoPageRoute<Object?>(
          builder: (_) => SessionPage(id: _c.technique, night: true),
        ),
      );
    }
    if (!mounted) return;
    setState(() {
      _phase = _NightPhase.sleeping;
      // Erst wieder einschlafen lassen, bevor Töne beginnen.
      _cuesEarliest = DateTime.now().add(const Duration(minutes: 20));
    });
  }

  void _cueWokeMe() {
    _player.stop();
    setState(() {
      _cuesPausedUntil = DateTime.now().add(const Duration(minutes: 45));
      _cueBase = _cueBase * 0.7;
      _cueCount = 0;
    });
  }

  Future<void> _end() async {
    _player.stop();
    setState(() => _phase = _NightPhase.morning);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _phase == _NightPhase.morning,
      child: CupertinoPageScaffold(
        backgroundColor: LC.redBg,
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: LS.maxWidth),
              child: Padding(
                padding: const EdgeInsets.all(LS.xl),
                child: switch (_phase) {
                  _NightPhase.sleeping => _sleeping(),
                  _NightPhase.alarm => _alarm(),
                  _NightPhase.awake => _awake(),
                  _NightPhase.morning => _morning(),
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _redButton(String label, VoidCallback onTap, {bool filled = false}) {
    return LTap(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 54),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: LS.lg),
        decoration: BoxDecoration(
          borderRadius: LRad.md,
          color: filled ? LC.redLine : LC.transparent,
          border: Border.all(color: LC.redDim),
        ),
        child: Text(label, style: LT.heading.copyWith(color: LC.redText, fontSize: 16), textAlign: TextAlign.center),
      ),
    );
  }

  Widget _sleeping() {
    final DateTime now = DateTime.now();
    final DateTime? wbtbAt = _c.wbtbAt;
    final DateTime? from = _c.cuesFrom;
    final DateTime? until = _c.cuesUntil;
    final List<String> lines = <String>[
      if (!_wbtbDone && wbtbAt != null) 'Wecksignal gegen ${_clock(wbtbAt)} Uhr',
      if (from != null && until != null && now.isBefore(until))
        (_cuesPausedUntil != null && now.isBefore(_cuesPausedUntil!))
            ? 'Klangsignale pausiert bis ${_clock(_cuesPausedUntil!)} Uhr'
            : 'Klangsignale ${_clock(from)} bis ${_clock(until)} Uhr',
    ];
    final bool cuesActive = from != null && until != null && !now.isBefore(from) && now.isBefore(until);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const Spacer(),
        const Icon(CupertinoIcons.moon_zzz, color: LC.redDim, size: 40),
        const SizedBox(height: LS.lg),
        Text('Schlaf gut', style: LT.title.copyWith(color: LC.redDim), textAlign: TextAlign.center),
        const SizedBox(height: LS.md),
        for (final String l in lines)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(l, style: LT.label.copyWith(color: LC.redDim), textAlign: TextAlign.center),
          ),
        if (!_wakeLock) ...<Widget>[
          const SizedBox(height: LS.md),
          Text(
            'Der Bildschirm kann hier nicht wach gehalten werden. Bitte die automatische Sperre ausschalten.',
            style: LT.caption.copyWith(color: LC.redDim),
            textAlign: TextAlign.center,
          ),
        ],
        const Spacer(),
        if (cuesActive) ...<Widget>[
          _redButton('Ein Ton hat mich geweckt', _cueWokeMe),
          const SizedBox(height: LS.md),
        ],
        _redButton('Nacht beenden', _end),
      ],
    );
  }

  Widget _alarm() {
    return LTap(
      onTap: _stopAlarm,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const Spacer(),
          const Icon(CupertinoIcons.alarm, color: LC.redText, size: 48),
          const SizedBox(height: LS.lg),
          Text('Zeit für die Wachphase',
              style: LT.display.copyWith(color: LC.redText, fontSize: 32), textAlign: TextAlign.center),
          const SizedBox(height: LS.md),
          Text('Bleib kurz still liegen. Was hast du gerade geträumt?',
              style: LT.body.copyWith(color: LC.redText), textAlign: TextAlign.center),
          const Spacer(),
          _redButton('Ich bin wach', _stopAlarm, filled: true),
        ],
      ),
    );
  }

  Widget _awake() {
    final int mins = _awakeSince == null ? 0 : DateTime.now().difference(_awakeSince!).inMinutes;
    final String tech = _c.technique == 'ssild' ? 'SSILD' : 'MILD';
    final TextStyle body = LT.body.copyWith(color: LC.redText, fontSize: 15.5);
    return ListView(
      children: <Widget>[
        Text('Wachphase', style: LT.display.copyWith(color: LC.redText, fontSize: 32)),
        const SizedBox(height: LS.xs),
        Text(
          mins < 1 ? 'Gerade aufgewacht' : 'Seit $mins Min. wach. 10 bis 30 Minuten genügen.',
          style: LT.label.copyWith(color: LC.redDim),
        ),
        const SizedBox(height: LS.xl),
        Text('1  Traum notieren', style: LT.heading.copyWith(color: LC.redText)),
        const SizedBox(height: LS.sm),
        CupertinoTextField(
          controller: _note,
          maxLines: 5,
          minLines: 3,
          placeholder: 'Stichworte: Ort, Personen, Seltsames',
          placeholderStyle: body.copyWith(color: LC.redDim),
          style: body,
          cursorColor: LC.redText,
          textCapitalization: TextCapitalization.sentences,
          padding: const EdgeInsets.all(LS.lg),
          decoration: BoxDecoration(
            color: LC.redBg,
            borderRadius: LRad.md,
            border: Border.all(color: LC.redLine),
          ),
        ),
        const SizedBox(height: LS.xl),
        Text('2  Absicht erinnern', style: LT.heading.copyWith(color: LC.redText)),
        const SizedBox(height: LS.sm),
        Text('„${PracticeStore.instance.profile.intention}“', style: body),
        const SizedBox(height: LS.xl),
        Text('3  Zurück ins Bett mit $tech', style: LT.heading.copyWith(color: LC.redText)),
        const SizedBox(height: LS.sm),
        Text(
          'Kein helles Licht, kein Scrollen. Wenn du schon müde bist, geh gleich weiter.',
          style: body.copyWith(color: LC.redDim),
        ),
        const SizedBox(height: LS.xl),
        _redButton('$tech starten und weiterschlafen', () => _backToSleep(withTechnique: true), filled: true),
        const SizedBox(height: LS.md),
        _redButton('Ohne Übung weiterschlafen', () => _backToSleep(withTechnique: false)),
        const SizedBox(height: LS.md),
        _redButton('Nacht beenden', () async {
          await _saveNote();
          await _end();
        }),
      ],
    );
  }

  Widget _morning() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const Spacer(),
        const Icon(CupertinoIcons.sunrise, color: LC.moon, size: 44),
        const SizedBox(height: LS.lg),
        Text('Guten Morgen', style: LT.display.copyWith(color: LC.text), textAlign: TextAlign.center),
        const SizedBox(height: LS.md),
        Text(
          'Bevor du aufstehst: Was hast du geträumt? Auch Bruchstücke zählen.',
          style: LT.bodyMuted,
          textAlign: TextAlign.center,
        ),
        const Spacer(),
        LButton(
          label: 'Traum notieren',
          kind: LButtonKind.moon,
          icon: CupertinoIcons.pencil,
          onPressed: () {
            final NavigatorState nav = Navigator.of(context);
            nav.pop();
            AppShell.goTo(AppShell.tabJournal);
            nav.pushNamed<Object?>('/journal/new');
          },
        ),
        const SizedBox(height: LS.sm),
        LButton(
          label: 'Schließen',
          kind: LButtonKind.quiet,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}

// lib/screens/meditation/meditation_player_page.dart
import 'package:flutter/cupertino.dart';
import 'package:just_audio/just_audio.dart';
import '../../design/gradient_theme.dart';
import '../../models/meditation_models.dart';
import '../../services/meditation_repo.dart';

const _bg = Color(0xFF080B23);
const _white = Color(0xFFFFFFFF);
const _stroke = Color(0x22FFFFFF);

class MeditationPlayerPage extends StatefulWidget {
  final String id;
  const MeditationPlayerPage({super.key, required this.id});

  @override
  State<MeditationPlayerPage> createState() => _MeditationPlayerPageState();
}

class _MeditationPlayerPageState extends State<MeditationPlayerPage> {
  final _player = AudioPlayer();
  MeditationTrack? _t;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      _t = await MeditationRepo.instance.byId(widget.id);
      if (_t == null) return;

      // *** WICHTIG: Web-sichere Asset-Zuweisung ***
      // statt 'asset://...' immer AudioSource.asset() benutzen
      await _player.setAudioSource(AudioSource.asset(_t!.asset));

      await _player.setLoopMode(LoopMode.one);
      await _player.setVolume(.8);
      await _player.play();
      if (mounted) setState(() {});
    } catch (_) {
      // stille Fehler – UI bleibt erhalten
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final g = GradientTheme.of(GradientTheme.style.value).primary;
    final t = _t;
    return CupertinoPageScaffold(
      backgroundColor: _bg,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: _bg,
        middle: Text(t?.title ?? 'Sound', style: const TextStyle(color: _white)),
        border: const Border(bottom: BorderSide(color: _stroke, width: .5)),
      ),
      child: t == null
          ? const Center(child: CupertinoActivityIndicator())
          : SafeArea(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                children: [
                  Container(
                    height: 280,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _stroke),
                      boxShadow: const [
                        BoxShadow(
                            color: Color(0x66000000),
                            blurRadius: 16,
                            offset: Offset(0, 8))
                      ],
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: t.cover.isNotEmpty
                        ? Image.asset(t.cover, fit: BoxFit.cover)
                        : DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: g,
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                          ),
                  ),
                  const SizedBox(height: 16),
                  Text(t.title,
                      style: const TextStyle(
                          color: _white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text(t.category, style: const TextStyle(color: _white)),
                  const SizedBox(height: 16),

                  // Transport
                  StreamBuilder<PlayerState>(
                    stream: _player.playerStateStream,
                    builder: (_, snap) {
                      final playing = snap.data?.playing ?? false;
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CupertinoButton(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            onPressed: () => _player.seek(Duration.zero),
                            child: const Icon(CupertinoIcons.gobackward,
                                color: _white, size: 28),
                          ),
                          const SizedBox(width: 6),
                          CupertinoButton.filled(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 10),
                            onPressed: () =>
                                playing ? _player.pause() : _player.play(),
                            child: Icon(
                                playing
                                    ? CupertinoIcons.pause_fill
                                    : CupertinoIcons.play_fill,
                                size: 28),
                          ),
                          const SizedBox(width: 6),
                          CupertinoButton(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            onPressed: () async {
                              final v = _player.volume;
                              _player.setVolume((v + 0.1).clamp(0, 1));
                            },
                            child: const Icon(CupertinoIcons.speaker_3_fill,
                                color: _white, size: 28),
                          ),
                        ],
                      );
                    },
                  ),

                  // Position
                  StreamBuilder<Duration>(
                    stream: _player.positionStream,
                    builder: (_, snap) {
                      final pos = snap.data ?? Duration.zero;
                      final dur = _player.duration ?? Duration.zero;
                      final p = dur.inMilliseconds == 0
                          ? 0.0
                          : pos.inMilliseconds / dur.inMilliseconds;
                      return Column(
                        children: [
                          CupertinoSlider(
                              value: p.clamp(0.0, 1.0),
                              onChanged: (v) {
                                if (dur == Duration.zero) return;
                                _player.seek(dur * v);
                              }),
                          Text('${_fmt(pos)} / ${_fmt(dur)}',
                              style: const TextStyle(color: _white)),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 8),

                  // Loop Toggle
                  StreamBuilder<LoopMode>(
                    stream: _player.loopModeStream,
                    initialData: LoopMode.one,
                    builder: (_, snap) {
                      final on = (snap.data ?? LoopMode.one) == LoopMode.one;
                      return CupertinoListTile(
                        backgroundColor: const Color(0x11000000),
                        title: const Text('Endlos wiederholen',
                            style: TextStyle(color: _white)),
                        trailing: CupertinoSwitch(
                          value: on,
                          onChanged: (v) => _player
                              .setLoopMode(v ? LoopMode.one : LoopMode.off),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }
}

String _fmt(Duration d) {
  String two(int v) => v < 10 ? '0$v' : '$v';
  final m = two(d.inMinutes.remainder(60));
  final s = two(d.inSeconds.remainder(60));
  final h = d.inHours;
  return h > 0 ? '$h:$m:$s' : '$m:$s';
}

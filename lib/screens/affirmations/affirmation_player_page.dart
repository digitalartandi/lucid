// lib/screens/affirmations/affirmation_player_page.dart
import 'package:flutter/cupertino.dart';
import 'package:just_audio/just_audio.dart';
import '../../models/affirmation_models.dart';
import '../../services/affirmation_repo.dart';

const _bg     = Color(0xFF0D0F16);
const _white  = Color(0xFFE9EAFF);
const _card   = Color(0xFF0A0A23);
const _line   = Color(0x22FFFFFF);

class AffirmationPlayerPage extends StatefulWidget {
  final String id;
  const AffirmationPlayerPage({super.key, required this.id});

  @override
  State<AffirmationPlayerPage> createState() => _AffirmationPlayerPageState();
}

class _AffirmationPlayerPageState extends State<AffirmationPlayerPage> {
  final _player = AudioPlayer();
  AffirmationTrack? _t;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final t = await AffirmationRepo.instance.byId(widget.id);
    _t = t;
    if (t == null) return;
    // Assets auf Web: via asset:// Pfad
    await _player.setAudioSource(AudioSource.uri(Uri.parse('asset://${t.asset}')));
    await _player.setLoopMode(LoopMode.one);
    await _player.setVolume(.9);
    _player.play();
    if (mounted) setState(() {});
  }

  @override
  void dispose() { _player.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final t = _t;
    return CupertinoPageScaffold(
      backgroundColor: _bg,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: _bg,
        middle: Text(t?.title ?? 'Affirmation', style: const TextStyle(color: _white)),
      ),
      child: t == null
          ? const Center(child: CupertinoActivityIndicator())
          : SafeArea(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                children: [
                  _Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(t.title,
                            style: const TextStyle(color: _white, fontSize: 22, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 4),
                        Text(t.category, style: const TextStyle(color: _white)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Transport
                  StreamBuilder<PlayerState>(
                    stream: _player.playerStateStream,
                    builder: (_, snap) {
                      final playing = snap.data?.playing ?? false;
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CupertinoButton(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            onPressed: () => _player.seek(Duration.zero),
                            child: const Icon(CupertinoIcons.gobackward, color: _white, size: 28),
                          ),
                          const SizedBox(width: 6),
                          CupertinoButton.filled(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                            onPressed: () => playing ? _player.pause() : _player.play(),
                            child: Icon(playing ? CupertinoIcons.pause_fill : CupertinoIcons.play_fill, size: 28),
                          ),
                          const SizedBox(width: 6),
                          CupertinoButton(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            onPressed: () async {
                              final v = _player.volume;
                              _player.setVolume((v + 0.1).clamp(0.0, 1.0));
                            },
                            child: const Icon(CupertinoIcons.speaker_3_fill, color: _white, size: 28),
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
                      final p = dur.inMilliseconds == 0 ? 0.0 : pos.inMilliseconds / dur.inMilliseconds;
                      return Column(
                        children: [
                          CupertinoSlider(
                            value: p.clamp(0.0, 1.0),
                            onChanged: (v) {
                              if (dur == Duration.zero) return;
                              _player.seek(dur * v);
                            },
                          ),
                          Text('${_fmt(pos)} / ${_fmt(dur)}', style: const TextStyle(color: _white)),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 8),
                  _Card(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Endlos wiederholen', style: TextStyle(color: _white)),
                        StreamBuilder<LoopMode>(
                          stream: _player.loopModeStream,
                          initialData: LoopMode.one,
                          builder: (_, snap) {
                            final on = (snap.data ?? LoopMode.one) == LoopMode.one;
                            return CupertinoSwitch(
                              value: on,
                              onChanged: (v) => _player.setLoopMode(v ? LoopMode.one : LoopMode.off),
                            );
                          },
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

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _line),
      ),
      child: child,
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

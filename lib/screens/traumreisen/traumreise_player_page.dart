// lib/screens/traumreisen/traumreise_player_page.dart
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:just_audio/just_audio.dart';

import '../../models/traumreise_models.dart';
import '../../services/traumreise_repo.dart';

const _bgDark = Color(0xFF080B23);
const _white  = Color(0xFFFFFFFF);
const _stroke = Color(0x22FFFFFF);

class TraumreisePlayerPage extends StatefulWidget {
  final String id;
  const TraumreisePlayerPage({super.key, required this.id});

  @override
  State<TraumreisePlayerPage> createState() => _TraumreisePlayerPageState();
}

class _TraumreisePlayerPageState extends State<TraumreisePlayerPage> {
  final _repo = TraumreiseRepo.instance;
  final _player = AudioPlayer();

  Traumreise? _item;
  StreamSubscription<Duration>? _posSub;
  StreamSubscription<Duration?>? _durSub;

  Duration _pos = Duration.zero;
  Duration _dur = Duration.zero;
  bool _loop = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final it = await _repo.byId(widget.id);
    setState(() => _item = it);
    if (it == null) return;

    // Audio laden & starten
    await _player.setAsset(it.audioAsset);
    await _player.setLoopMode(LoopMode.one);
    await _player.play();

    _posSub = _player.positionStream.listen((d) {
      if (mounted) setState(() => _pos = d);
    });
    _durSub = _player.durationStream.listen((d) {
      if (mounted) setState(() => _dur = d ?? Duration.zero);
    });
  }

  @override
  void dispose() {
    _posSub?.cancel();
    _durSub?.cancel();
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final it = _item;

    return CupertinoPageScaffold(
      backgroundColor: _bgDark,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: _bgDark,
        middle: Text(it?.title ?? 'Traumreise'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Fertig'),
        ),
        border: const Border(bottom: BorderSide(color: _stroke, width: 0.5)),
      ),
      child: it == null
          ? const Center(child: CupertinoActivityIndicator())
          : SafeArea(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                children: [
                  // Cover
                  AspectRatio(
                    aspectRatio: 3 / 2,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(it.imageAsset, fit: BoxFit.cover),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Text(
                    it.title,
                    style: const TextStyle(
                      color: _white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(it.subtitle, style: const TextStyle(color: _white, fontSize: 15)),

                  const SizedBox(height: 18),

                  // Seekbar
                  _SeekBar(
                    position: _pos,
                    duration: _dur,
                    onChanged: (v) => _player.seek(v),
                  ),
                  const SizedBox(height: 8),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_fmt(_pos), style: const TextStyle(color: _white)),
                      Text(_fmt(_dur), style: const TextStyle(color: _white)),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Controls
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CupertinoButton(
                        onPressed: () async {
                          final newPos = _pos - const Duration(seconds: 15);
                          await _player.seek(newPos < Duration.zero ? Duration.zero : newPos);
                        },
                        child: const Icon(CupertinoIcons.gobackward_15, color: _white, size: 28),
                      ),
                      const SizedBox(width: 6),

                      StreamBuilder<PlayerState>(
                        stream: _player.playerStateStream,
                        builder: (_, snap) {
                          final playing = snap.data?.playing ?? _player.playing;
                          return CupertinoButton.filled(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                            onPressed: () async {
                              if (playing) {
                                await _player.pause();
                              } else {
                                await _player.play();
                              }
                            },
                            child: Icon(
                              playing ? CupertinoIcons.pause_fill : CupertinoIcons.play_fill,
                              size: 28,
                            ),
                          );
                        },
                      ),

                      const SizedBox(width: 6),
                      CupertinoButton(
                        onPressed: () async {
                          final newPos = _pos + const Duration(seconds: 15);
                          if (_dur == Duration.zero) return;
                          await _player.seek(newPos > _dur ? _dur : newPos);
                        },
                        child: const Icon(CupertinoIcons.goforward_15, color: _white, size: 28),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Loop', style: TextStyle(color: _white)),
                      const SizedBox(width: 8),
                      CupertinoSwitch(
                        value: _loop,
                        onChanged: (v) async {
                          setState(() => _loop = v);
                          await _player.setLoopMode(v ? LoopMode.one : LoopMode.off);
                        },
                        activeColor: const Color(0xFF7A6CFF),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),
                  const Text(
                    'Hinweis: Für beste Wirkung mit Kopfhörern hören. '
                    'Enthält Lucidity-Anker & sanfte RC-Erinnerungen.',
                    style: TextStyle(color: _white),
                  ),
                ],
              ),
            ),
    );
  }

  String _fmt(Duration d) {
    String two(int x) => x < 10 ? '0$x' : '$x';
    final mm = two(d.inMinutes.remainder(60));
    final ss = two(d.inSeconds.remainder(60));
    final hh = d.inHours;
    return hh > 0 ? '$hh:$mm:$ss' : '$mm:$ss';
  }
}

/// Cupertino-Slider, der Position/Duration in beide Richtungen synct
class _SeekBar extends StatelessWidget {
  final Duration position;
  final Duration duration;
  final ValueChanged<Duration> onChanged;

  const _SeekBar({
    required this.position,
    required this.duration,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final total = duration.inMilliseconds == 0 ? 1 : duration.inMilliseconds;
    final value = (position.inMilliseconds / total).clamp(0.0, 1.0);
    return CupertinoSlider(
      value: value,
      onChanged: (v) => onChanged(Duration(milliseconds: (v * total).round())),
      activeColor: const Color(0xFF7A6CFF),
    );
  }
}

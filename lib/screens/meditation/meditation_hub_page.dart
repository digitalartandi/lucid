import 'package:flutter/cupertino.dart';
import '../../models/meditation_models.dart';
import '../../services/meditation_repo.dart';

const _bg = Color(0xFF080B23);
const _white = Color(0xFFFFFFFF);
const _stroke = Color(0x22FFFFFF);
const _card = Color(0xFF0F1220);

class MeditationHubPage extends StatefulWidget {
  const MeditationHubPage({super.key});
  @override
  State<MeditationHubPage> createState() => _MeditationHubPageState();
}

class _MeditationHubPageState extends State<MeditationHubPage> {
  List<MeditationTrack> _tracks = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await MeditationRepo.instance.all();
    if (!mounted) return;
    setState(() {
      _tracks = list;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: _bg,
      navigationBar: const CupertinoNavigationBar(
        backgroundColor: _bg,
        middle: Text('Soundscapes', style: TextStyle(color: _white)),
        border: Border(bottom: BorderSide(color: _stroke, width: .5)),
      ),
      child: _loading
          ? const Center(child: CupertinoActivityIndicator())
          : SafeArea(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                itemCount: _tracks.length,
                itemBuilder: (_, i) {
                  final t = _tracks[i];
                  final label = _durationLabel(t);
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: _card,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: _stroke),
                    ),
                    child: CupertinoButton(
                      padding: const EdgeInsets.all(12),
                      onPressed: () => Navigator.of(context)
                          .pushNamed('/meditations/play', arguments: t.id),
                      child: Row(
                        children: [
                          _CoverThumb(path: t.cover),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  t.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: _white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  label == null ? t.category : '${t.category} · $label',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(color: _white),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(CupertinoIcons.play_fill, color: _white),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }

  /// Robuste Daueranzeige – ohne Extensions/zusätzliche Datei.
  String? _durationLabel(MeditationTrack t) {
    // Falls dein Model bereits eine fertige Anzeige hat:
    final dyn = t as dynamic;
    try {
      final any = dyn.durationLabel;
      if (any is String && any.trim().isNotEmpty) return any;
    } catch (_) {}

    int? minutes;
    try {
      final v = dyn.durationMinutes ?? dyn.durationMin ?? dyn.minutes ?? dyn.lengthMinutes;
      if (v is int) minutes = v;
      if (v is double) minutes = v.round();
    } catch (_) {}

    return (minutes == null || minutes <= 0) ? null : '$minutes min';
  }
}

class _CoverThumb extends StatelessWidget {
  const _CoverThumb({required this.path});
  final String? path;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 64,
      height: 64,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: path != null && path!.isNotEmpty
            ? Image.asset(path!, fit: BoxFit.cover)
            : Container(color: const Color(0xFF1B1E33)),
      ),
    );
  }
}

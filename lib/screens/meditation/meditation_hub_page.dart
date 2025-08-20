import 'package:flutter/cupertino.dart';
import '../../design/gradient_theme.dart';
import '../../models/meditation_models.dart';
import '../../services/meditation_repo.dart';

const _bg = Color(0xFF080B23);
const _white = Color(0xFFFFFFFF);
const _stroke = Color(0x22FFFFFF);

class MeditationHubPage extends StatefulWidget {
  const MeditationHubPage({super.key});
  @override State<MeditationHubPage> createState() => _MeditationHubPageState();
}

class _MeditationHubPageState extends State<MeditationHubPage> {
  List<MeditationTrack> _items = [];

  @override
  void initState() { super.initState(); _load(); }
  Future<void> _load() async {
    _items = await MeditationRepo.instance.all();
    if (mounted) setState((){});
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: _bg,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: _bg,
        middle: const Text('Soundscapes', style: TextStyle(color: _white)),
        border: const Border(bottom: BorderSide(color: _stroke, width: .5)),
      ),
      child: SafeArea(
        child: GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: .88),
          itemCount: _items.length,
          itemBuilder: (_, i) {
            final t = _items[i];
            return _Tile(track: t, onTap: (){
              Navigator.of(context).pushNamed('/meditations/play', arguments: t.id);
            });
          },
        ),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  final MeditationTrack track;
  final VoidCallback onTap;
  const _Tile({required this.track, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final g = GradientTheme.of(GradientTheme.style.value).primary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _stroke),
          boxShadow: const [BoxShadow(color: Color(0x66000000), blurRadius: 14, offset: Offset(0,8))]
        ),
        clipBehavior: Clip.hardEdge,
        child: Stack(
          children: [
            Positioned.fill(
              child: track.cover.isNotEmpty
                  ? Image.asset(track.cover, fit: BoxFit.cover)
                  : DecoratedBox(decoration: BoxDecoration(
                      gradient: LinearGradient(colors: g, begin: Alignment.topLeft, end: Alignment.bottomRight))),
            ),
            Positioned(
              left: 10, right:10, bottom: 10,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: const Color(0x66000000),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(track.title, maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: _white, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(track.category, maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: _white)),
                  ]),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

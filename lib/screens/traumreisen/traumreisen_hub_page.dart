// lib/screens/traumreisen/traumreisen_hub_page.dart
import 'package:flutter/cupertino.dart';
import '../../models/traumreise_models.dart';
import '../../services/traumreise_repo.dart';

const _bgDark = Color(0xFF080B23);
const _white = Color(0xFFFFFFFF);
const _stroke = Color(0x22FFFFFF);
const _rXL = BorderRadius.all(Radius.circular(20));

class TraumreisenHubPage extends StatefulWidget {
  const TraumreisenHubPage({super.key});

  @override
  State<TraumreisenHubPage> createState() => _TraumreisenHubPageState();
}

class _TraumreisenHubPageState extends State<TraumreisenHubPage> {
  final _repo = TraumreiseRepo.instance;
  List<Traumreise> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await _repo.all();
    if (!mounted) return;
    setState(() => _items = list);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: _bgDark,
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Traumreisen'),
        backgroundColor: _bgDark,
        border: Border(bottom: BorderSide(color: _stroke, width: 0.5)),
      ),
      child: SafeArea(
        bottom: false,
        child: _items.isEmpty
            ? const Center(child: CupertinoActivityIndicator())
            : ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                children: [
                  const _SectionTitle('Empfohlen'),
                  const SizedBox(height: 10),
                  _HorizontalBanners(items: _items),

                  const SizedBox(height: 22),
                  const _SectionTitle('Alle Traumreisen'),
                  const SizedBox(height: 10),
                  _HorizontalBanners(items: _items),
                ],
              ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: const TextStyle(
          color: _white, fontSize: 18, fontWeight: FontWeight.w800));
  }
}

class _HorizontalBanners extends StatelessWidget {
  final List<Traumreise> items;
  const _HorizontalBanners({required this.items});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) => _BannerCard(item: items[i]),
      ),
    );
  }
}

class _BannerCard extends StatelessWidget {
  final Traumreise item;
  const _BannerCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Traumreise ${item.title}',
      child: GestureDetector(
        onTap: () => Navigator.of(context).pushNamed('/traumreisen/play', arguments: item.id),
        child: Container(
          width: 280,
          decoration: BoxDecoration(
            borderRadius: _rXL,
            border: Border.all(color: _stroke, width: 0.5),
            image: DecorationImage(
              image: AssetImage(item.imageAsset),
              fit: BoxFit.cover,
            ),
            boxShadow: const [
              BoxShadow(color: Color(0x66000000), blurRadius: 16, offset: Offset(0, 8)),
            ],
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: _rXL,
              gradient: const LinearGradient(
                begin: Alignment.bottomCenter, end: Alignment.topCenter,
                colors: [Color(0xAA000000), Color(0x00000000)],
                stops: [0.0, 0.6],
              ),
            ),
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
            alignment: Alignment.bottomLeft,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title,
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: _white, fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(item.subtitle,
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: _white)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

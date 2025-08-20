import 'package:flutter/cupertino.dart';

import '../../design/brand_appbar.dart';
// Journal
import '../../services/journal_repo.dart';
import '../../models/journal_models.dart';

// Media/Manifest
import 'dart:convert' show jsonDecode;
import 'package:flutter/services.dart' show rootBundle;
import 'package:video_player/video_player.dart';

// ---------- Farben laut Briefing ----------
const _bgDark = Color(0xFF080B23);

const _violetA = Color(0xFF7C83FF);
const _violetB = Color(0xFFA179EF);

const _violet2_1 = Color(0xFF926AB7);
const _violet2_2 = Color(0xFF7149CD);

const _pinkA = Color(0xFFED68BE);
const _pinkB = Color(0xFFEE2B71);

const _cyan  = Color(0xFF52CAEB);
const _white = Color(0xFFFFFFFF);

const _surface = Color(0xFF0A0A23); // solide Kartenfläche
const _stroke  = Color(0x22FFFFFF); // zarte Kontur

const _rXL = BorderRadius.all(Radius.circular(20));
const _rL  = BorderRadius.all(Radius.circular(16));

// ---------- Model für Header-Slider ----------
class _Promo {
  final String title;
  final String subtitle;
  final List<Color> grad;
  final String? imageAsset; // optional 3:2-Bild (assets)
  const _Promo(this.title, this.subtitle, this.grad, {this.imageAsset});
}

// Beispiel-Slides (Fallback, falls kein Manifest vorhanden)
const _promos = <_Promo>[
  _Promo(
    'Night Lite+ 2.0',
    'Sanfte REM-Cues & neue Sounds',
    [_violetA, _cyan],
    imageAsset: 'assets/slider/slide1.jpg',
  ),
  _Promo('RC-Reminder Pro', 'Kontextbasiert mit Zeitfenstern', [_violet2_1, _violet2_2]),
  _Promo('Journal Export', 'PDF/Markdown teilen', [_pinkA, _pinkB]),
];

/// Startseite: Header-Slider (Bild/Video), Hero, Cards, Quick Actions, Recents
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: _bgDark,
      navigationBar: const BrandAppBar(),
      child: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: const [
            _PromoSlider(banners: _promos), // ⬅️ Header-Slider (3:2)
            SizedBox(height: 14),
            _HeroScore(),
            SizedBox(height: 16),
            _HorizontalCards(),
            SizedBox(height: 16),
            _QuickGrid(),
            SizedBox(height: 16),
            _PromoBanner(),
            SizedBox(height: 20),
            _RecentSection(),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

// ------------------------------------------------------
//  Header Slider (3:2) – lädt Bilder & Videos aus Manifest
// ------------------------------------------------------

class _PromoMedia {
  final String title;
  final String subtitle;
  final String asset;          // Bild- oder Video-Assetpfad
  final bool isVideo;
  final List<Color>? grad;     // Fallback-Gradient wenn kein Asset
  const _PromoMedia({
    required this.title,
    required this.subtitle,
    required this.asset,
    required this.isVideo,
    this.grad,
  });
}

class _PromoSlider extends StatefulWidget {
  final List<_Promo> banners; // Fallback
  const _PromoSlider({super.key, required this.banners});

  @override
  State<_PromoSlider> createState() => _PromoSliderState();
}

class _PromoSliderState extends State<_PromoSlider> {
  late final PageController _ctrl;
  int _index = 0;
  List<_PromoMedia> _items = const [];

  @override
  void initState() {
    super.initState();
    _ctrl = PageController(viewportFraction: .90);
    _loadManifestOrFallback();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _loadManifestOrFallback() async {
    try {
      final s = await rootBundle.loadString('assets/slider/manifest.json');
      final data = jsonDecode(s) as Map<String, dynamic>;
      final list = (data['items'] as List).cast<Map<String, dynamic>>();
      final items = list.map((m) {
        final type = (m['type'] ?? 'image').toString().toLowerCase();
        return _PromoMedia(
          title: (m['title'] ?? '') as String,
          subtitle: (m['subtitle'] ?? '') as String,
          asset: (m['asset'] ?? '') as String,
          isVideo: type == 'video',
        );
      }).toList();

      if (!mounted) return;
      setState(() => _items = items);
      // Bilder vorladen (Videos nicht nötig)
      for (final it in items.where((e) => !e.isVideo && e.asset.isNotEmpty)) {
        // ignore: use_build_context_synchronously
        precacheImage(AssetImage(it.asset), context);
      }
    } catch (_) {
      // Fallback: Code-Promos nutzen
      final fb = widget.banners.map((p) => _PromoMedia(
        title: p.title,
        subtitle: p.subtitle,
        asset: p.imageAsset ?? '',
        isVideo: false,
        grad: p.grad,
      )).toList();
      if (!mounted) return;
      setState(() => _items = fb);
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = _items;
    if (items.isEmpty) {
      return const SizedBox(height: 200, child: Center(child: CupertinoActivityIndicator()));
    }

    return Column(
      children: [
        AspectRatio(
          aspectRatio: 3 / 2,
          child: PageView.builder(
            controller: _ctrl,
            onPageChanged: (i) => setState(() => _index = i),
            itemCount: items.length,
            itemBuilder: (ctx, i) {
              final p = items[i];
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: _SolidCard(
                  radius: _rXL,
                  color: _surface,
                  child: ClipRRect(
                    borderRadius: _rXL,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // 1) Media-Hintergrund
                        if (p.isVideo)
                          _VideoCard(asset: p.asset)
                        else if (p.asset.isNotEmpty)
                          Image.asset(p.asset, fit: BoxFit.cover)
                        else
                          DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: p.grad ?? [_violetA, _cyan],
                              ),
                            ),
                          ),

                        // 2) dunkler Fade unten für Lesbarkeit
                        const _BottomFade(),

                        // 3) Beschriftung
                        Positioned(
                          left: 16, right: 16, bottom: 16,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(p.title,
                                  maxLines: 1, overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: _white, fontSize: 18, fontWeight: FontWeight.w800)),
                              const SizedBox(height: 4),
                              Text(p.subtitle,
                                  maxLines: 2, overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(color: _white)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(items.length, (i) {
            final active = i == _index;
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _ctrl.animateToPage(
                i, duration: const Duration(milliseconds: 260), curve: Curves.easeOut),
              child: Container(
                width: 24, height: 24,
                alignment: Alignment.center,
                child: Container(
                  width: active ? 10 : 8,
                  height: active ? 10 : 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: active ? _white.withOpacity(.95) : _white.withOpacity(.35),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _BottomFade extends StatelessWidget {
  const _BottomFade();
  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter, end: Alignment.topCenter,
          colors: [Color(0xAA000000), Color(0x00000000)],
          stops: [0.0, 0.5],
        ),
      ),
    );
  }
}

class _VideoCard extends StatefulWidget {
  final String asset;
  const _VideoCard({required this.asset});

  @override
  State<_VideoCard> createState() => _VideoCardState();
}

class _VideoCardState extends State<_VideoCard> {
  late final VideoPlayerController _c;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _c = VideoPlayerController.asset(widget.asset);
    _init();
  }

  Future<void> _init() async {
    try {
      await _c.setLooping(true);
      await _c.setVolume(0); // stumm → Autoplay im Web/iOS erlaubt
      await _c.initialize();
      await _c.play();
      if (!mounted) return;
      setState(() => _ready = true);
    } catch (_) {
      // Wenn das Video nicht geladen werden kann, bleiben wir still.
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) return const SizedBox.shrink();
    return FittedBox(
      fit: BoxFit.cover,
      clipBehavior: Clip.hardEdge,
      child: SizedBox(
        width: _c.value.size.width,
        height: _c.value.size.height,
        child: VideoPlayer(_c),
      ),
    );
  }
}

// ------------------------------------------------------
//  Hero („8 Sessions“)
// ------------------------------------------------------
class _HeroScore extends StatelessWidget {
  const _HeroScore();

  @override
  Widget build(BuildContext context) {
    return _SolidCard(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      radius: _rXL,
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [_violetA, _cyan],
      ),
      child: Row(
        children: const [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Dein Klartraum-Score', style: TextStyle(fontSize: 13, color: _white)),
                SizedBox(height: 4),
                Text('8 Sessions',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: _white)),
                SizedBox(height: 6),
                Text('Diese Woche +2 gegenüber letzter Woche',
                    style: TextStyle(fontSize: 13, color: _white)),
              ],
            ),
          ),
          _StartButton(),
        ],
      ),
    );
  }
}

class _StartButton extends StatelessWidget {
  const _StartButton();

  @override
  Widget build(BuildContext context) {
    return CupertinoButton.filled(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      borderRadius: BorderRadius.circular(14),
      onPressed: () => Navigator.of(context).pushNamed('/trainer'),
      child: const Text('Start'),
    );
  }
}

// ------------------------------------------------------
//  Horizontale Gradient-Cards
// ------------------------------------------------------
class _HorizontalCards extends StatelessWidget {
  const _HorizontalCards();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 140,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: const [
          _GradientCard(
            title: 'RC-Reminder',
            subtitle: 'kontextbasiert',
            colors: [_violetA, _cyan],
            route: '/rc',
          ),
          _GradientCard(
            title: 'Night Lite+',
            subtitle: 'REM-Cues',
            colors: [_violet2_1, _violet2_2],
            route: '/nightlite',
          ),
          _GradientCard(
            title: 'Journal',
            subtitle: 'schnell notieren',
            colors: [_pinkA, _pinkB],
            route: '/journal',
          ),
        ],
      ),
    );
  }
}

class _GradientCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Color> colors; // [start, end]
  final String route;

  const _GradientCard({
    required this.title,
    required this.subtitle,
    required this.colors,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: Padding(
        padding: const EdgeInsets.only(right: 12),
        child: _SolidCard(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [colors.first, colors.last],
          ),
          onTap: () => Navigator.of(context).pushNamed(route),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(title,
                  style: const TextStyle(
                    color: _white, fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text(subtitle, style: const TextStyle(color: _white)),
            ],
          ),
        ),
      ),
    );
  }
}

// ------------------------------------------------------
//  Quick Actions (2×2)
// ------------------------------------------------------
class _QuickGrid extends StatelessWidget {
  const _QuickGrid();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        _QuickRow(
          left: _QuickAction(icon: CupertinoIcons.bell,       label: 'Trainer',     route: '/trainer'),
          right:_QuickAction(icon: CupertinoIcons.music_note, label: 'Cue Tuning',  route: '/cuetuning'),
        ),
        SizedBox(height: 12),
        _QuickRow(
          left: _QuickAction(icon: CupertinoIcons.book,       label: 'Wissen',      route: '/wissen'),
          right:_QuickAction(icon: CupertinoIcons.chart_bar,  label: 'Fortschritt', route: '/telemetry'),
        ),
      ],
    );
  }
}

class _QuickRow extends StatelessWidget {
  final _QuickAction left;
  final _QuickAction right;
  const _QuickRow({required this.left, required this.right});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: left),
        const SizedBox(width: 12),
        Expanded(child: right),
      ],
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final String route;

  const _QuickAction({required this.icon, required this.label, required this.route});

  @override
  Widget build(BuildContext context) {
    return _SolidCard(
      radius: _rXL,
      color: _surface,
      onTap: () => Navigator.of(context).pushNamed(route),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Color(0x1AFFFFFF),
              borderRadius: _rL,
            ),
            child: Icon(icon, color: _white, size: 20),
          ),
          const SizedBox(height: 12),
          Text(label, style: const TextStyle(color: _white, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// ------------------------------------------------------
//  Promo-Banner
// ------------------------------------------------------
class _PromoBanner extends StatelessWidget {
  const _PromoBanner();

  @override
  Widget build(BuildContext context) {
    return _SolidCard(
      radius: _rXL,
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [_violetA, _pinkA],
      ),
      child: Row(
        children: const [
          Expanded(
            child: Text('2-Wochen-Trainer – dein klarer Einstieg.',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _white)),
          ),
          _Pill('Neu', CupertinoIcons.sparkles),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final IconData icon;
  const _Pill(this.label, this.icon);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: const BoxDecoration(
        color: Color(0x1AFFFFFF),
        borderRadius: BorderRadius.all(Radius.circular(999)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: _white),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(color: _white, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// ------------------------------------------------------
//  Recents – dynamisch aus JournalRepo
// ------------------------------------------------------
class _RecentSection extends StatefulWidget {
  const _RecentSection();

  @override
  State<_RecentSection> createState() => _RecentSectionState();
}

class _RecentSectionState extends State<_RecentSection> {
  final _repo = JournalRepo.instance;
  List<JournalIndexItem> _recent = [];

  @override
  void initState() {
    super.initState();
    _init();
    _repo.revision.addListener(_refresh);
  }

  @override
  void dispose() {
    _repo.revision.removeListener(_refresh);
    super.dispose();
  }

  Future<void> _init() async {
    await _repo.init();
    await _refresh();
  }

  Future<void> _refresh() async {
    final latest = await _repo.latest(count: 3);
    if (!mounted) return;
    setState(() => _recent = latest);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Zuletzt',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _white)),
        const SizedBox(height: 8),

        if (_recent.isEmpty)
          const _Recent(title: 'Journal – keine Einträge', subtitle: 'Noch keine Notizen')
        else
          ..._recent.map((it) => _Recent(
                title: 'Journal – ${it.title.isEmpty ? 'Ohne Titel' : it.title}',
                subtitle: _friendlyDate(it.date),
                onTap: () => Navigator.of(context).pushNamed('/journal/edit', arguments: it.id),
              )),

        // Beispiele/Events behalten:
        const _Recent(title: 'RC-Reminder aktiviert',      subtitle: 'Gestern, 19:42'),
        const _Recent(title: 'Cue Tuning – sanfte Glocke', subtitle: 'Gestern, 18:11'),
      ],
    );
  }
}

String _friendlyDate(DateTime dt) {
  final now = DateTime.now();
  final d = dt.toLocal();
  bool sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String two(int x) => x < 10 ? '0$x' : '$x';
  final hm = '${two(d.hour)}:${two(d.minute)}';

  if (sameDay(d, now)) return 'Heute, $hm';
  final yesterday = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 1));
  if (sameDay(d, yesterday)) return 'Gestern, $hm';
  return '${two(d.day)}.${two(d.month)}.${d.year}, $hm';
}

class _Recent extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  const _Recent({required this.title, required this.subtitle, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: _rXL,
        border: Border.all(color: _stroke),
      ),
      child: CupertinoListTile.notched(
        title: Text(title, style: const TextStyle(color: _white)),
        subtitle: Text(subtitle, style: const TextStyle(color: _white)),
        trailing: const Icon(CupertinoIcons.chevron_right, color: _white),
        onTap: onTap,
      ),
    );
  }
}

// ------------------------------------------------------
//  Solide Karte (kein Glass, nur Gradient/Farbe + Border + Shadow)
// ------------------------------------------------------
class _SolidCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final BorderRadius radius;
  final LinearGradient? gradient;
  final Color? color;
  final VoidCallback? onTap;

  const _SolidCard({
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = _rXL,
    this.gradient,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final box = Container(
      decoration: BoxDecoration(
        color: color,
        gradient: gradient,
        borderRadius: radius,
        border: Border.all(color: _stroke),
        boxShadow: const [
          BoxShadow(color: Color(0x66000000), blurRadius: 18, offset: Offset(0, 8)),
          BoxShadow(color: Color(0x33000000), blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Padding(padding: padding, child: child),
    );

    if (onTap == null) return box;
    return GestureDetector(onTap: onTap, child: box);
  }
}

/// Deko-Aurora (kein Glass)
class _AuroraBlob extends StatelessWidget {
  final List<Color> colors;
  final double opacity;
  const _AuroraBlob({required this.colors, this.opacity = .3});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            colors.first.withOpacity(opacity),
            colors.last.withOpacity(0),
          ],
          stops: const [0, 1],
        ),
      ),
    );
  }
}

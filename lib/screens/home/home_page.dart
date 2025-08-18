import 'package:flutter/cupertino.dart';

import '../../design/brand_appbar.dart';

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

// Beispiel-Slides (du kannst imageAsset setzen, z. B. 'assets/slider/slide1.jpg')
const _promos = <_Promo>[
  _Promo(
    'Night Lite+ 2.0',
    'Sanfte REM-Cues & neue Sounds',
    [_violetA, _cyan],
    imageAsset: 'assets/slider/slide1.jpg',  // ← dein Bild (liegt im Ordner)
  ),
  _Promo('RC-Reminder Pro', 'Kontextbasiert mit Zeitfenstern', [_violet2_1, _violet2_2]),
  _Promo('Journal Export', 'PDF/Markdown teilen', [_pinkA, _pinkB]),
];

/// Startseite ohne Glass: Header-Slider, Hero, Gradient-Cards, Quick Actions, Recents
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: const Color(0x00000000),
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
//  Header Slider (3:2), Swipe + tappbare Dots (große Touch-Targets)
// ------------------------------------------------------
class _PromoSlider extends StatefulWidget {
  final List<_Promo> banners;
  const _PromoSlider({super.key, required this.banners});

  @override
  State<_PromoSlider> createState() => _PromoSliderState();
}

class _PromoSliderState extends State<_PromoSlider> {
  late final PageController _ctrl;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _ctrl = PageController(viewportFraction: .90);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AspectRatio(
          aspectRatio: 3 / 2,
          child: PageView.builder(
            controller: _ctrl,
            onPageChanged: (i) => setState(() => _index = i),
            itemCount: widget.banners.length,
            itemBuilder: (ctx, i) {
              final p = widget.banners[i];
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: _SolidCard(
                  radius: _rXL,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: p.grad,
                  ),
                  child: Stack(
                    children: [
                      if (p.imageAsset != null)
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: _rXL,
                              image: DecorationImage(
                                image: AssetImage(p.imageAsset!),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      Positioned(
                        left: 16, right: 16, bottom: 16,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p.title,
                                style: const TextStyle(
                                  color: _white, fontSize: 18, fontWeight: FontWeight.w800)),
                            const SizedBox(height: 4),
                            Text(p.subtitle, style: const TextStyle(color: _white)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.banners.length, (i) {
            final active = i == _index;
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _ctrl.animateToPage(
                i, duration: const Duration(milliseconds: 260), curve: Curves.easeOut),
              child: Container(
                width: 24, height: 24, // leicht zu tippen
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
//  Recents
// ------------------------------------------------------
class _RecentSection extends StatelessWidget {
  const _RecentSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text('Zuletzt',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _white)),
        SizedBox(height: 8),
        _Recent(title: 'Journal – 3 Einträge',      subtitle: 'Heute, 07:10'),
        _Recent(title: 'RC-Reminder aktiviert',      subtitle: 'Gestern, 19:42'),
        _Recent(title: 'Cue Tuning – sanfte Glocke', subtitle: 'Gestern, 18:11'),
      ],
    );
  }
}

class _Recent extends StatelessWidget {
  final String title;
  final String subtitle;
  const _Recent({required this.title, required this.subtitle});

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
        onTap: () {},
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

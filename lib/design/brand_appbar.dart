// lib/design/brand_appbar.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

const _bgDark = Color(0xFF080B23);
const _white  = Color(0xFFFFFFFF);
const _hairline = Color(0x22FFFFFF);

class BrandAppBar extends StatelessWidget implements ObstructingPreferredSizeWidget {
  const BrandAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(44);

  @override
  bool shouldFullyObstruct(BuildContext context) => true;

  @override
  Widget build(BuildContext context) {
    return CupertinoNavigationBar(
      backgroundColor: _bgDark,
      automaticallyImplyLeading: false,
      // Wir nutzen 'leading' für linksbündigen Titel (Signet + Textlogo).
      leading: const _BrandLeading(),
      // kein 'middle', sonst würde es zentriert werden.
      middle: null,
      trailing: CupertinoButton(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        minSize: 36,
        onPressed: () => Navigator.of(context).pushNamed('/account'),
        child: const Icon(CupertinoIcons.person_crop_circle, color: _white, size: 24),
      ),
      border: const Border(bottom: BorderSide(color: _hairline, width: .5)),
    );
  }
}

class _BrandLeading extends StatelessWidget {
  const _BrandLeading();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        SizedBox(width: 6),
        _AnimatedSignet(), // kleines Signet mit „Mond“-Pulse
        SizedBox(width: 10),
        _LogoText(),       // weißes Textlogo
      ],
    );
  }
}

class _LogoText extends StatelessWidget {
  const _LogoText();

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/logo/logo-text.svg',
      height: 18, // fein für die Nav-Bar
      colorFilter: const ColorFilter.mode(_white, BlendMode.srcIn),
      clipBehavior: Clip.hardEdge,
    );
  }
}

/// Kleiner „Mond-Pulse“ beim Laden.
/// Hinweis: Da das Signet als eine SVG-Pfadform vorliegt, animieren wir
/// das ganze Symbol subtil (Scale + Opacity), was dem Mond ein sanftes Aufblitzen gibt.
class _AnimatedSignet extends StatefulWidget {
  const _AnimatedSignet();

  @override
  State<_AnimatedSignet> createState() => _AnimatedSignetState();
}

class _AnimatedSignetState extends State<_AnimatedSignet> with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 650));
    _scale = Tween<double>(begin: .92, end: 1.0).animate(
      CurvedAnimation(parent: _c, curve: Curves.easeOutBack),
    );
    _opacity = Tween<double>(begin: .0, end: 1.0).animate(
      CurvedAnimation(parent: _c, curve: Curves.easeOut),
    );
    _c.forward();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: ScaleTransition(
        scale: _scale,
        child: SvgPicture.asset(
          'assets/logo/logo-signet.svg',
          height: 22,
          colorFilter: const ColorFilter.mode(_white, BlendMode.srcIn),
        ),
      ),
    );
  }
}

import 'package:flutter/cupertino.dart';
import '../theme.dart';

class HeroHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final String asset;
  final VoidCallback? onPrimary;
  final String primaryLabel;
  const HeroHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.asset,
    this.onPrimary,
    this.primaryLabel = 'Jetzt starten',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 190,
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: Brand.heroGradient,
        ),
        boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 16, offset: Offset(0, 8))],
      ),
      child: Stack(children: [
        Positioned.fill(
          child: Opacity(
            opacity: 0.18,
            child: Image.asset(asset, fit: BoxFit.cover),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: T.titleL.copyWith(color: CupertinoColors.white)),
              const SizedBox(height: 6),
              Text(subtitle, style: T.body.copyWith(color: const Color(0xFFF0F3FF))),
              const Spacer(),
              if (onPrimary != null)
                Align(
                  alignment: Alignment.bottomLeft,
                  child: CupertinoButton(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    color: const Color(0xFFFFFFFF),
                    borderRadius: BorderRadius.circular(22),
                    onPressed: onPrimary,
                    child: Text(primaryLabel, style: const TextStyle(color: Brand.primaryDark, fontWeight: FontWeight.w700)),
                  ),
                ),
            ],
          ),
        ),
      ]),
    );
  }
}








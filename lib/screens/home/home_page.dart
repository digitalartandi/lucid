import 'package:flutter/cupertino.dart';
import '../../apple_ui/widgets/large_sliver_scaffold.dart';
import '../../apple_ui/widgets/section_list.dart';
import '../../design/widgets/hero_header.dart';
import '../../design/widgets/brand_chip.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return LargeSliverScaffold(
      title: 'Klartraum Studio',
      slivers: [
        SliverToBoxAdapter(child: HeroHeader(
  title: 'Lernen • Üben • Sanft erinnern',
  subtitle: 'Vom Traumtagebuch zum Klartraum: alles an einem Ort – privat, 100% on-device.',
  asset: 'assets/brand/hero_bg.webp',        // <- WebP
  onPrimary: () => Navigator.pushNamed(context, '/trainer'),
  primaryLabel: '2-Wochen-Trainer starten',
)),

        SliverToBoxAdapter(child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(spacing: 8, runSpacing: 8, children: const [
            BrandChip(label: 'Einsteigerfreundlich', icon: CupertinoIcons.hand_thumbsup),
            BrandChip(label: 'Fortschritt im Blick', icon: CupertinoIcons.chart_bar_alt_fill),
            BrandChip(label: 'Privat', icon: CupertinoIcons.lock_fill),
          ]),
        )),
        SliverToBoxAdapter(child: Section(header: 'Schnelle Wege', children: [
          RowItem(title: const Text('Reality-Checks (RC-Reminder)'), subtitle: const Text('Kontextbasierte Erinnerungen'), onTap: ()=> Navigator.pushNamed(context, '/rc')),
          RowItem(title: const Text('Night Lite+'), subtitle: const Text('Sanfte Hinweise in REM-Fenstern'), onTap: ()=> Navigator.pushNamed(context, '/nightlite')),
          RowItem(title: const Text('Journal'), subtitle: const Text('Traum festhalten â€“ direkt nach dem Aufwachen'), onTap: ()=> Navigator.pushNamed(context, '/journal')),
        ])),
        SliverToBoxAdapter(child: Section(header: 'Entdecken', children: [
          RowItem(title: const Text('Trainer â€“ 2-Wochen-Plan'), subtitle: const Text('GefÃ¼hrtes Programm von Basics bis Profis'), onTap: ()=> Navigator.pushNamed(context, '/trainer')),
          RowItem(title: const Text('Cue-Tuning â€“ Audio-Lab'), subtitle: const Text('Fein dosieren & testen'), onTap: ()=> Navigator.pushNamed(context, '/cuetuning')),
          RowItem(title: const Text('Wissen â€“ kompakt'), subtitle: const Text('Fundierte Artikel mit TOC & Lesezeichen'), onTap: ()=> Navigator.pushNamed(context, '/wissen')),
        ])),
        const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
      ],
    );
  }
}







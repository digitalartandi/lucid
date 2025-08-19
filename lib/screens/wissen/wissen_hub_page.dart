import 'package:flutter/cupertino.dart';

/// Wissen-Hub: Einstieg in alle Wissensinhalte + schnelles FAQ (Accordion)
class WissenHubPage extends StatefulWidget {
  const WissenHubPage({super.key});

  @override
  State<WissenHubPage> createState() => _WissenHubPageState();
}

class _WissenHubPageState extends State<WissenHubPage>
    with TickerProviderStateMixin {
  final _scrollCtrl = ScrollController();

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const white = Color(0xFFFFFFFF);
    const sub   = Color(0xFFB8C0E8);
    const card  = Color(0xFF0F1220);
    const line  = Color(0x33FFFFFF);
    const violet = Color(0xFF7A6CFF);

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Wissen'),
      ),
      backgroundColor: const Color(0x00000000),
      child: SafeArea(
        top: false,
        child: CupertinoScrollbar(
          controller: _scrollCtrl,
          child: ListView(
            controller: _scrollCtrl,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
            children: [
              // Intro
              const Text(
                'Lernen. Verstehen. Anwenden.',
                style: TextStyle(
                  color: white, fontSize: 22, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              const Text(
                'Alles zu Klarträumen – von Grundlagen bis Pro-Techniken. '
                'Kompakt erklärt, belegbar und praxisnah.',
                style: TextStyle(color: sub, fontSize: 15, height: 1.45),
              ),
              const SizedBox(height: 20),

              // Schnellzugriffe (Studien & Leseliste)
              Row(
                children: [
                  Expanded(
                    child: _HubTile(
                      title: 'Studien & News',
                      subtitle: 'Aktuelle Forschung',
                      icon: CupertinoIcons.lab_flask,
                      onTap: () => Navigator.of(context).pushNamed('/studien'),
                      bg: card, fg: white, sub: sub, stroke: line, accent: violet,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _HubTile(
                      title: 'Leseliste',
                      subtitle: 'Später weiterlesen',
                      icon: CupertinoIcons.bookmark,
                      onTap: () => Navigator.of(context).pushNamed('/reading_list'),
                      bg: card, fg: white, sub: sub, stroke: line, accent: violet,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Themen
              const _SectionHeader('Themen'),
              _HubTile(
                title: 'Grundlagen des Klarträumens',
                subtitle: 'Was, warum, wie starten',
                icon: CupertinoIcons.info_circle,
                onTap: () => _openMd(context, 'assets/wissen/grundlagen_de.md'),
                bg: card, fg: white, sub: sub, stroke: line, accent: violet,
              ),
              _HubTile(
                title: 'Techniken',
                subtitle: 'MILD, WILD, Reality Checks u. a.',
                icon: CupertinoIcons.sparkles,
                onTap: () => _openMd(context, 'assets/wissen/techniken_de.md'),
                bg: card, fg: white, sub: sub, stroke: line, accent: violet,
              ),
              _HubTile(
                title: 'Neuro & Schlaf',
                subtitle: 'REM-Schlaf, Gedächtnis, Gehirnmechanismen',
                icon: CupertinoIcons.lab_flask,
                onTap: () => _openMd(context, 'assets/wissen/neuro_sleep_de.md'),
                bg: card, fg: white, sub: sub, stroke: line, accent: violet,
              ),
              _HubTile(
                title: 'Journal Guide',
                subtitle: 'Traumtagebuch wie ein Profi',
                icon: CupertinoIcons.book,
                onTap: () => _openMd(context, 'assets/wissen/journal_guide_de.md'),
                bg: card, fg: white, sub: sub, stroke: line, accent: violet,
              ),
              _HubTile(
                title: 'Albträume & IRT',
                subtitle: 'Sicher mit Träumen arbeiten',
                icon: CupertinoIcons.moon_zzz,
                onTap: () => _openMd(context, 'assets/wissen/nightmare_irt_de.md'),
                bg: card, fg: white, sub: sub, stroke: line, accent: violet,
              ),
              _HubTile(
                title: 'Wearables & Erkennung',
                subtitle: 'Signale, Erkennung, Grenzen',
                icon: CupertinoIcons.time,
                onTap: () => _openMd(context, 'assets/wissen/wearables_detection_de.md'),
                bg: card, fg: white, sub: sub, stroke: line, accent: violet,
              ),
              _HubTile(
                title: 'Ethik & Risiken',
                subtitle: 'Verantwortung & Best Practices',
                icon: CupertinoIcons.shield_lefthalf_fill,
                onTap: () => _openMd(context, 'assets/wissen/ethics_risks_de.md'),
                bg: card, fg: white, sub: sub, stroke: line, accent: violet,
              ),
              _HubTile(
                title: 'Troubleshooting',
                subtitle: 'Blockaden lösen, Fortschritt sichern',
                icon: CupertinoIcons.wrench,
                onTap: () => _openMd(context, 'assets/wissen/troubleshooting_de.md'),
                bg: card, fg: white, sub: sub, stroke: line, accent: violet,
              ),
              _HubTile(
                title: 'FAQ – Häufige Fragen',
                subtitle: 'Kurz & prägnant',
                icon: CupertinoIcons.question_circle,
                onTap: () => Navigator.of(context).pushNamed('/wissen/faq_basics'),
                bg: card, fg: white, sub: sub, stroke: line, accent: violet,
              ),
              _HubTile(
                title: 'Glossar',
                subtitle: 'Begriffe von A–Z',
                icon: CupertinoIcons.textformat_abc,
                onTap: () => _openMd(context, 'assets/wissen/glossary_de.md'),
                bg: card, fg: white, sub: sub, stroke: line, accent: violet,
              ),
              _HubTile(
                title: 'Quellen & Zitate',
                subtitle: 'Literatur & Referenzen',
                icon: CupertinoIcons.doc_text_search,
                onTap: () => _openMd(context, 'assets/wissen/citations_de.md'),
                bg: card, fg: white, sub: sub, stroke: line, accent: violet,
              ),

              const SizedBox(height: 20),

              // FAQ Accordion – kompakt
              const _SectionHeader('Schnelle Antworten'),
              _FaqAccordion(
                items: const [
                  FaqItem(
                    q: 'Was ist ein Klartraum?',
                    a: 'Ein Klartraum ist ein Traum, in dem du erkennst, dass du träumst, '
                       'und den Traumverlauf oft gezielt beeinflussen kannst.',
                  ),
                  FaqItem(
                    q: 'Brauche ich ein Traumtagebuch?',
                    a: 'Ja, es ist einer der stärksten Prädiktoren für Fortschritt. '
                       'Tägliche Notizen schärfen Erinnerung & Traumbewusstsein.',
                  ),
                  FaqItem(
                    q: 'Wie starte ich am besten?',
                    a: 'Starte mit Reality Checks + Journal. Später MILD/WBTB ergänzen. '
                       'Kleine, konsistente Schritte schlagen seltene Marathon-Sessions.',
                  ),
                  FaqItem(
                    q: 'Sind Klarträume sicher?',
                    a: 'Für gesunde Menschen in der Regel ja. Achte auf Schlafhygiene. '
                       'Bei Schlafstörungen/Traumata bitte ärztlichen Rat einholen.',
                  ),
                  FaqItem(
                    q: 'Wie oft sollte ich Reality Checks machen?',
                    a: 'Qualität vor Quantität: 8–12 bewusste Checks/Tag, kontextbasiert '
                       '(Auslöser definieren, nicht nur „Zählen“).',
                  ),
                  FaqItem(
                    q: 'Was, wenn ich nicht einschlafen kann?',
                    a: 'Techniken zeitlich dosieren (z. B. WBTB seltener), Entspannung '
                       'priorisieren, Koffein & Bildschirm am Abend reduzieren.',
                  ),
                ],
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _openMd(BuildContext context, String assetPath) {
    Navigator.of(context).pushNamed('/wissen/article', arguments: assetPath);
  }
}

/// Kleiner Abschnittstitel
class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Text(
        '',
        style: TextStyle(color: Color(0xFFE9EAFF), fontSize: 14, fontWeight: FontWeight.w700),
      ),
    )._with(text);
  }
}

extension on Widget {
  Widget _with(String text) {
    if (this is Padding) {
      final p = this as Padding;
      final child = p.child;
      if (child is Text) {
        return Padding(
          padding: p.padding,
          child: Text(
            text,
            style: child.style,
          ),
        );
      }
    }
    return this;
  }
}

/// Kachel für Themen & Schnellzugriffe (Cupertino-Style, dunkle Card)
class _HubTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final VoidCallback onTap;

  final Color bg, fg, sub, stroke, accent;

  const _HubTile({
    required this.title,
    required this.icon,
    required this.onTap,
    this.subtitle,
    required this.bg,
    required this.fg,
    required this.sub,
    required this.stroke,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: stroke, width: .6),
      ),
      child: CupertinoButton(
        padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
        onPressed: onTap,
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: accent.withOpacity(.15),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Icon(icon, color: accent, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                        color: fg, fontSize: 16, fontWeight: FontWeight.w700)),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitle!,
                        style: TextStyle(color: sub, fontSize: 13, height: 1.25)),
                  ],
                ],
              ),
            ),
            const Icon(CupertinoIcons.chevron_right, color: Color(0xFFE9EAFF), size: 18),
          ],
        ),
      ),
    );
  }
}

/* ------------------------------  FAQ Accordion  ------------------------------ */

class FaqItem {
  final String q;
  final String a;
  const FaqItem({required this.q, required this.a});
}

class _FaqAccordion extends StatefulWidget {
  final List<FaqItem> items;
  const _FaqAccordion({required this.items});

  @override
  State<_FaqAccordion> createState() => _FaqAccordionState();
}

class _FaqAccordionState extends State<_FaqAccordion>
    with TickerProviderStateMixin {
  late final List<bool> _open;

  @override
  void initState() {
    super.initState();
    _open = List<bool>.filled(widget.items.length, false);
  }

  @override
  Widget build(BuildContext context) {
    const card  = Color(0xFF0F1220);
    const line  = Color(0x33FFFFFF);
    const text  = Color(0xFFFFFFFF);
    const sub   = Color(0xFFB8C0E8);

    return Column(
      children: [
        for (int i = 0; i < widget.items.length; i++)
          _FaqTile(
            item: widget.items[i],
            open: _open[i],
            onToggle: () {
              setState(() => _open[i] = !_open[i]);
            },
            bg: card, stroke: line, fg: text, sub: sub,
          ),
      ],
    );
  }
}

class _FaqTile extends StatelessWidget {
  final FaqItem item;
  final bool open;
  final VoidCallback onToggle;
  final Color bg, stroke, fg, sub;

  const _FaqTile({
    required this.item,
    required this.open,
    required this.onToggle,
    required this.bg,
    required this.stroke,
    required this.fg,
    required this.sub,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: stroke, width: .6),
      ),
      child: CupertinoButton(
        padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
        onPressed: onToggle,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(item.q,
                      style: TextStyle(
                        color: fg, fontSize: 15.5, fontWeight: FontWeight.w700)),
                ),
                AnimatedRotation(
                  turns: open ? .5 : 0,
                  duration: const Duration(milliseconds: 180),
                  child: const Icon(CupertinoIcons.chevron_down,
                      color: Color(0xFFE9EAFF), size: 18),
                ),
              ],
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              child: open
                  ? Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Column(
                        children: [
                          const SizedBox(height: 2),
                          const DividerCupertino(),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              item.a,
                              style: TextStyle(color: sub, height: 1.45, fontSize: 14.5),
                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

/// Dünne Trennlinie im dunklen Stil (Cupertino hat keinen Divider-Konstruktor)
class DividerCupertino extends StatelessWidget {
  const DividerCupertino({super.key, this.color = const Color(0x33FFFFFF), this.height = .8});
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

class WissenArticlePage extends StatefulWidget {
  final String assetPath; // z. B. assets/wissen/grundlagen_de.md
  const WissenArticlePage({super.key, required this.assetPath});

  @override
  State<WissenArticlePage> createState() => _WissenArticlePageState();
}

class _WissenArticlePageState extends State<WissenArticlePage>
    with TickerProviderStateMixin {

  Future<String> _loadMd() =>
      DefaultAssetBundle.of(context).loadString(widget.assetPath);

  // ---------- H2-Abschnitte zuverlässig extrahieren ----------
  List<_Section> _extractSections(String md) {
    var text = md;
    if (text.startsWith('\uFEFF')) text = text.substring(1); // BOM
    text = text.replaceAll('\r\n', '\n').replaceAll('\r', '\n'); // CRLF → LF

    final lines = text.split('\n');
    final headerRe = RegExp(r'^\s{0,3}##(?!#)\s+(.+?)\s*$'); // genau zwei '#'

    final sections = <_Section>[];
    int? start;
    String? currentTitle;

    for (var i = 0; i < lines.length; i++) {
      final m = headerRe.firstMatch(lines[i]);
      if (m != null) {
        if (start != null && currentTitle != null) {
          sections.add(_Section(
            title: currentTitle,
            body: lines.sublist(start, i).join('\n').trim(),
          ));
        }
        currentTitle = m.group(1)!.trim();
        start = i + 1; // Inhalt ab nächster Zeile
      }
    }
    if (start != null && currentTitle != null) {
      sections.add(_Section(
        title: currentTitle,
        body: lines.sublist(start).join('\n').trim(),
      ));
    }
    return sections;
  }

  MarkdownStyleSheet _mdStyle(BuildContext context) {
    final base = MarkdownStyleSheet.fromCupertinoTheme(CupertinoTheme.of(context));
    return base.copyWith(
      a: const TextStyle(color: Color(0xFF8FA2FF), fontWeight: FontWeight.w600),
      p: const TextStyle(color: Color(0xFFE9EAFF), height: 1.5, fontSize: 16),
      h1: const TextStyle(color: Color(0xFFFFFFFF), fontSize: 24, fontWeight: FontWeight.w800),
      h2: const TextStyle(color: Color(0xFFFFFFFF), fontSize: 20, fontWeight: FontWeight.w700),
      h3: const TextStyle(color: Color(0xFFE9EAFF), fontSize: 18, fontWeight: FontWeight.w700),
      listBullet: const TextStyle(color: Color(0xFFE9EAFF)),
      blockquoteDecoration: const BoxDecoration(
        border: Border(left: BorderSide(color: Color(0x33FFFFFF), width: 3)),
      ),
      codeblockDecoration: BoxDecoration(
        color: const Color(0x1AFFFFFF),
        borderRadius: BorderRadius.circular(10),
      ),
      blockSpacing: 14,
      horizontalRuleDecoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0x33FFFFFF), width: .5)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      // gut lesbare Leiste auf Dark
      navigationBar: const CupertinoNavigationBar(
        backgroundColor: Color(0xCC0D0F16),
        border: Border(bottom: BorderSide(color: Color(0x1FFFFFFF), width: .5)),
        previousPageTitle: 'Wissen',
        middle: Text('Artikel',
          style: TextStyle(color: Color(0xFFE9EAFF), fontWeight: FontWeight.w700)),
      ),
      child: SafeArea(
        top: false,
        child: FutureBuilder<String>(
          future: _loadMd(),
          builder: (ctx, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return const Center(child: CupertinoActivityIndicator());
            }
            if (snap.hasError || !snap.hasData) {
              return const Center(child: Text('Konnte Inhalt nicht laden.',
                  style: TextStyle(color: Color(0xFFE9EAFF))));
            }

            final md = snap.data!;
            final sections = _extractSections(md);
            final sheet = _mdStyle(context);

            // Fallback: normales Markdown, wenn keine ##-Abschnitte existieren
            if (sections.isEmpty) {
              return CupertinoScrollbar(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  children: [
                    MarkdownBody(
                      data: md,
                      styleSheet: sheet,
                      onTapLink: (text, href, title) async {
                        final uri = Uri.tryParse(href ?? '');
                        if (uri != null && await canLaunchUrl(uri)) {
                          await launchUrl(uri, mode: LaunchMode.externalApplication);
                        }
                      },
                    ),
                  ],
                ),
              );
            }

            // Accordion-Ansicht
            return _AccordionList(sections: sections, sheet: sheet);
          },
        ),
      ),
    );
  }
}

// ----- Daten & Widgets -----
class _Section {
  final String title;
  final String body;
  _Section({required this.title, required this.body});
}

class _AccordionList extends StatefulWidget {
  final List<_Section> sections;
  final MarkdownStyleSheet sheet;
  const _AccordionList({required this.sections, required this.sheet});

  @override
  State<_AccordionList> createState() => _AccordionListState();
}

class _AccordionListState extends State<_AccordionList> {
  late final List<bool> _open = List<bool>.filled(widget.sections.length, false);

  @override
  Widget build(BuildContext context) {
    return CupertinoScrollbar(
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        itemCount: widget.sections.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (ctx, i) {
          final s = widget.sections[i];
          return _AccordionItem(
            title: s.title,
            expanded: _open[i],
            onToggle: () => setState(() => _open[i] = !_open[i]),
            child: MarkdownBody(
              data: s.body,
              styleSheet: widget.sheet,
              shrinkWrap: true,
              softLineBreak: true,
              onTapLink: (text, href, title) async {
                final uri = Uri.tryParse(href ?? '');
                if (uri != null && await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
            ),
          );
        },
      ),
    );
  }
}

class _AccordionItem extends StatelessWidget {
  final String title;
  final bool expanded;
  final VoidCallback onToggle;
  final Widget child;
  const _AccordionItem({
    required this.title,
    required this.expanded,
    required this.onToggle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0x1AFFFFFF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0x14FFFFFF), width: 1),
      ),
      child: Column(
        children: [
          CupertinoButton(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            onPressed: onToggle,
            child: Row(
              children: [
                Expanded(child: Text(title,
                  style: const TextStyle(
                    color: Color(0xFFFFFFFF),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ))),
                const SizedBox(width: 8),
                Transform.rotate(
                  angle: expanded ? 3.1416/2 : 0,
                  child: const Icon(CupertinoIcons.chevron_right,
                      color: Color(0xFFE9EAFF), size: 18),
                ),
              ],
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: child,
            ),
            crossFadeState:
                expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 180),
            sizeCurve: Curves.easeInOutCubic,
          ),
        ],
      ),
    );
  }
}

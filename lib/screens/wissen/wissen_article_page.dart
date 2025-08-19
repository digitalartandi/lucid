import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_markdown/flutter_markdown.dart';

class WissenArticlePage extends StatefulWidget {
  final String assetPath;
  const WissenArticlePage({super.key, required this.assetPath});

  @override
  State<WissenArticlePage> createState() => _WissenArticlePageState();
}

class _WissenArticlePageState extends State<WissenArticlePage> {
  String? _raw;
  String _title = 'Artikel';
  String _intro = '';
  late List<_QaSection> _sections = [];
  bool _expandedAll = false;

  @override
  void initState() {
    super.initState();
    _loadMd();
  }

  Future<void> _loadMd() async {
    final md = await rootBundle.loadString(widget.assetPath);
    final parsed = _parseMd(md);
    setState(() {
      _raw = md;
      _title = parsed.title;
      _intro = parsed.intro;
      _sections = parsed.sections;
    });
  }

  // ---------- Parsen: H1 = Seitentitel, vor dem ersten "## " = Intro, dann Q&A-Blöcke ----------
  _Parsed _parseMd(String md) {
    final lines = md.split(RegExp(r'\r?\n'));
    String title = 'Artikel';
    final bufIntro = StringBuffer();
    final sections = <_QaSection>[];

    String? currentQ;
    final bufA = StringBuffer();

    bool seenAnySection = false;

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];

      // H1 als Title, falls vorhanden
      if (i == 0 && line.trim().startsWith('# ')) {
        title = line.trim().substring(2).trim();
        continue; // Title-Zeile nicht weiterverarbeiten
      }

      // Neuer Frageblock?
      if (line.startsWith('## ')) {
        // alten Block abschließen
        if (currentQ != null) {
          sections.add(_QaSection(
            question: currentQ,
            answerMd: bufA.toString().trim(),
          ));
          bufA.clear();
        } else {
          // bis hierher war Intro
          seenAnySection = true;
        }
        currentQ = line.substring(3).trim();
      } else {
        if (currentQ == null) {
          // noch vor dem ersten "## " → Intro
          if (!seenAnySection) bufIntro.writeln(line);
        } else {
          bufA.writeln(line);
        }
      }
    }

    // letzten Block hinzufügen
    if (currentQ != null) {
      sections.add(_QaSection(
        question: currentQ,
        answerMd: bufA.toString().trim(),
      ));
    }

    return _Parsed(
      title: title,
      intro: bufIntro.toString().trim(),
      sections: sections,
    );
  }

  void _toggleAll(bool expand) {
    setState(() {
      _expandedAll = expand;
      for (final s in _sections) {
        s.expanded = expand;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(_title),
        trailing: _sections.isEmpty
            ? null
            : CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => _toggleAll(!_expandedAll),
                child: Text(_expandedAll ? 'Alle schließen' : 'Alle öffnen'),
              ),
      ),
      child: _raw == null
          ? const Center(child: CupertinoActivityIndicator())
          : SafeArea(
              top: false,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
                children: [
                  // Intro-Abschnitt (optional)
                  if (_intro.isNotEmpty)
                    _IntroCard(markdown: _intro),

                  // Kein "##" gefunden → normale Markdown-Seite als Fallback
                  if (_sections.isEmpty) ...[
                    const SizedBox(height: 8),
                    MarkdownBody(
                      data: _raw!,
                      styleSheet: MarkdownStyleSheet.fromCupertinoTheme(
                        CupertinoTheme.of(context),
                      ).copyWith(
                        p: const TextStyle(fontSize: 16),
                        h2: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ] else ...[
                    const SizedBox(height: 8),
                    for (final s in _sections)
                      _AccordionTile(
                        section: s,
                        onToggle: () => setState(() => s.expanded = !s.expanded),
                      ),
                  ],
                ],
              ),
            ),
    );
  }
}

// ---------- Widgets ----------

class _IntroCard extends StatelessWidget {
  final String markdown;
  const _IntroCard({required this.markdown});

  @override
  Widget build(BuildContext context) {
    // Schlichte, klare Karte ohne „Glass“
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF111426),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0x22FFFFFF)),
      ),
      child: MarkdownBody(
        data: markdown,
        styleSheet: MarkdownStyleSheet.fromCupertinoTheme(
          CupertinoTheme.of(context),
        ).copyWith(p: const TextStyle(fontSize: 16, height: 1.35)),
      ),
    );
  }
}

class _AccordionTile extends StatelessWidget {
  final _QaSection section;
  final VoidCallback onToggle;

  const _AccordionTile({required this.section, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final chevron = section.expanded
        ? CupertinoIcons.chevron_down
        : CupertinoIcons.chevron_right;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1220),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0x22FFFFFF)),
      ),
      child: Column(
        children: [
          // Kopfzeile – große Tippfläche
          CupertinoButton(
            padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
            onPressed: onToggle,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    section.question,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: CupertinoColors.white,
                    ),
                  ),
                ),
                Icon(chevron, size: 18, color: const Color(0xFFB8C0E8)),
              ],
            ),
          ),

          // Inhalt – weich animiert
          AnimatedCrossFade(
            crossFadeState: section.expanded
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            duration: const Duration(milliseconds: 180),
            firstChild: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: MarkdownBody(
                data: section.answerMd,
                styleSheet: MarkdownStyleSheet.fromCupertinoTheme(
                  CupertinoTheme.of(context),
                ).copyWith(
                  p: const TextStyle(fontSize: 15, height: 1.4, color: CupertinoColors.white),
                  a: const TextStyle(
                    fontSize: 15,
                    decoration: TextDecoration.underline,
                    color: Color(0xFF7A6CFF), // Primärviolett
                  ),
                  listBullet: const TextStyle(fontSize: 15, color: CupertinoColors.white),
                ),
              ),
            ),
            secondChild: const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

// ---------- Modelle ----------

class _QaSection {
  final String question;
  final String answerMd;
  bool expanded;
  _QaSection({
    required this.question,
    required this.answerMd,
    this.expanded = false,
  });
}

class _Parsed {
  final String title;
  final String intro;
  final List<_QaSection> sections;
  _Parsed({required this.title, required this.intro, required this.sections});
}

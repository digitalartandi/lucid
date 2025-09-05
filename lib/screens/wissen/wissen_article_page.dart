// lib/screens/wissen/wissen_article_page.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Divider; // nur für eine dünne Linie
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_markdown/flutter_markdown.dart';

class WissenArticlePage extends StatefulWidget {
  final String assetPath; // z.B. assets/wissen/grundlagen_de.md
  const WissenArticlePage({super.key, required this.assetPath});

  @override
  State<WissenArticlePage> createState() => _WissenArticlePageState();
}

class _WissenArticlePageState extends State<WissenArticlePage> {
  String? _raw;              // kompletter Markdown-Text
  String _title = 'Artikel'; // aus erster "# " Überschrift, falls vorhanden
  late Future<void> _loadF;

  @override
  void initState() {
    super.initState();
    _loadF = _load();
  }

  Future<void> _load() async {
    final raw = await rootBundle.loadString(widget.assetPath);
    String t = _title;
    // Titel aus der ersten H1 ziehen (falls vorhanden)
    final lines = raw.split('\n');
    for (final l in lines) {
      final s = l.trimLeft();
      if (s.startsWith('# ')) {
        t = s.substring(2).trim();
        break;
      }
    }
    setState(() {
      _raw = raw;
      _title = t;
    });
  }

  // Heuristik: Aus Markdown Q&A-Sektionen bauen.
  // Annahme: Frage = Zeile, die mit '?' endet (und keine Überschrift ist).
  List<_QA> _parseQA(String md) {
    final out = <_QA>[];
    final ls = md.split('\n');

    String? currentQ;
    final buf = StringBuffer();

    void flush() {
      if (currentQ != null) {
        out.add(_QA(question: currentQ!, answerMd: buf.toString().trim()));
        currentQ = null;
        buf.clear();
      }
    }

    for (var raw in ls) {
      final l = raw.trimRight();

      // harte Trenner resetten
      if (l.startsWith('# ')) {
        // H1 – als globalen Titel nutzen, nicht als Frage
        // vorigen Block abschließen
        flush();
        continue;
      }

      final isQuestion = l.isNotEmpty &&
          l.endsWith('?') &&
          !l.startsWith('#') &&
          !l.startsWith('- ') &&
          !l.startsWith('* ') &&
          !l.startsWith('> ');

      if (isQuestion) {
        // Neue Frage beginnt -> vorherigen Block abschließen
        flush();
        currentQ = l.trim();
      } else {
        // Antwortzeilen sammeln (inkl. Leerzeilen)
        if (currentQ != null) {
          buf.writeln(l);
        }
      }
    }
    flush();

    // Manche Dateien haben evtl. nur wenige echte Fragen → Accordion wäre sinnlos
    return out;
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFF101323);
    const card = Color(0x141A1F2E); // leicht transparent
    const border = Color(0x33FFFFFF);
    const title = Color(0xFFE9EAFF);

    return CupertinoPageScaffold(
      backgroundColor: bg,
      navigationBar: CupertinoNavigationBar(
        middle: Text(_title, style: const TextStyle(color: title)),
      ),
      child: FutureBuilder<void>(
        future: _loadF,
        builder: (context, snap) {
          if (_raw == null) {
            return const Center(child: CupertinoActivityIndicator());
          }

          final qas = _parseQA(_raw!);
          final showAccordion = qas.length >= 3; // nur wenn sinnvoll

          if (!showAccordion) {
            // Fallback: klassischer Markdown-Artikel
            return SafeArea(
              bottom: false,
              child: Markdown(
                data: _raw!,
                selectable: false,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                styleSheet: MarkdownStyleSheet.fromCupertinoTheme(
                  CupertinoTheme.of(context),
                ).copyWith(
                  p: const TextStyle(color: title, height: 1.4),
                  h1: const TextStyle(
                    color: title, fontSize: 24, fontWeight: FontWeight.w700),
                ),
              ),
            );
          }

          // Accordion-Darstellung
          return SafeArea(
            bottom: false,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 28),
              itemCount: qas.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                return _AccordionTile(
                  question: qas[i].question,
                  answerMd: qas[i].answerMd,
                  card: card,
                  border: border,
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _QA {
  final String question;
  final String answerMd;
  _QA({required this.question, required this.answerMd});
}

class _AccordionTile extends StatefulWidget {
  final String question;
  final String answerMd;
  final Color card;
  final Color border;

  const _AccordionTile({
    super.key,
    required this.question,
    required this.answerMd,
    required this.card,
    required this.border,
  });

  @override
  State<_AccordionTile> createState() => _AccordionTileState();
}

class _AccordionTileState extends State<_AccordionTile> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    const qStyle = TextStyle(
      color: Color(0xFFE9EAFF),
      fontSize: 16,
      fontWeight: FontWeight.w600,
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          color: widget.card,
          border: Border.all(color: widget.border, width: 0.7),
          borderRadius: BorderRadius.circular(14),
        ),
        child: CupertinoButton(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          onPressed: () => setState(() => _open = !_open),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Kopfzeile (Frage)
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(child: Text(widget.question, style: qStyle)),
                  const SizedBox(width: 8),
                  Icon(
                    _open ? CupertinoIcons.chevron_up : CupertinoIcons.chevron_down,
                    size: 18,
                    color: const Color(0xFFB8C0E8),
                  ),
                ],
              ),
              // Inhalt
              AnimatedCrossFade(
                crossFadeState:
                    _open ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                duration: const Duration(milliseconds: 180),
                firstChild: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: MarkdownBody(
                    data: widget.answerMd.trim().isEmpty
                        ? '_Keine Details verfügbar._'
                        : widget.answerMd.trim(),
                    styleSheet: MarkdownStyleSheet.fromCupertinoTheme(
                      CupertinoTheme.of(context),
                    ).copyWith(
                      p: const TextStyle(
                        color: Color(0xFFE9EAFF),
                        height: 1.4,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
                secondChild: const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

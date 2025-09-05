// lib/screens/wissen/wissen_article_page.dart
import 'dart:convert' show utf8;
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
  String? _md;
  String _title = 'Artikel';
  late Future<void> _loadF;

  @override
  void initState() {
    super.initState();
    _loadF = _load();
  }

  Future<void> _load() async {
    final bytes = await rootBundle.load(widget.assetPath);
    final md = utf8.decode(bytes.buffer.asUint8List());
    final lines = md.split(RegExp(r'\r?\n'));
    // Titel aus erster Markdown-H1 übernehmen, wenn vorhanden
    final h1 = lines.firstWhere(
      (l) => l.trim().startsWith('# '),
      orElse: () => '',
    );
    if (h1.isNotEmpty) {
      _title = h1.replaceFirst(RegExp(r'^#\s*'), '').trim();
    }
    setState(() => _md = md);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(middle: Text(_title)),
      child: SafeArea(
        top: false,
        child: FutureBuilder<void>(
          future: _loadF,
          builder: (_, snap) {
            if (_md == null) {
              return const Center(child: CupertinoActivityIndicator());
            }

            final faqs = _tryParseFaq(_md!);
            if (faqs.length >= 3) {
              // Accordion-Ansicht
              return _FaqView(items: faqs);
            }

            // Fallback: normale Markdown-Ansicht
            return Markdown(
              data: _md!,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              selectable: false,
              styleSheet: MarkdownStyleSheet.fromCupertinoTheme(
                CupertinoTheme.of(context),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Einfache Struktur für Frage/Antwort
class _FaqItem {
  _FaqItem(this.question, this.answer);
  final String question; // reine Frage (eine Zeile)
  final String answer;   // Markdown (mehrere Zeilen)
}

/// Heuristik: Erzeuge FAQ-Blöcke aus Markdown.
/// Regeln:
/// - Eine Zeile, die mit '## ' / '### ' beginnt ODER mit '?' endet, gilt als Frage.
/// - Antwort = nachfolgende Zeilen bis zur nächsten Frage oder Dateiende.
/// - Überschrift '# ' (Titel) wird ignoriert.
List<_FaqItem> _tryParseFaq(String md) {
  final lines = md.split(RegExp(r'\r?\n'));

  // Start nach erster H1 (falls vorhanden)
  int i = 0;
  if (lines.isNotEmpty && lines.first.trim().startsWith('# ')) {
    i = 1;
  }

  final items = <_FaqItem>[];

  bool isQuestionLine(String s) {
    final t = s.trimLeft();
    if (t.startsWith('## ')) return true;
    if (t.startsWith('### ')) return true;
    // einfache Fragezeile
    return t.isNotEmpty && t.endsWith('?');
  }

  String cleanQuestion(String s) {
    var t = s.trim();
    t = t.replaceFirst(RegExp(r'^#{2,}\s*'), ''); // '## ' / '### ' entfernen
    return t;
  }

  while (i < lines.length) {
    final line = lines[i];
    if (!isQuestionLine(line)) {
      i++;
      continue;
    }

    final q = cleanQuestion(line);
    i++;

    final buf = <String>[];
    // sammle Antwort bis zur nächsten Frage
    while (i < lines.length && !isQuestionLine(lines[i])) {
      buf.add(lines[i]);
      i++;
    }
    // überflüssige Leerzeilen am Anfang/Ende kürzen
    while (buf.isNotEmpty && buf.first.trim().isEmpty) buf.removeAt(0);
    while (buf.isNotEmpty && buf.last.trim().isEmpty) buf.removeLast();

    final a = buf.join('\n').trim();
    if (q.isNotEmpty && a.isNotEmpty) {
      items.add(_FaqItem(q, a));
    }
  }
  return items;
}

/// Cupertino-Accordion für FAQ
class _FaqView extends StatefulWidget {
  const _FaqView({required this.items});
  final List<_FaqItem> items;

  @override
  State<_FaqView> createState() => _FaqViewState();
}

class _FaqViewState extends State<_FaqView> {
  late final List<bool> _open;

  @override
  void initState() {
    super.initState();
    _open = List<bool>.filled(widget.items.length, false);
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
      itemCount: widget.items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final it = widget.items[i];
        final expanded = _open[i];

        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0A0A23),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0x22FFFFFF)),
          ),
          child: Column(
            children: [
              CupertinoButton(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                onPressed: () => setState(() => _open[i] = !expanded),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        it.question,
                        style: const TextStyle(
                          color: Color(0xFFE9EAFF),
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      expanded ? CupertinoIcons.chevron_down : CupertinoIcons.chevron_right,
                      size: 16,
                      color: const Color(0xFFB8C0E8),
                    ),
                  ],
                ),
              ),
              AnimatedCrossFade(
                firstChild: const SizedBox.shrink(),
                secondChild: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  child: MarkdownBody(
                    data: it.answer,
                    styleSheet: MarkdownStyleSheet.fromCupertinoTheme(
                      CupertinoTheme.of(context),
                    ),
                  ),
                ),
                crossFadeState:
                    expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 180),
              ),
            ],
          ),
        );
      },
    );
  }
}

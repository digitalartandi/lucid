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
    var md = utf8.decode(bytes.buffer.asUint8List());

    // Alte, versehentlich „ge-escapte“ Überschriften wie "\## Titel" reparieren
    md = md.replaceAllMapped(
      RegExp(r'^\s*\\(#{1,6}\s)', multiLine: true),
      (m) => m[1]!,
    );

    // Seitentitel aus erster H1
    final lines = md.split(RegExp(r'\r?\n'));
    final h1 = lines.firstWhere((l) => l.trim().startsWith('# '), orElse: () => '');
    if (h1.isNotEmpty) {
      _title = h1.replaceFirst(RegExp(r'^#\s*'), '').trim();
    }
    setState(() => _md = md);
  }

  // Welche Seiten sollen grundsätzlich Accordion nutzen?
  bool _wantsAccordion(String path) {
    final p = path.toLowerCase();
    return p.contains('grundlagen') ||
        p.contains('techniken') ||
        p.contains('neuro') ||
        p.contains('journal') ||
        p.contains('albtraeume') ||
        p.contains('albträume') || // falls Umlaute im Pfad
        p.contains('nightmare') ||
        p.contains('irt') ||
        p.contains('wearables') ||
        p.contains('erkennung') ||
        p.contains('detection') ||
        p.contains('ethik') ||
        p.contains('ethics') ||
        p.contains('troubleshoot') ||
        p.contains('faq') ||
        p.contains('glossar') ||
        p.contains('glossary') ||
        p.contains('quellen') ||
        p.contains('literatur') ||
        p.contains('citations');
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(middle: Text(_title)),
      child: SafeArea(
        top: true,
        child: FutureBuilder<void>(
          future: _loadF,
          builder: (_, __) {
            if (_md == null) {
              return const Center(child: CupertinoActivityIndicator());
            }

            final wantsAcc = _wantsAccordion(widget.assetPath);

            // 1) Versuche Q&A-Accordion (für echte Fragen-Seiten)
            final faqs = wantsAcc ? _tryParseFaq(_md!) : const <_FaqItem>[];
            if (faqs.length >= 3) {
              return _FaqView(items: faqs);
            }

            // 2) Sonst Abschnitts-Accordion anhand H2/H3
            final sections = wantsAcc ? _parseSections(_md!) : const <_Section>[];
            if (sections.length >= 2) {
              return _SectionView(items: sections);
            }

            // 3) Fallback: normales Markdown
            return Markdown(
              data: _md!,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              selectable: false,
              styleSheet: _mdWhite(context),
            );
          },
        ),
      ),
    );
  }
}

/* ---------- FAQ (Q&A) Parser & View ---------- */

class _FaqItem {
  _FaqItem(this.question, this.answer);
  final String question;
  final String answer;
}

List<_FaqItem> _tryParseFaq(String md) {
  final lines = md.split(RegExp(r'\r?\n'));
  int i = 0;
  if (lines.isNotEmpty && lines.first.trim().startsWith('# ')) i = 1;

  final items = <_FaqItem>[];

  bool isQ(String s) {
    final t = s.trimLeft();
    if (t.startsWith('## ') || t.startsWith('### ')) return true;
    return t.isNotEmpty && t.trimRight().endsWith('?');
  }

  String cleanQ(String s) {
    var q = s.trim().replaceFirst(RegExp(r'^#{2,3}\s*'), '');
    q = q.replaceAll(r'\&', '&').replaceAll(r'\*', '*');
    return q;
  }

  while (i < lines.length) {
    if (!isQ(lines[i])) {
      i++;
      continue;
    }
    final q = cleanQ(lines[i++]);

    final buf = <String>[];
    while (i < lines.length && !isQ(lines[i])) buf.add(lines[i++]);

    while (buf.isNotEmpty && buf.first.trim().isEmpty) buf.removeAt(0);
    while (buf.isNotEmpty && buf.last.trim().isEmpty) buf.removeLast();

    final a = buf.join('\n').trim();
    if (q.isNotEmpty && a.isNotEmpty) items.add(_FaqItem(q, a));
  }
  return items;
}

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
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => setState(() => _open[i] = !expanded),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Row(
                    children: [
                      const SizedBox(width: 2),
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
              ),
              AnimatedCrossFade(
                firstChild: const SizedBox.shrink(),
                secondChild: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  child: MarkdownBody(
                    data: it.answer,
                    styleSheet: _mdWhite(context),
                  ),
                ),
                crossFadeState: expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 180),
              ),
            ],
          ),
        );
      },
    );
  }
}

/* ---------- Abschnitts-Parser (H2/H3 → Kacheln) ---------- */

class _Section {
  _Section(this.title, this.bodyMd);
  final String title;
  final String bodyMd;
}

// Schneidet den H1-Kopf ab und baut Abschnitte aus H2/H3
List<_Section> _parseSections(String md) {
  final lines = md.split(RegExp(r'\r?\n'));
  final items = <_Section>[];

  int i = 0;
  if (lines.isNotEmpty && lines.first.trim().startsWith('# ')) i = 1;

  String? currentTitle;
  final buf = <String>[];

  void push() {
    if (currentTitle == null) return;
    final body = buf.join('\n').trim();
    if (body.isNotEmpty) {
      items.add(_Section(currentTitle!, body));
    }
    currentTitle = null;
    buf.clear();
  }

  String cleanTitle(String s) {
    var t = s.trim().replaceFirst(RegExp(r'^#{2,3}\s*'), '');
    t = t.replaceAll(r'\&', '&').replaceAll(r'\*', '*');
    return t;
  }

  while (i < lines.length) {
    final l = lines[i];

    if (RegExp(r'^\s*#{2,3}\s').hasMatch(l)) {
      // Neuer Abschnitt
      push();
      currentTitle = cleanTitle(l);
    } else {
      buf.add(l);
    }
    i++;
  }
  push();

  return items;
}

class _SectionView extends StatefulWidget {
  const _SectionView({required this.items});
  final List<_Section> items;

  @override
  State<_SectionView> createState() => _SectionViewState();
}

class _SectionViewState extends State<_SectionView> {
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
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => setState(() => _open[i] = !expanded),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Row(
                    children: [
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          it.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
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
              ),
              AnimatedCrossFade(
                firstChild: const SizedBox.shrink(),
                secondChild: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  child: MarkdownBody(
                    data: it.bodyMd,
                    styleSheet: _mdWhite(context),
                  ),
                ),
                crossFadeState: expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 180),
              ),
            ],
          ),
        );
      },
    );
  }
}

/* ---------- Einheitliches Markdown-Stylesheet ---------- */

MarkdownStyleSheet _mdWhite(BuildContext context) {
  const white = Color(0xFFE9EAFF);
  final base = MarkdownStyleSheet.fromCupertinoTheme(CupertinoTheme.of(context));

  return base.copyWith(
    p: base.p!.copyWith(color: white, height: 1.35),
    em: base.em!.copyWith(color: white),
    strong: base.strong!.copyWith(color: white),
    code: base.code!.copyWith(color: white),
    a: base.a!.copyWith(color: white),

    h1: base.h1!.copyWith(color: white),
    h2: base.h2!.copyWith(color: white),
    h3: base.h3!.copyWith(color: white),
    h4: base.h4!.copyWith(color: white),
    h5: base.h5!.copyWith(color: white),
    h6: base.h6!.copyWith(color: white),

    listBullet: const TextStyle(color: white),

    blockquote: base.blockquote!.copyWith(color: white),
    blockquotePadding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
    blockquoteDecoration: BoxDecoration(
      color: const Color(0x1AFFFFFF),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: const Color(0x22FFFFFF)),
    ),

    horizontalRuleDecoration: const BoxDecoration(color: Color(0x33FFFFFF)),
  );
}

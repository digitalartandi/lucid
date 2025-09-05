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
    final h1 = lines.firstWhere((l) => l.trim().startsWith('# '), orElse: () => '');
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
          builder: (_, __) {
            if (_md == null) {
              return const Center(child: CupertinoActivityIndicator());
            }

            final faqs = _tryParseFaq(_md!);
            if (faqs.length >= 3) {
              return _FaqView(items: faqs);
            }

            return Markdown(
              data: _md!,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              selectable: false,
              styleSheet: _mdWhite(context), // <-- weißer Text auch im Fallback
            );
          },
        ),
      ),
    );
  }
}

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
    return t.isNotEmpty && t.endsWith('?');
  }

  String cleanQ(String s) => s.trim().replaceFirst(RegExp(r'^#{2,}\s*'), '');

  while (i < lines.length) {
    if (!isQ(lines[i])) { i++; continue; }
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
              CupertinoButton(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                onPressed: () => setState(() => _open[i] = !expanded),
                child: Row(
                  children: const [
                    Expanded(
                      child: Text(
                        '',
                        // Der tatsächliche Fragetext wird unten gesetzt
                      ),
                    ),
                  ],
                ),
              ),
              // Frage-Row mit korrektem Text & Chevron
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
                    styleSheet: _mdWhite(context), // <-- HIER: weißer Text im Accordion
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

/// Einheitliches Markdown-Stylesheet mit weißer Typo
MarkdownStyleSheet _mdWhite(BuildContext context) {
  const white = Color(0xFFE9EAFF);
  final base = MarkdownStyleSheet.fromCupertinoTheme(CupertinoTheme.of(context));
  return base.copyWith(
    p: base.p!.copyWith(color: white),
    h1: base.h1!.copyWith(color: white),
    h2: base.h2!.copyWith(color: white),
    h3: base.h3!.copyWith(color: white),
    h4: base.h4!.copyWith(color: white),
    h5: base.h5!.copyWith(color: white),
    h6: base.h6!.copyWith(color: white),
    blockquote: base.blockquote!.copyWith(color: white),
    code: base.code!.copyWith(color: white),
    listBullet: const TextStyle(color: white),
  );
}

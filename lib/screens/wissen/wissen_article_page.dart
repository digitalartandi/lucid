import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

/// WissenArticlePage
/// Lädt Markdown aus [assetPath] und rendert es als Cupertino-Accordion.
///
/// Fallbacks in genau dieser Reihenfolge:
/// 1) Wenn keine "##" vorhanden, werden "###" zu "##" promotet.
/// 2) Wenn weiterhin keine "##", werden Fragezeilen (…?) zu "##" konvertiert.
/// 3) Wenn weiterhin keine "##", wird ein Wrapper-Abschnitt "## Inhalt" eingefügt.
class WissenArticlePage extends StatefulWidget {
  final String assetPath;
  const WissenArticlePage({super.key, required this.assetPath});

  @override
  State<WissenArticlePage> createState() => _WissenArticlePageState();
}

class _WissenArticlePageState extends State<WissenArticlePage> {
  late Future<_ArticleData> _loader;

  @override
  void initState() {
    super.initState();
    _loader = _loadAndParse(widget.assetPath);
  }

  @override
  Widget build(BuildContext context) {
    final bg = const Color(0xFF0E0D18);
    final hairline = const Color(0x22FFFFFF);
    final titleColor = const Color(0xFFE9EAFF);

    return CupertinoPageScaffold(
      backgroundColor: bg,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: bg.withOpacity(0.85),
        middle: Text('Wissen', style: TextStyle(color: titleColor)),
        border: const Border(bottom: BorderSide(color: Color(0x22FFFFFF), width: 0.5)),
      ),
      child: SafeArea(
        bottom: false,
        child: FutureBuilder<_ArticleData>(
          future: _loader,
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return const _Loading();
            }
            if (snap.hasError || snap.data == null) {
              return _ErrorView(error: snap.error);
            }
            final data = snap.data!;
            return _ArticleView(data: data, hairline: hairline);
          },
        ),
      ),
    );
  }

  Future<_ArticleData> _loadAndParse(String assetPath) async {
    final raw = await rootBundle.loadString(assetPath);
    final normalized = _normalizeLineEndings(_stripBom(raw));

    // Erstversuch
    var parsed = _parseMarkdownIntoSections(normalized);
    if (parsed.sections.isNotEmpty) return parsed;

    // Fallback 1: ### -> ##
    final promoted = _normalizeLineEndings(
      normalized.replaceAll(RegExp(r'^\s{0,3}###(?!#)\s+', multiLine: true), '## '),
    );
    parsed = _parseMarkdownIntoSections(promoted);
    if (parsed.sections.isNotEmpty) return parsed;

    // Fallback 2: Fragezeilen (? am Ende) -> ##
    final questionPromoted = _promoteQuestionLinesToH2(promoted);
    parsed = _parseMarkdownIntoSections(questionPromoted);
    if (parsed.sections.isNotEmpty) return parsed;

    // Fallback 3: Wrapper "## Inhalt"
    final withWrapper = _injectWrapperInhalt(promoted);
    parsed = _parseMarkdownIntoSections(withWrapper);
    return parsed.sections.isNotEmpty
        ? parsed
        : _ArticleData(h1Title: parsed.h1Title, sections: [
            _Section('Inhalt', normalized) // absoluter Fallback
          ]);
  }
}

// ------------------------- Datenmodell -------------------------

class _ArticleData {
  final String? h1Title;
  final List<_Section> sections;
  _ArticleData({required this.h1Title, required this.sections});
}

class _Section {
  final String title;
  final String bodyMd;
  _Section(this.title, this.bodyMd);
}

// ------------------------- Parsing / Heuristik -------------------------

// Robuste Regex wie im Handover spezifiziert
final _h2Regex = RegExp(r'^\s{0,3}##(?!#)\s+(.+?)\s*$', multiLine: true);
final _h1Regex = RegExp(r'^\s{0,3}#(?!#)\s+(.+?)\s*$', multiLine: true);
// Fragezeilen (vorsichtig; max ~120 Zeichen)
final _questionLine = RegExp(r'^\s*(\*\*|__)?(.{1,120}\?)\s*(\*\*|__)?\s*$');

String _stripBom(String s) {
  if (s.isNotEmpty && s.codeUnitAt(0) == 0xFEFF) return s.substring(1);
  return s;
}

String _normalizeLineEndings(String s) => s.replaceAll('\r\n', '\n').replaceAll('\r', '\n');

String _injectWrapperInhalt(String text) {
  final h1 = _h1Regex.firstMatch(text);
  if (h1 != null) {
    final idx = h1.end;
    return text.substring(0, idx) + '\n\n## Inhalt\n\n' + text.substring(idx).trimLeft();
  } else {
    return '## Inhalt\n\n$text';
  }
}

String _promoteQuestionLinesToH2(String text) {
  final lines = text.split('\n');
  final out = <String>[];
  for (var i = 0; i < lines.length; i++) {
    final line = lines[i];
    final prevBlank = (i == 0) || lines[i - 1].trim().isEmpty;
    final m = _questionLine.firstMatch(line);
    final isList = line.trimLeft().startsWith(RegExp(r'(-|\*|\+|>|\d+\.)\s'));
    final isFence = line.trimLeft().startsWith('```');
    if (prevBlank && m != null && !isList && !isFence) {
      final q = m.group(2)!.trim();
      out.add('## $q');
      // eine Leerzeile nach dem Heading sicherstellen
      if (i + 1 >= lines.length || lines[i + 1].trim().isNotEmpty) {
        out.add('');
      }
    } else {
      out.add(line);
    }
  }
  return out.join('\n');
}

_ArticleData _parseMarkdownIntoSections(String text) {
  String? h1Title;
  final h1m = _h1Regex.firstMatch(text);
  if (h1m != null) {
    h1Title = h1m.group(1)?.trim();
  }

  final matches = _h2Regex.allMatches(text).toList();
  if (matches.isEmpty) {
    return _ArticleData(h1Title: h1Title, sections: const []);
  }

  final sections = <_Section>[];
  for (var i = 0; i < matches.length; i++) {
    final m = matches[i];
    final title = (m.group(1) ?? '').trim();
    final start = m.end;
    final end = (i + 1 < matches.length) ? matches[i + 1].start : text.length;

    var body = text.substring(start, end).trim();
    body = body.replaceFirst(_h1Regex, '').trim(); // evtl. H1 im Body entfernen

    sections.add(_Section(title, body));
  }
  return _ArticleData(h1Title: h1Title, sections: sections);
}

// ------------------------- UI -------------------------

class _ArticleView extends StatefulWidget {
  final _ArticleData data;
  final Color hairline;
  const _ArticleView({required this.data, required this.hairline});

  @override
  State<_ArticleView> createState() => _ArticleViewState();
}

class _ArticleViewState extends State<_ArticleView> {
  final Map<int, bool> _open = {}; // Accordion-State

  @override
  Widget build(BuildContext context) {
    final titleText = widget.data.h1Title ?? 'Artikel';
    final bodyColor = const Color(0xFFE9EAFF);
    final linkColor = const Color(0xFF8FA2FF);
    final violet = const Color(0xFF7A6CFF);

    // Kein Section-Parse? Zeige Fließtext.
    if (widget.data.sections.isEmpty) {
      return CustomScrollView(
        slivers: [
          _TitleSliver(titleText),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: _MarkdownBox(
                markdown: 'Dieser Artikel wird als Fließtext angezeigt.',
                bodyColor: bodyColor,
                linkColor: linkColor,
              ),
            ),
          ),
        ],
      );
    }

    return CustomScrollView(
      slivers: [
        _TitleSliver(titleText),
        SliverList.builder(
          itemCount: widget.data.sections.length,
          itemBuilder: (context, index) {
            final s = widget.data.sections[index];
            final isOpen = _open[index] ?? index == 0; // erstes Item standardmäßig offen
            return _AccordionItem(
              index: index,
              title: s.title,
              isOpen: isOpen,
              onToggle: () => setState(() => _open[index] = !isOpen),
              child: _MarkdownBox(
                markdown: s.bodyMd,
                bodyColor: bodyColor,
                linkColor: linkColor,
              ),
              accent: violet,
              hairline: widget.data.sections.length == 1 ? widget.hairline : widget.hairline,
            );
          },
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }
}

class _TitleSliver extends StatelessWidget {
  final String title;
  const _TitleSliver(this.title);

  @override
  Widget build(BuildContext context) {
    final titleColor = const Color(0xFFE9EAFF);
    final subtitleColor = CupertinoColors.systemGrey2;
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: titleColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Klartraum · Wissen',
              style: TextStyle(
                fontSize: 13,
                color: subtitleColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccordionItem extends StatelessWidget {
  final int index;
  final String title;
  final bool isOpen;
  final VoidCallback onToggle;
  final Widget child;
  final Color accent;
  final Color hairline;

  const _AccordionItem({
    required this.index,
    required this.title,
    required this.isOpen,
    required this.onToggle,
    required this.child,
    required this.accent,
    required this.hairline,
  });

  @override
  Widget build(BuildContext context) {
    final gradient = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF141321), Color(0xFF0E0D18)],
    );
    final titleColor = const Color(0xFFE9EAFF);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: hairline, width: 0.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Column(
          children: [
            CupertinoButton(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              onPressed: onToggle,
              minSize: 44,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        color: titleColor,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: isOpen ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(CupertinoIcons.chevron_down, color: accent, size: 18),
                  ),
                ],
              ),
            ),
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 220),
              crossFadeState: isOpen ? CrossFadeState.showFirst : CrossFadeState.showSecond,
              firstChild: Container(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                alignment: Alignment.centerLeft,
                child: child,
              ),
              secondChild: const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

class _MarkdownBox extends StatelessWidget {
  final String markdown;
  final Color bodyColor;
  final Color linkColor;

  const _MarkdownBox({
    required this.markdown,
    required this.bodyColor,
    required this.linkColor,
  });

  @override
  Widget build(BuildContext context) {
    final base = CupertinoTheme.of(context).textTheme;
    final style = MarkdownStyleSheet(
      p: TextStyle(color: bodyColor, fontSize: 16, height: 1.4, fontFamily: base.textStyle.fontFamily),
      h1: TextStyle(color: bodyColor, fontSize: 24, fontWeight: FontWeight.w700),
      h2: TextStyle(color: bodyColor, fontSize: 20, fontWeight: FontWeight.w700),
      h3: TextStyle(color: bodyColor, fontSize: 18, fontWeight: FontWeight.w600),
      listBullet: TextStyle(color: bodyColor, fontSize: 16),
      code: const TextStyle(fontFamily: 'monospace', fontSize: 14),
      blockquote: TextStyle(color: bodyColor.withOpacity(0.9)),
      a: TextStyle(color: linkColor, decoration: TextDecoration.underline),
    );

    return MarkdownBody(
      data: markdown,
      styleSheet: style,
      selectable: false,
      onTapLink: (text, href, title) async {
        if (href == null) return;
        final uri = Uri.tryParse(href);
        if (uri != null) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CupertinoActivityIndicator(radius: 14));
  }
}

class _ErrorView extends StatelessWidget {
  final Object? error;
  const _ErrorView({this.error});

  @override
  Widget build(BuildContext context) {
    final c = const Color(0xFFE9EAFF);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          'Konnte den Artikel nicht laden.\n${error ?? ''}',
          textAlign: TextAlign.center,
          style: TextStyle(color: c.withOpacity(0.9)),
        ),
      ),
    );
  }
}

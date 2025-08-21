import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../../services/news_feed_service.dart';
import '../../models/news_models.dart';

/// --------- Tuning: Lesbarkeit / Größen ----------
const _titleSize   = 17.0;  // 16–18
const _summarySize = 14.0;  // 13–14.5
const _lineHeight  = 1.32;  // für Titel/Unterzeile
const _cardPad     = 14.0;  // Innenabstand Karte
const _vSpace      = 8.0;   // vertikale Abstände

// Farben – etwas heller als zuvor, für mehr Kontrast
const _bg      = Color(0xFF0D0F16);
const _white   = Color(0xFFE9EAFF);
const _muted   = Color(0xFFC7CEFF);   // heller Sekundärtext
const _card    = Color(0xFF12152A);   // minimal heller als zuvor
const _line    = Color(0x33FFFFFF);   // 20% → 33% Hairline
const _thumbBg = Color(0x1FFFFFFF);
const _accent  = Color(0xFF7A6CFF);

enum _Tab { all, studies, news, saved }

class StudienFeedPage extends StatefulWidget {
  const StudienFeedPage({super.key});
  @override
  State<StudienFeedPage> createState() => _StudienFeedPageState();
}

class _StudienFeedPageState extends State<StudienFeedPage> {
  final _svc = NewsFeedService.instance;
  _Tab _tab = _Tab.all;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _svc.init();
    _svc.revision.addListener(_bump);
  }

  @override
  void dispose() {
    _svc.revision.removeListener(_bump);
    super.dispose();
  }

  void _bump() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final items = _filtered(_svc.items, _svc.saved, _tab, _query);

    return CupertinoPageScaffold(
      backgroundColor: _bg,
      navigationBar: const CupertinoNavigationBar(
        backgroundColor: _bg,
        middle: Text(
          'Aktuelle Studien & News',
          style: TextStyle(color: _white, fontWeight: FontWeight.w700),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            _TopBar(
              tab: _tab,
              onTab: (t) => setState(() => _tab = t),
              onRefresh: () async => _svc.refresh(),
              onQuery: (q) => setState(() => _query = q),
            ),
            const SizedBox(height: _vSpace),
            Expanded(
              child: items.isEmpty
                  ? const _EmptyFeed()
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 20),
                      itemCount: items.length,
                      itemBuilder: (_, i) => _FeedCard(item: items[i]),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  List<NewsItem> _filtered(
    List<NewsItem> all,
    List<NewsItem> saved,
    _Tab tab,
    String query,
  ) {
    final q = query.trim().toLowerCase();

    List<NewsItem> base;
    switch (tab) {
      case _Tab.all: base = all; break;
      case _Tab.studies: base = all.where((e) => e.isStudy).toList(); break;
      case _Tab.news: base = all.where((e) => !e.isStudy).toList(); break;
      case _Tab.saved: base = saved; break;
    }

    if (q.isEmpty) return base;
    return base.where((e) =>
      e.title.toLowerCase().contains(q) ||
      e.summary.toLowerCase().contains(q) ||
      e.source.toLowerCase().contains(q)
    ).toList();
  }
}

class _TopBar extends StatelessWidget {
  final _Tab tab;
  final ValueChanged<_Tab> onTab;
  final Future<void> Function() onRefresh;
  final ValueChanged<String> onQuery;

  const _TopBar({
    required this.tab,
    required this.onTab,
    required this.onRefresh,
    required this.onQuery,
  });

  @override
  Widget build(BuildContext context) {
    Widget segLabel(String text, bool selected) => Text(
      text,
      style: TextStyle(
        color: selected ? _white : _muted.withOpacity(.85),
        fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
        fontSize: 13,
      ),
    );

    return Column(
      children: [
        // Suche
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
          child: CupertinoSearchTextField(
            placeholder: 'Studien, News, Quellen …',
            style: const TextStyle(color: _white, fontSize: 15),
            placeholderStyle: const TextStyle(color: Color(0x66E9EAFF), fontSize: 15),
            backgroundColor: const Color(0x22FFFFFF), // 34% → klarer
            prefixIcon: const Icon(CupertinoIcons.search, color: _white, size: 18),
            suffixIcon: const Icon(CupertinoIcons.xmark_circle_fill, color: _white),
            onChanged: onQuery,
          ),
        ),
        // Tabs + Refresh
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Expanded(
                child: CupertinoSlidingSegmentedControl<_Tab>(
                  groupValue: tab,
                  backgroundColor: const Color(0x1FFFFFFF),
                  thumbColor: const Color(0x334C5BFF),
                  children: {
                    _Tab.all:     segLabel('Alle', tab == _Tab.all),
                    _Tab.studies: segLabel('Studien', tab == _Tab.studies),
                    _Tab.news:    segLabel('News', tab == _Tab.news),
                    _Tab.saved:   segLabel('Gespeichert', tab == _Tab.saved),
                  },
                  onValueChanged: (v) {
                    if (v != null) onTab(v);
                  },
                ),
              ),
              const SizedBox(width: 10),
              CupertinoButton(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                color: const Color(0xFF2A2942),
                borderRadius: BorderRadius.circular(12),
                onPressed: onRefresh,
                child: const Icon(CupertinoIcons.refresh, color: _white, size: 18),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FeedCard extends StatelessWidget {
  final NewsItem item;
  const _FeedCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final svc = NewsFeedService.instance;
    final isSaved = svc.isSaved(item.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _line, width: 1),
        boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 12, offset: Offset(0, 8))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(_cardPad),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail / Icon
            (item.imageUrl == null)
                ? const _ThumbPlaceholder(size: 48)
                : ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      item.imageUrl!,
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const _ThumbPlaceholder(size: 48),
                    ),
                  ),
            const SizedBox(width: 12),
            // Textblock
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Titel
                  Text(
                    item.title,
                    style: const TextStyle(
                      color: _white,
                      fontWeight: FontWeight.w800,
                      fontSize: _titleSize,
                      height: _lineHeight,
                      letterSpacing: .1,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  // Meta + Summary
                  Row(
                    children: [
                      item.isStudy ? const _Badge(text: 'Studie') : const _Badge(text: 'News'),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _subtitle(item),
                          style: const TextStyle(
                            color: _muted,
                            fontSize: _summarySize,
                            height: _lineHeight,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Actions
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CupertinoButton(
                  padding: const EdgeInsets.all(6),
                  onPressed: () async {
                    try {
                      await Share.share('${item.title}\n${item.link}');
                    } catch (_) {
                      await Clipboard.setData(ClipboardData(text: item.link));
                      _toast(context, 'Link kopiert');
                    }
                  },
                  child: const Icon(CupertinoIcons.share, color: _white, size: 20),
                ),
                CupertinoButton(
                  padding: const EdgeInsets.all(6),
                  onPressed: () => svc.toggleSaved(item),
                  child: Icon(
                    isSaved ? CupertinoIcons.bookmark_solid : CupertinoIcons.bookmark,
                    color: isSaved ? _accent : _white,
                    size: 20,
                  ),
                ),
                CupertinoButton(
                  padding: const EdgeInsets.all(6),
                  onPressed: () async {
                    final uri = Uri.tryParse(item.link);
                    if (uri != null) {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    }
                  },
                  child: const Icon(CupertinoIcons.arrow_up_right_square, color: _white, size: 20),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _subtitle(NewsItem it) {
    final when = it.published != null ? _timeAgo(it.published!) : '';
    final src = it.source.isNotEmpty ? it.source : 'Quelle';
    final sum = it.summary.replaceAll(RegExp(r'\s+'), ' ').trim();
    final short = sum.length > 140 ? '${sum.substring(0, 140)}…' : sum;
    return [src, when, short].where((e) => e.isNotEmpty).join(' · ');
  }

  String _timeAgo(DateTime d) {
    final now = DateTime.now();
    final diff = now.difference(d);
    if (diff.inMinutes < 1) return 'gerade eben';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min';
    if (diff.inHours < 24) return '${diff.inHours} h';
    if (diff.inDays < 7) return '${diff.inDays} Tage';
    return '${diff.inDays ~/ 7} Wo.';
  }
}

class _ThumbPlaceholder extends StatelessWidget {
  final double size;
  const _ThumbPlaceholder({this.size = 56});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        color: _thumbBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _line),
      ),
      child: const Icon(CupertinoIcons.doc_text, color: _white, size: 22),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  const _Badge({required this.text});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0x334C5BFF),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _line),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: _white,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          height: 1.1,
        ),
      ),
    );
  }
}

class _EmptyFeed extends StatelessWidget {
  const _EmptyFeed();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(CupertinoIcons.doc_on_doc, color: _white, size: 42),
            SizedBox(height: 12),
            Text(
              'Keine Einträge gefunden',
              style: TextStyle(color: _white, fontWeight: FontWeight.w700, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 6),
            Text(
              'Ziehe zum Aktualisieren herunter oder ändere den Filter.',
              style: TextStyle(color: _muted, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Kleine Overlay-Toast (nicht blockierend)
void _toast(BuildContext context, String message) {
  final overlay = Overlay.of(context);
  if (overlay == null) return;
  final entry = OverlayEntry(
    builder: (_) => Positioned(
      bottom: 80,
      left: 24,
      right: 24,
      child: IgnorePointer(
        ignoring: true,
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xE61C1F2E),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _line),
            ),
            child: Text(
              message,
              style: const TextStyle(color: _white, fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    ),
  );
  overlay.insert(entry);
  Future.delayed(const Duration(milliseconds: 1400), () {
    entry.remove();
  });
}

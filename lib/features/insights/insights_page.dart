// lib/features/insights/insights_page.dart
//
// Auswertung: Was sich in den letzten Wochen getan hat, in wenigen Zahlen.
import 'package:flutter/cupertino.dart';

import '../../core/practice_store.dart';
import '../../core/techniques.dart';
import '../../models/journal_models.dart';
import '../../services/journal_repo.dart';
import '../../ui/tokens.dart';
import '../../ui/widgets.dart';

class InsightsPage extends StatelessWidget {
  const InsightsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final PracticeStore store = PracticeStore.instance;
    final List<JournalIndexItem> entries = JournalRepo.instance.snapshot;
    final DateTime today = dateOnly(DateTime.now());

    // Vier Wochen, älteste zuerst.
    final List<int> dreamsPerWeek = List<int>.filled(4, 0);
    final List<int> lucidPerWeek = List<int>.filled(4, 0);
    for (final JournalIndexItem e in entries) {
      final int ago = today.difference(dateOnly(e.date)).inDays;
      if (ago < 0 || ago >= 28) continue;
      final int w = 3 - ago ~/ 7;
      dreamsPerWeek[w] += 1;
      if (e.lucid) lucidPerWeek[w] += 1;
    }
    int maxDreams = 1;
    for (final int v in dreamsPerWeek) {
      if (v > maxDreams) maxDreams = v;
    }

    final double? recallNow = store.recallRate(7);
    final double? recallBefore =
        store.recallRate(7, now: today.subtract(const Duration(days: 7)));
    final int lucidTotal = entries.where((JournalIndexItem e) => e.lucid).length;
    final int rc7 = store.realityChecksInLast(7);
    final int wbtb7 = store.wbtbNightsInLast(7);

    // Traumzeichen nach Häufigkeit.
    final Map<String, int> tagCount = <String, int>{};
    for (final JournalIndexItem e in entries) {
      for (final String t in e.tags) {
        tagCount[t] = (tagCount[t] ?? 0) + 1;
      }
    }
    final List<MapEntry<String, int>> tags = tagCount.entries.toList()
      ..sort((MapEntry<String, int> a, MapEntry<String, int> b) => b.value.compareTo(a.value));

    // Nächte mit Technik und Anteil der Klartraum-Tage danach.
    final Map<String, List<int>> tech = <String, List<int>>{};
    for (final MapEntry<DateTime, DayLog> d in store.lastDays(56)) {
      for (final String id in d.value.techniques) {
        if (id == 'journal' || id == 'rc') continue;
        final List<int> v = tech.putIfAbsent(id, () => <int>[0, 0]);
        v[0] += 1;
        if (d.value.lucid) v[1] += 1;
      }
    }

    String trend() {
      if (recallNow == null) return 'Trag morgens ein, ob du dich erinnerst. Dann siehst du hier deinen Verlauf.';
      if (recallBefore == null) return 'Dein Ausgangswert. In den ersten Wochen steigt er meist.';
      final int diff = ((recallNow - recallBefore) * 100).round();
      if (diff > 5) return '$diff Prozentpunkte mehr als in der Woche davor.';
      if (diff < -5) return '${-diff} Prozentpunkte weniger als in der Woche davor. Schwankungen sind normal.';
      return 'Etwa wie in der Woche davor.';
    }

    return LPage(
      title: 'Auswertung',
      child: LScroll(
        children: <Widget>[
          IntrinsicHeight(
            child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(
                child: _Tile(
                  value: recallNow == null ? '–' : '${(recallNow * 100).round()} %',
                  label: 'Morgen mit Traumerinnerung, 7 Tage',
                ),
              ),
              const SizedBox(width: LS.md),
              Expanded(
                child: _Tile(value: '$lucidTotal', label: 'Klarträume insgesamt', color: LC.moon),
              ),
            ],
          ),
          ),
          const SizedBox(height: LS.md),
          Text(trend(), style: LT.labelMuted),
          const LSection('Notierte Träume pro Woche'),
          LCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                LBars(
                  values: <double>[for (final int v in dreamsPerWeek) v / maxDreams],
                  labels: const <String>['vor 3 Wo.', 'vor 2 Wo.', 'letzte', 'diese'],
                  highlights: <bool>[for (final int v in lucidPerWeek) v > 0],
                  height: 96,
                ),
                const SizedBox(height: LS.md),
                Wrap(
                  spacing: LS.lg,
                  runSpacing: LS.sm,
                  children: <Widget>[
                    const _Legend(color: LC.iris, label: 'Träume'),
                    const _Legend(color: LC.moon, label: 'Woche mit Klartraum'),
                    Text('${dreamsPerWeek[3]} diese Woche', style: LT.caption),
                  ],
                ),
              ],
            ),
          ),
          const LSection('Diese Woche geübt'),
          LGroup(
            children: <Widget>[
              LRow(
                icon: CupertinoIcons.hand_raised,
                title: 'Reality-Checks',
                trailing: Text('$rc7', style: LT.heading),
              ),
              LRow(
                icon: CupertinoIcons.alarm,
                iconColor: wbtb7 > 3 ? LC.rose : LC.iris,
                title: 'Nächte mit Wachphase',
                subtitle: wbtb7 > 3 ? 'Mehr als empfohlen. Plane Pausen ein.' : 'Empfohlen: höchstens 3',
                trailing: Text('$wbtb7', style: LT.heading),
              ),
              LRow(
                icon: CupertinoIcons.flame,
                title: 'Tage in Folge',
                trailing: Text('${store.streak()}', style: LT.heading),
              ),
            ],
          ),
          if (tech.isNotEmpty) ...<Widget>[
            const LSection('Techniken, letzte 8 Wochen'),
            LGroup(
              children: <Widget>[
                for (final MapEntry<String, List<int>> t in tech.entries)
                  LRow(
                    title: techniqueById(t.key)?.name ?? t.key,
                    subtitle: '${t.value[0]} Mal geübt, an ${t.value[1]} dieser Tage ein Klartraum',
                  ),
              ],
            ),
            const SizedBox(height: LS.sm),
            Text(
              'Kleine Zahlen sind Zufall. Erst ab einigen Wochen zeigt sich, was bei dir wirkt.',
              style: LT.caption,
            ),
          ],
          if (tags.isNotEmpty) ...<Widget>[
            const LSection('Häufigste Traumzeichen'),
            LCard(
              child: Column(
                children: <Widget>[
                  for (final MapEntry<String, int> t in tags.take(6))
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: <Widget>[
                          Expanded(flex: 4, child: Text(t.key, style: LT.label, maxLines: 1, overflow: TextOverflow.ellipsis)),
                          Expanded(
                            flex: 5,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: FractionallySizedBox(
                                widthFactor: (t.value / tags.first.value).clamp(0.06, 1.0).toDouble(),
                                child: Container(
                                  height: 8,
                                  decoration: const BoxDecoration(color: LC.iris, borderRadius: LRad.pill),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 32,
                            child: Text('${t.value}', style: LT.caption, textAlign: TextAlign.right),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
          if (entries.isEmpty && recallNow == null)
            const LEmpty(
              icon: CupertinoIcons.chart_bar,
              title: 'Noch keine Daten',
              text: 'Mit den ersten Journal-Einträgen entsteht hier dein Verlauf.',
            ),
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.value, required this.label, this.color = LC.text});
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return LCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(value, style: LT.number.copyWith(color: color)),
          const SizedBox(height: LS.sm),
          Text(label, style: LT.caption),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: LT.caption),
      ],
    );
  }
}

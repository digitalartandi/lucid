import 'package:flutter/cupertino.dart';
import '../../apple_ui/widgets/large_nav_scaffold.dart';
import '../../apple_ui/widgets/section_list.dart';
import '../../knowledge/progress.dart';
import '../../routes/wissen_routes_en_quiz_anchors.dart';
import 'coach_banner.dart';

class WissenIndexWithProgress extends StatefulWidget {
  const WissenIndexWithProgress({super.key});
  @override State<WissenIndexWithProgress> createState()=> _WissenIndexWithProgressState();
}

class _WissenIndexWithProgressState extends State<WissenIndexWithProgress> {
  final assets = const {
    'Grundlagen':'assets/wissen/klartraum_grundlagen_de.md',
    'Techniken – Details':'assets/wissen/techniken_de.md',
    'Neurobiologie des Schlafs':'assets/wissen/neuro_sleep_de.md',
    'Traumtagebuch – Praxis':'assets/wissen/journal_guide_de.md',
    'Albtraumtherapie (IRT)':'assets/wissen/nightmare_irt_de.md',
    'Wearables & Erkennung':'assets/wissen/wearables_detection_de.md',
    'Ethik & Risiken':'assets/wissen/ethics_risks_de.md',
    'Troubleshooting & Plateaus':'assets/wissen/troubleshooting_de.md',
    'FAQ':'assets/wissen/faq_de.md',
    'Glossar':'assets/wissen/glossary_de.md',
    'Quellen & Literatur':'assets/wissen/citations_de.md',
  };
  Map<String, KnowledgeProgress> progress = {};

  @override
  void initState() { super.initState(); _load(); }
  Future<void> _load() async {
    final m = <String, KnowledgeProgress>{};
    for (final a in assets.values) {
      m[a] = await KnowledgeProgressRepo.get(a);
    }
    if (mounted) setState(()=> progress = m);
  }

  Widget _badge(String asset) {
    final p = progress[asset];
    if (p == null) return const SizedBox.shrink();
    final pct = (p.scrollPct * 100).round();
    final visited = p.visitedSlugs.length;
    final label = visited > 0 ? '$pct% • $visited Abschn.' : '$pct%';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: const Color(0xFFE7F1FF), borderRadius: BorderRadius.circular(10)),
      child: Text(label, style: const TextStyle(fontSize: 12)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LargeNavScaffold(title: 'Wissen', child: Column(children: [
      const CoachBanner(text: 'Tipp: Oben im Artikel findest du eine Inhaltsleiste (TOC). Tippe Überschriften zum Springen. Neben Überschriften kannst du Abschnitte als Lesezeichen speichern.'),
      Section(header: 'Kategorien', children: [
        for (final entry in assets.entries)
          RowItem(
            title: Text(entry.key),
            trailing: _badge(entry.value),
            onTap: () {
              switch (entry.key) {
                case 'Grundlagen': Navigator.pushNamed(context, WissenRoutesEx.grundlagen); break;
                case 'Techniken – Details': Navigator.pushNamed(context, WissenRoutesEx.techniken); break;
                case 'Neurobiologie des Schlafs': Navigator.pushNamed(context, WissenRoutesEx.neuro); break;
                case 'Traumtagebuch – Praxis': Navigator.pushNamed(context, WissenRoutesEx.journalGuide); break;
                case 'Albtraumtherapie (IRT)': Navigator.pushNamed(context, WissenRoutesEx.nightmareIrt); break;
                case 'Wearables & Erkennung': Navigator.pushNamed(context, WissenRoutesEx.wearables); break;
                case 'Ethik & Risiken': Navigator.pushNamed(context, WissenRoutesEx.ethics); break;
                case 'Troubleshooting & Plateaus': Navigator.pushNamed(context, WissenRoutesEx.troubleshooting); break;
                case 'FAQ': Navigator.pushNamed(context, WissenRoutesEx.faq); break;
                case 'Glossar': Navigator.pushNamed(context, WissenRoutesEx.glossary); break;
                case 'Quellen & Literatur': Navigator.pushNamed(context, WissenRoutesEx.citations); break;
              }
            },
          ),
      ]),
      Section(header: 'Werkzeuge', children: [
        RowItem(title: const Text('Studien & News (aktuell)'), onTap: ()=> Navigator.pushNamed(context, '/wissen/feed')),
        RowItem(title: const Text('Leseliste'), onTap: ()=> Navigator.pushNamed(context, '/wissen/reading_list')),
        RowItem(title: const Text('Quiz – Techniken'), onTap: ()=> Navigator.pushNamed(context, WissenRoutesEx.quizTechniken)),
        RowItem(title: const Text('Checklist – Pre‑Night'), onTap: ()=> Navigator.pushNamed(context, WissenRoutesEx.checklistPreNight)),
      ]),
    ]));
  }
}

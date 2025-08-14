import 'package:flutter/cupertino.dart';
import '../screens/wissen/wissen_page_anchors.dart';
import '../screens/wissen/wissen_index_with_progress.dart';
import '../screens/wissen/knowledge_settings_page.dart';
import '../screens/wissen/quiz_page.dart';
import '../screens/wissen/checklist_page.dart';
import '../prefs/lang_prefs.dart';

class WissenRoutesEx {
  static const index = '/wissen';
  static const settings = '/wissen/settings';
  static const grundlagen = '/wissen/grundlagen';
  static const techniken = '/wissen/techniken';
  static const neuro = '/wissen/neuro';
  static const journalGuide = '/wissen/journal_guide';
  static const nightmareIrt = '/wissen/nightmare_irt';
  static const wearables = '/wissen/wearables';
  static const ethics = '/wissen/ethics';
  static const troubleshooting = '/wissen/troubleshooting';
  static const faq = '/wissen/faq';
  static const glossary = '/wissen/glossary';
  static const citations = '/wissen/citations';
  static const quizTechniken = '/wissen/quiz/techniken';
  static const checklistPreNight = '/wissen/checklist/pre_night';

  static Future<String> _asset(String key) async {
    final lang = await LangPrefs.get();
    final m = <String, Map<String, String>>{
      'grundlagen': {'de':'assets/wissen/klartraum_grundlagen_de.md','en':'assets/wissen_en/basics_en.md'},
      'techniken': {'de':'assets/wissen/techniken_de.md','en':'assets/wissen_en/techniques_en.md'},
      'neuro': {'de':'assets/wissen/neuro_sleep_de.md','en':'assets/wissen_en/neuro_sleep_en.md'},
      'journal': {'de':'assets/wissen/journal_guide_de.md','en':'assets/wissen_en/journal_guide_en.md'},
      'nightmare': {'de':'assets/wissen/nightmare_irt_de.md','en':'assets/wissen_en/nightmare_irt_en.md'},
      'wearables': {'de':'assets/wissen/wearables_detection_de.md','en':'assets/wissen_en/wearables_detection_en.md'},
      'ethics': {'de':'assets/wissen/ethics_risks_de.md','en':'assets/wissen_en/ethics_risks_en.md'},
      'troubleshooting': {'de':'assets/wissen/troubleshooting_de.md','en':'assets/wissen_en/troubleshooting_en.md'},
      'faq': {'de':'assets/wissen/faq_de.md','en':'assets/wissen_en/faq_en.md'},
      'glossary': {'de':'assets/wissen/glossary_de.md','en':'assets/wissen_en/glossary_en.md'},
      'citations': {'de':'assets/wissen/citations_de.md','en':'assets/wissen_en/citations_en.md'},
    };
    final map = m[key] ?? const {};
    return map[lang] ?? map['de']!;
  }

  static Route<dynamic> onGenerate(RouteSettings s) {
    Widget page = const WissenIndexWithProgress();
    switch (s.name) {
      case index:
        page = const WissenIndexWithProgress();
        break;
      case settings:
        page = const KnowledgeSettingsPage();
        break;
      case grundlagen:
        return _deferred('Klartraum – Grundlagen', 'grundlagen', s);
      case techniken:
        return _deferred('Techniken – Details', 'techniken', s);
      case neuro:
        return _deferred('Neurobiologie des Schlafs', 'neuro', s);
      case journalGuide:
        return _deferred('Traumtagebuch – Praxis', 'journal', s);
      case nightmareIrt:
        return _deferred('Albtraumtherapie (IRT)', 'nightmare', s);
      case wearables:
        return _deferred('Wearables & Erkennung', 'wearables', s);
      case ethics:
        return _deferred('Ethik & Risiken', 'ethics', s);
      case troubleshooting:
        return _deferred('Troubleshooting & Plateaus', 'troubleshooting', s);
      case faq:
        return _deferred('FAQ', 'faq', s);
      case glossary:
        return _deferred('Glossar', 'glossary', s);
      case citations:
        return _deferred('Quellen & Literatur', 'citations', s);
      case quizTechniken:
        page = const QuizPage(asset: 'assets/quizzes/techniken_de.json');
        break;
      case checklistPreNight:
        page = const ChecklistPage(asset: 'assets/checklists/pre_night_de.json', title: 'Pre-Night-Checklist');
        break;
      default:
        page = const WissenIndexWithProgress();
    }
    return CupertinoPageRoute(builder: (_) => page, settings: s);
  }

  static CupertinoPageRoute _deferred(String title, String key, RouteSettings s) {
    return CupertinoPageRoute(
      settings: s,
      builder: (_) => FutureBuilder<String>(
        future: _asset(key),
        builder: (ctx, snap) {
          if (!snap.hasData) {
            return const CupertinoPageScaffold(
              child: Center(child: CupertinoActivityIndicator()),
            );
          }
          return WissenPageAnchors(asset: snap.data!, title: title);
        },
      ),
    );
  }
}

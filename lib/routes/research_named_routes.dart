// lib/routes/research_named_routes.dart
import 'package:flutter/cupertino.dart';

// ALLES mit Alias importieren, um Namenskonflikte zu vermeiden
import '../screens/research/study_list_page.dart' as list;
import '../screens/research/study_builder_page.dart' as builder;
import '../screens/research/survey_editor_page.dart' as editor;
import '../screens/research/study_detail_page.dart' as detail;
import '../screens/research/survey_run_page.dart' as run;

Route<dynamic> onGenerateResearch(RouteSettings s) {
  switch (s.name) {
    // Einstieg: Studienliste
    case '/research':
      return CupertinoPageRoute(builder: (_) => const list.StudyListPage());

    // Builder (legt Titel/Ziel/Consent/Aufgaben fest)
    case '/research/study_builder': {
      final id = s.arguments as String;
      return CupertinoPageRoute(builder: (_) => builder.StudyBuilderPage(studyId: id));
    }

    // Survey-Editor für die Studie
    case '/research/survey_editor': {
      final id = s.arguments as String;
      return CupertinoPageRoute(builder: (_) => editor.SurveyEditorPage(studyId: id));
    }

    // Detailseite mit Tabs (Übersicht/Teilnehmer/Erhebung/Export)
    case '/research/study_detail': {
      final id = s.arguments as String;
      return CupertinoPageRoute(builder: (_) => detail.StudyDetailPage(studyId: id));
    }

    // Fragebogen ausfüllen
    case '/research/run_survey': {
      final args = (s.arguments as Map?) ?? const {};
      final studyId = args['studyId'] as String;
      final participantId = args['participantId'] as String?;
      return CupertinoPageRoute(
        builder: (_) => run.SurveyRunPage(
          studyId: studyId,
          participantId: participantId,
        ),
      );
    }

    // Fallback → Liste
    default:
      return CupertinoPageRoute(builder: (_) => const list.StudyListPage());
  }
}

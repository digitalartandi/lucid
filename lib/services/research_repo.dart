// lib/services/research_repo.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/research_models.dart';

class ResearchRepo {
  ResearchRepo._();
  static final ResearchRepo instance = ResearchRepo._();

  static const _key = 'research.studies.v1';

  final ValueNotifier<int> revision = ValueNotifier<int>(0);

  List<Study> _studies = [];
  List<Study> get studies => List.unmodifiable(_studies);

  Future<void> init() async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString(_key);
    if (raw != null && raw.isNotEmpty) {
      final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
      _studies = list.map(Study.fromJson).toList();
    } else {
      // 1 Demo-Studie als Einstieg
      _studies = [
        Study(
          title: 'Klarträumen – Mikro-Cues',
          goal: 'Untersuchen, wie sanfte Cues die Traumerinnerung beeinflussen.',
          consent:
              'Ich willige ein, dass meine anonymen Antworten gespeichert und zur Auswertung genutzt werden.',
          status: StudyStatus.recruiting,
          tasks: const [StudyTask.survey, StudyTask.cueTuning, StudyTask.sleepDiary],
          survey: Survey(
            title: 'Kurzfragebogen Abend',
            questions: [
              SurveyQuestion(title: 'Wie wach fühlst du dich?', type: QuestionType.slider, min: 0, max: 10, step: 1),
              SurveyQuestion(title: 'Hast du heute RCs gemacht?', type: QuestionType.single, options: ['Ja', 'Nein']),
              SurveyQuestion(title: 'Stimmung in einem Wort', type: QuestionType.text),
            ],
          ),
        ),
      ];
      await _save();
    }
  }

  Future<void> _save() async {
    final sp = await SharedPreferences.getInstance();
    final list = _studies.map((s) => s.toJson()).toList();
    await sp.setString(_key, jsonEncode(list));
    revision.value++;
  }

  Study? byId(String id) => _studies.firstWhere((s) => s.id == id, orElse: () => Study(title: '', goal: '', consent: ''));

  Future<Study> createStudy({required String title}) async {
    final s = Study(title: title, goal: '', consent: '');
    _studies.insert(0, s);
    await _save();
    return s;
  }

  Future<void> updateStudy(Study s) async {
    final i = _studies.indexWhere((e) => e.id == s.id);
    if (i >= 0) {
      _studies[i] = s;
      await _save();
    }
  }

  Future<void> deleteStudy(String id) async {
    _studies.removeWhere((e) => e.id == id);
    await _save();
  }

  // Teilnehmer
  Future<Participant> addParticipant(String studyId, {String? note}) async {
    final s = _studies.firstWhere((e) => e.id == studyId);
    final code = 'P${(s.participants.length + 1).toString().padLeft(3, '0')}';
    final p = Participant(code: code, note: note);
    s.participants.add(p);
    await _save();
    return p;
  }

  Future<void> removeParticipant(String studyId, String pid) async {
    final s = _studies.firstWhere((e) => e.id == studyId);
    s.participants.removeWhere((e) => e.id == pid);
    s.responses.removeWhere((r) => r.participantId == pid);
    await _save();
  }

  // Antworten
  Future<void> saveResponse(SurveyResponse r) async {
    final s = _studies.firstWhere((e) => e.id == r.studyId);
    s.responses.add(r);
    await _save();
  }

  // Export Helfer
  String toCsv(Study s) {
    // Header
    final qids = s.survey?.questions.map((q) => q.id).toList() ?? [];
    final qtitles = s.survey?.questions.map((q) => q.title).toList() ?? [];

    final rows = <List<String>>[
      ['studyId', 'surveyId', 'participantCode', 'timestamp', ...qtitles],
    ];

    for (final r in s.responses) {
      final pCode = s.participants.firstWhere(
        (p) => p.id == r.participantId,
        orElse: () => Participant(code: '—'),
      ).code;

      final row = <String>[
        s.id,
        r.surveyId,
        pCode,
        r.ts.toIso8601String(),
      ];

      for (final qid in qids) {
        final v = r.answers[qid];
        if (v is List) {
          row.add(v.join('|'));
        } else {
          row.add(v?.toString() ?? '');
        }
      }
      rows.add(row);
    }

    return rows.map((r) => r.map(_csvEscape).join(',')).join('\n');
  }

  String _csvEscape(String s) {
    if (s.contains(',') || s.contains('"') || s.contains('\n')) {
      return '"${s.replaceAll('"', '""')}"';
    }
    return s;
  }
}

// lib/models/research_models.dart
import 'dart:convert';

String _id() => DateTime.now().microsecondsSinceEpoch.toString();

enum StudyStatus { draft, recruiting, active, closed }
enum StudyTask { survey, sleepDiary, cueTuning, nightLite, note }

enum QuestionType { single, multi, slider, text }

class SurveyQuestion {
  final String id;
  String title;
  QuestionType type;
  List<String> options; // für single/multi
  double min;
  double max;
  double step;

  SurveyQuestion({
    String? id,
    required this.title,
    required this.type,
    this.options = const [],
    this.min = 0,
    this.max = 10,
    this.step = 1,
  }) : id = id ?? _id();

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'type': type.name,
        'options': options,
        'min': min,
        'max': max,
        'step': step,
      };

  factory SurveyQuestion.fromJson(Map<String, dynamic> m) => SurveyQuestion(
        id: m['id'] as String?,
        title: m['title'] as String,
        type: QuestionType.values.firstWhere((e) => e.name == m['type']),
        options: (m['options'] as List?)?.cast<String>() ?? const [],
        min: (m['min'] as num?)?.toDouble() ?? 0,
        max: (m['max'] as num?)?.toDouble() ?? 10,
        step: (m['step'] as num?)?.toDouble() ?? 1,
      );
}

class Survey {
  final String id;
  String title;
  List<SurveyQuestion> questions;

  Survey({String? id, required this.title, this.questions = const []})
      : id = id ?? _id();

  Map<String, dynamic> toJson() =>
      {'id': id, 'title': title, 'questions': questions.map((e) => e.toJson()).toList()};

  factory Survey.fromJson(Map<String, dynamic> m) => Survey(
        id: m['id'] as String?,
        title: m['title'] as String,
        questions: (m['questions'] as List).cast<Map<String, dynamic>>().map(SurveyQuestion.fromJson).toList(),
      );
}

class Participant {
  final String id;
  String code; // P001 …
  String? note;

  Participant({String? id, required this.code, this.note}) : id = id ?? _id();

  Map<String, dynamic> toJson() => {'id': id, 'code': code, 'note': note};

  factory Participant.fromJson(Map<String, dynamic> m) =>
      Participant(id: m['id'] as String?, code: m['code'] as String, note: m['note'] as String?);
}

class SurveyResponse {
  final String id;
  final String studyId;
  final String surveyId;
  final String? participantId;
  final DateTime ts;
  final Map<String, dynamic> answers; // qid -> value (String | List | num)

  SurveyResponse({
    String? id,
    required this.studyId,
    required this.surveyId,
    this.participantId,
    required this.ts,
    required this.answers,
  }) : id = id ?? _id();

  Map<String, dynamic> toJson() => {
        'id': id,
        'studyId': studyId,
        'surveyId': surveyId,
        'participantId': participantId,
        'ts': ts.toIso8601String(),
        'answers': answers,
      };

  factory SurveyResponse.fromJson(Map<String, dynamic> m) => SurveyResponse(
        id: m['id'] as String?,
        studyId: m['studyId'] as String,
        surveyId: m['surveyId'] as String,
        participantId: m['participantId'] as String?,
        ts: DateTime.parse(m['ts'] as String),
        answers: (m['answers'] as Map).map((k, v) => MapEntry(k.toString(), v)),
      );
}

class Study {
  final String id;
  String title;
  String goal;
  String consent;     // Einverständniserklärung
  StudyStatus status;
  List<StudyTask> tasks;
  Survey? survey;     // optional

  // runtime data (nicht in UI sichtbar, aber exportierbar)
  final List<Participant> participants;
  final List<SurveyResponse> responses;

  Study({
    String? id,
    required this.title,
    required this.goal,
    required this.consent,
    this.status = StudyStatus.draft,
    this.tasks = const [StudyTask.survey],
    this.survey,
    List<Participant>? participants,
    List<SurveyResponse>? responses,
  })  : id = id ?? _id(),
        participants = participants ?? <Participant>[],
        responses = responses ?? <SurveyResponse>[];

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'goal': goal,
        'consent': consent,
        'status': status.name,
        'tasks': tasks.map((e) => e.name).toList(),
        'survey': survey?.toJson(),
        'participants': participants.map((e) => e.toJson()).toList(),
        'responses': responses.map((e) => e.toJson()).toList(),
      };

  factory Study.fromJson(Map<String, dynamic> m) => Study(
        id: m['id'] as String?,
        title: m['title'] as String,
        goal: m['goal'] as String,
        consent: m['consent'] as String,
        status: StudyStatus.values.firstWhere((e) => e.name == m['status']),
        tasks: (m['tasks'] as List).map((e) => StudyTask.values.firstWhere((t) => t.name == e)).toList(),
        survey: m['survey'] == null ? null : Survey.fromJson((m['survey'] as Map).cast<String, dynamic>()),
        participants: (m['participants'] as List?)?.cast<Map<String, dynamic>>().map(Participant.fromJson).toList(),
        responses: (m['responses'] as List?)?.cast<Map<String, dynamic>>().map(SurveyResponse.fromJson).toList(),
      );

  String encode() => jsonEncode(toJson());
  static Study decode(String s) => Study.fromJson(jsonDecode(s) as Map<String, dynamic>);
}

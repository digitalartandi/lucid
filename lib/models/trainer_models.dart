// lib/models/trainer_models.dart
import 'dart:convert';

enum TrainerTaskType { journal, rc, nightlite, cue, lesen, atem, traumreise, reflekt }

class TrainerTask {
  final String id;
  final String title;
  final TrainerTaskType type;
  final String? route;   // z. B. '/journal/new', '/rc', '/nightlite', '/traumreisen'
  final int minutes;     // grobe Dauer
  final String? hint;    // kurzer Tipp

  bool done;

  TrainerTask({
    required this.id,
    required this.title,
    required this.type,
    this.route,
    this.minutes = 5,
    this.hint,
    this.done = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'type': type.name,
        'route': route,
        'minutes': minutes,
        'hint': hint,
        'done': done,
      };

  factory TrainerTask.fromJson(Map<String, dynamic> m) => TrainerTask(
        id: m['id'] as String,
        title: m['title'] as String,
        type: TrainerTaskType.values.firstWhere((t) => t.name == m['type']),
        route: m['route'] as String?,
        minutes: (m['minutes'] as num?)?.toInt() ?? 5,
        hint: m['hint'] as String?,
        done: m['done'] as bool? ?? false,
      );
}

class TrainerDay {
  final int index;            // 1..14
  final String title;         // z. B. "Grundlagen & Setup"
  final String subtitle;      // kurzer Untertitel
  final List<TrainerTask> tasks;

  TrainerDay({
    required this.index,
    required this.title,
    required this.subtitle,
    required this.tasks,
  });

  bool get completed => tasks.isNotEmpty && tasks.every((t) => t.done);

  Map<String, dynamic> toJson() => {
        'index': index,
        'title': title,
        'subtitle': subtitle,
        'tasks': tasks.map((e) => e.toJson()).toList(),
      };

  factory TrainerDay.fromJson(Map<String, dynamic> m) => TrainerDay(
        index: (m['index'] as num).toInt(),
        title: m['title'] as String,
        subtitle: m['subtitle'] as String,
        tasks: (m['tasks'] as List).cast<Map<String, dynamic>>().map(TrainerTask.fromJson).toList(),
      );
}

class TrainerPlan {
  final DateTime started;
  final List<TrainerDay> days;

  TrainerPlan({required this.started, required this.days});

  int get totalDays => days.length;
  int get completedDays => days.where((d) => d.completed).length;

  Map<String, dynamic> toJson() => {
        'started': started.toIso8601String(),
        'days': days.map((e) => e.toJson()).toList(),
      };

  factory TrainerPlan.fromJson(Map<String, dynamic> m) => TrainerPlan(
        started: DateTime.parse(m['started'] as String),
        days: (m['days'] as List).cast<Map<String, dynamic>>().map(TrainerDay.fromJson).toList(),
      );

  String encode() => jsonEncode(toJson());
  static TrainerPlan decode(String s) => TrainerPlan.fromJson(jsonDecode(s) as Map<String, dynamic>);
}

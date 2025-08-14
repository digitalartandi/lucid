class QuizQuestion {
  final String id;
  final String text;
  final List<String> options;
  final int correctIndex;
  final String? explain;
  QuizQuestion({required this.id, required this.text, required this.options, required this.correctIndex, this.explain});

  factory QuizQuestion.fromJson(Map<String, dynamic> j) => QuizQuestion(
    id: j['id'], text: j['text'], options: (j['options'] as List).cast<String>(), correctIndex: j['correctIndex'], explain: j['explain'],
  );
}

class Quiz {
  final String id;
  final String title;
  final List<QuizQuestion> questions;
  Quiz({required this.id, required this.title, required this.questions});

  factory Quiz.fromJson(Map<String, dynamic> j) => Quiz(
    id: j['id'], title: j['title'],
    questions: (j['questions'] as List).map((e)=> QuizQuestion.fromJson(e)).toList(),
  );
}







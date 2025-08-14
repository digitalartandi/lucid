import 'package:flutter/cupertino.dart';
import '../../apple_ui/widgets/large_nav_scaffold.dart';
import '../../apple_ui/widgets/section_list.dart';
import '../../quiz/quiz_repo.dart';
import '../../quiz/quiz_models.dart';

class QuizPage extends StatefulWidget {
  final String asset;
  const QuizPage({super.key, required this.asset});
  @override State<QuizPage> createState()=> _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  Quiz? quiz;
  final answers = <int, int>{}; // qIndex -> optionIndex
  bool submitted = false;
  String? savedScore;

  @override
  void initState() { super.initState(); _load(); }
  Future<void> _load() async {
    quiz = await QuizRepo.load(widget.asset);
    savedScore = await QuizRepo.getScore(quiz!.id);
    if (mounted) setState((){});
  }

  void _submit() async {
    final total = quiz!.questions.length;
    int score = 0;
    for (var i=0;i<total;i++) {
      if (answers[i] == quiz!.questions[i].correctIndex) score++;
    }
    await QuizRepo.saveScore(quiz!.id, score, total);
    savedScore = '$score/$total';
    setState(()=> submitted = true);
  }

  @override
  Widget build(BuildContext context) {
    if (quiz == null) return const CupertinoPageScaffold(child: Center(child: CupertinoActivityIndicator()));
    return LargeNavScaffold(title: quiz!.title, child: Column(children: [
      if (savedScore != null) Padding(padding: const EdgeInsets.all(12), child: Text('Letztes Ergebnis: $savedScore')),
      Section(children: [
        for (var i=0;i<quiz!.questions.length;i++)
          _buildQuestion(i, quiz!.questions[i]),
      ]),
      Padding(padding: const EdgeInsets.all(16), child: CupertinoButton.filled(
        onPressed: _submit, child: const Text('Abschicken'))),
      const SizedBox(height: 12),
    ]));
  }

  Widget _buildQuestion(int idx, QuizQuestion q) {
    final selected = answers[idx];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), child: Text('${idx+1}. ${q.text}', style: const TextStyle(fontWeight: FontWeight.w600))),
        for (var o=0;o<q.options.length;o++)
          Row(
            children: [
              CupertinoButton(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), onPressed: (){
                setState(()=> answers[idx] = o);
              }, child: Row(children: [
                Icon(selected==o ? CupertinoIcons.largecircle_fill_circle : CupertinoIcons.circle),
                const SizedBox(width: 8),
                Text(q.options[o]),
              ])),
            ],
          ),
        if (submitted)
          Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4), child: Text(
            (selected == q.correctIndex ? 'Richtig!' : 'Richtig wäre: ${q.options[q.correctIndex]}')
            + (q.explain!=null? ' – ${q.explain}':''),
            style: TextStyle(color: selected==q.correctIndex ? CupertinoColors.activeGreen : CupertinoColors.destructiveRed),
          )),
        const SizedBox(height: 8),
      ]),
    );
  }
}

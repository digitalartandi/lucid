// lib/screens/research/survey_editor_page.dart
import 'package:flutter/cupertino.dart';
import '../../models/research_models.dart';
import '../../services/research_repo.dart';

const _bg = Color(0xFF080B23);
const _white = Color(0xFFFFFFFF);
const _stroke = Color(0x22FFFFFF);
const _card = Color(0xFF0A0A23);

class SurveyEditorPage extends StatefulWidget {
  final String studyId;
  const SurveyEditorPage({super.key, required this.studyId});

  @override
  State<SurveyEditorPage> createState() => _SurveyEditorPageState();
}

class _SurveyEditorPageState extends State<SurveyEditorPage> {
  late Study s;

  @override
  void initState() {
    super.initState();
    s = ResearchRepo.instance.studies.firstWhere((e) => e.id == widget.studyId);
  }

  Future<void> _save() async => ResearchRepo.instance.updateStudy(s);

  @override
  Widget build(BuildContext context) {
    final survey = s.survey!;
    return CupertinoPageScaffold(
      backgroundColor: _bg,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: _bg,
        middle: const Text('Fragebogen', style: TextStyle(color: _white)),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Fertig', style: TextStyle(color: _white)),
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _stroke),
              ),
              child: CupertinoTextField(
                controller: TextEditingController(text: survey.title),
                onChanged: (v) => survey.title = v,
                placeholder: 'Titel des Fragebogens',
              ),
            ),
            const SizedBox(height: 12),
            ...survey.questions.map((q) => _QuestionTile(
                  q: q,
                  onChanged: (_) => setState(() {}),
                  onDelete: () async {
                    survey.questions.removeWhere((e) => e.id == q.id);
                    await _save();
                    setState(() {});
                  },
                )),
            const SizedBox(height: 12),
            _AddRow(onAdd: (type) async {
              survey.questions.add(_emptyQ(type));
              await _save();
              setState(() {});
            }),
          ],
        ),
      ),
    );
  }

  SurveyQuestion _emptyQ(QuestionType t) => switch (t) {
        QuestionType.single => SurveyQuestion(title: 'Einfachauswahl', type: t, options: ['A', 'B']),
        QuestionType.multi  => SurveyQuestion(title: 'Mehrfachauswahl', type: t, options: ['A', 'B', 'C']),
        QuestionType.slider => SurveyQuestion(title: 'Skala', type: t, min: 0, max: 10, step: 1),
        QuestionType.text   => SurveyQuestion(title: 'Freitext', type: t),
      };
}

class _QuestionTile extends StatelessWidget {
  final SurveyQuestion q;
  final ValueChanged<SurveyQuestion> onChanged;
  final VoidCallback onDelete;
  const _QuestionTile({required this.q, required this.onChanged, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    Widget body;
    switch (q.type) {
      case QuestionType.single:
      case QuestionType.multi:
        body = Column(
          children: [
            for (int i = 0; i < q.options.length; i++)
              CupertinoTextField(
                controller: TextEditingController(text: q.options[i]),
                onChanged: (v) {
                  q.options[i] = v;
                  onChanged(q);
                },
                placeholder: 'Option ${i + 1}',
              ),
            const SizedBox(height: 6),
            CupertinoButton(
              color: const Color(0xFF242742),
              borderRadius: BorderRadius.circular(10),
              child: const Text('Option hinzufügen', style: TextStyle(color: _white)),
              onPressed: () {
                q.options = List.of(q.options)..add('Neue Option');
                onChanged(q);
              },
            ),
          ],
        );
        break;
      case QuestionType.slider:
        body = Row(
          children: [
            const Text('Min', style: TextStyle(color: _white)),
            const SizedBox(width: 6),
            _NumField(q.min, (v) {
              q.min = v;
              onChanged(q);
            }),
            const SizedBox(width: 12),
            const Text('Max', style: TextStyle(color: _white)),
            const SizedBox(width: 6),
            _NumField(q.max, (v) {
              q.max = v;
              onChanged(q);
            }),
            const SizedBox(width: 12),
            const Text('Step', style: TextStyle(color: _white)),
            const SizedBox(width: 6),
            _NumField(q.step, (v) {
              q.step = v;
              onChanged(q);
            }),
          ],
        );
        break;
      case QuestionType.text:
        body = const SizedBox.shrink();
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _stroke),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: CupertinoTextField(
                  controller: TextEditingController(text: q.title),
                  onChanged: (v) {
                    q.title = v;
                    onChanged(q);
                  },
                  placeholder: 'Fragetext',
                ),
              ),
              const SizedBox(width: 8),
              CupertinoSlidingSegmentedControl<QuestionType>(
                groupValue: q.type,
                children: const {
                  QuestionType.single: Text('Single'),
                  QuestionType.multi: Text('Multi'),
                  QuestionType.slider: Text('Skala'),
                  QuestionType.text: Text('Text'),
                },
                onValueChanged: (val) {
                  if (val != null) {
                    q.type = val;
                    onChanged(q);
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          body,
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: CupertinoButton(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              color: const Color(0xFF402D2D),
              borderRadius: BorderRadius.circular(10),
              onPressed: onDelete,
              child: const Text('Löschen', style: TextStyle(color: _white)),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddRow extends StatelessWidget {
  final ValueChanged<QuestionType> onAdd;
  const _AddRow({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text('Frage hinzufügen:', style: TextStyle(color: _white, fontWeight: FontWeight.w700)),
        const SizedBox(width: 10),
        for (final t in QuestionType.values)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: CupertinoButton(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              color: const Color(0xFF242742),
              borderRadius: BorderRadius.circular(999),
              onPressed: () => onAdd(t),
              child: Text(t.name, style: const TextStyle(color: _white)),
            ),
          ),
      ],
    );
  }
}

class _NumField extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;
  const _NumField(this.value, this.onChanged);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 60,
      child: CupertinoTextField(
        controller: TextEditingController(text: value.toStringAsFixed(0)),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        onSubmitted: (v) => onChanged(double.tryParse(v) ?? value),
      ),
    );
  }
}

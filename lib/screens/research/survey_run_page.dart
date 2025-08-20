// lib/screens/research/survey_run_page.dart
import 'package:flutter/cupertino.dart';
import '../../models/research_models.dart';
import '../../services/research_repo.dart';

const _bg = Color(0xFF080B23);
const _white = Color(0xFFFFFFFF);
const _stroke = Color(0x22FFFFFF);
const _card = Color(0xFF0A0A23);

class SurveyRunPage extends StatefulWidget {
  final String studyId;
  final String? participantId;
  const SurveyRunPage({super.key, required this.studyId, this.participantId});

  @override
  State<SurveyRunPage> createState() => _SurveyRunPageState();
}

class _SurveyRunPageState extends State<SurveyRunPage> {
  late Study s;
  late Survey survey;

  final Map<String, dynamic> answers = {};

  @override
  void initState() {
    super.initState();
    s = ResearchRepo.instance.studies.firstWhere((e) => e.id == widget.studyId);
    survey = s.survey!;
  }

  Future<void> _submit() async {
    final r = SurveyResponse(
      studyId: s.id,
      surveyId: survey.id,
      participantId: widget.participantId,
      ts: DateTime.now(),
      answers: answers,
    );
    await ResearchRepo.instance.saveResponse(r);
    if (!mounted) return;
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('Gespeichert'),
        content: const Text('Antwort wurde erfasst.'),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: _bg,
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Fragebogen', style: TextStyle(color: _white)),
        backgroundColor: _bg,
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            for (final q in survey.questions) _QuestionField(q: q, onChanged: (v) => answers[q.id] = v),
            const SizedBox(height: 16),
            CupertinoButton.filled(
              borderRadius: BorderRadius.circular(14),
              onPressed: _submit,
              child: const Text('Abschicken'),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuestionField extends StatefulWidget {
  final SurveyQuestion q;
  final ValueChanged<dynamic> onChanged;
  const _QuestionField({required this.q, required this.onChanged});

  @override
  State<_QuestionField> createState() => _QuestionFieldState();
}

class _QuestionFieldState extends State<_QuestionField> {
  dynamic value;

  @override
  Widget build(BuildContext context) {
    final q = widget.q;
    Widget field;

    switch (q.type) {
      case QuestionType.single:
        field = Column(
          children: [
            for (final opt in q.options)
              CupertinoListTile(
                title: Text(opt, style: const TextStyle(color: _white)),
                trailing: CupertinoRadio<String>(
                  value: opt,
                  groupValue: value as String?,
                  onChanged: (v) {
                    setState(() => value = v);
                    widget.onChanged(v);
                  },
                ),
              ),
          ],
        );
        break;
      case QuestionType.multi:
        final set = (value as Set<String>?) ?? <String>{};
        field = Column(
          children: [
            for (final opt in q.options)
              CupertinoListTile(
                title: Text(opt, style: const TextStyle(color: _white)),
                trailing: CupertinoSwitch(
                  value: set.contains(opt),
                  onChanged: (v) {
                    if (v) {
                      set.add(opt);
                    } else {
                      set.remove(opt);
                    }
                    setState(() => value = Set<String>.from(set));
                    widget.onChanged(set.toList());
                  },
                ),
              ),
          ],
        );
        break;
      case QuestionType.slider:
        final double v = (value as double?) ?? q.min;
        field = Column(
          children: [
            CupertinoSlider(
              min: q.min,
              max: q.max,
              divisions: ((q.max - q.min) / q.step).round(),
              value: v,
              onChanged: (nv) {
                setState(() => value = nv);
                widget.onChanged(nv);
              },
            ),
            Text(v.toStringAsFixed(1), style: const TextStyle(color: _white)),
          ],
        );
        break;
      case QuestionType.text:
        field = CupertinoTextField(
          placeholder: 'Antwort',
          onChanged: (v) {
            value = v;
            widget.onChanged(v);
          },
        );
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(q.title, style: const TextStyle(color: _white, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          field,
        ],
      ),
    );
  }
}

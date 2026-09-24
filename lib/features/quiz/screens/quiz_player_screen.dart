import 'package:flutter/material.dart';

import '../../../core/widgets/app_background.dart';
import '../../progress/services/quiz_progress_service.dart';
import '../models/quiz_models.dart';
import 'quiz_result_screen.dart';

class QuizPlayerScreen extends StatefulWidget {
  const QuizPlayerScreen({
    super.key,
    required this.quiz,
    required this.onQuizFinished,
  });

  final Quiz quiz;
  final VoidCallback onQuizFinished;

  @override
  State<QuizPlayerScreen> createState() => _QuizPlayerScreenState();
}

class _QuizPlayerScreenState extends State<QuizPlayerScreen> {
  late final List<int?> _answers;
  int _index = 0;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _answers = List<int?>.filled(widget.quiz.questions.length, null);
  }

  Future<void> _next() async {
    if (_saving || _answers[_index] == null) return;

    if (_index < widget.quiz.questions.length - 1) {
      setState(() => _index++);
      return;
    }

    setState(() => _saving = true);

    final answers = _answers.map((answer) => answer!).toList();
    var correct = 0;

    for (var i = 0; i < answers.length; i++) {
      if (answers[i] == widget.quiz.questions[i].correctIndex) {
        correct++;
      }
    }

    try {
      await quizProgressService.saveAttempt(
        QuizAttempt(
          quizId: widget.quiz.id,
          quizTitle: widget.quiz.title,
          correct: correct,
          total: widget.quiz.questions.length,
          completedAt: DateTime.now(),
        ),
      );

      if (!mounted) return;

      widget.onQuizFinished();

      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => QuizResultScreen(quiz: widget.quiz, answers: answers),
        ),
      );
    } catch (_) {
      if (!mounted) return;

      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ফলাফল সংরক্ষণ করা যায়নি। আবার চেষ্টা করুন।'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final question = widget.quiz.questions[_index];
    final selected = _answers[_index];

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text(widget.quiz.title),
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 650),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    LinearProgressIndicator(
                      value: (_index + 1) / widget.quiz.questions.length,
                      minHeight: 7,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'প্রশ্ন ${_index + 1} / ${widget.quiz.questions.length}',
                        style: const TextStyle(
                          color: Color(0xFF577566),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    Expanded(
                      child: ListView(
                        children: [
                          Text(
                            question.question,
                            style: const TextStyle(
                              color: Color(0xFF173A33),
                              fontSize: 23,
                              height: 1.45,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 25),
                          for (
                            var option = 0;
                            option < question.options.length;
                            option++
                          ) ...[
                            Material(
                              color: selected == option
                                  ? const Color(0xFFDDEFE3)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(18),
                                onTap: _saving
                                    ? null
                                    : () {
                                        setState(() {
                                          _answers[_index] = option;
                                        });
                                      },
                                child: Padding(
                                  padding: const EdgeInsets.all(17),
                                  child: Row(
                                    children: [
                                      Icon(
                                        selected == option
                                            ? Icons.radio_button_checked
                                            : Icons.radio_button_unchecked,
                                        color: const Color(0xFF236B54),
                                      ),
                                      const SizedBox(width: 13),
                                      Expanded(
                                        child: Text(
                                          question.options[option],
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 11),
                          ],
                        ],
                      ),
                    ),
                    if (_index > 0) ...[
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: _saving
                              ? null
                              : () {
                                  setState(() => _index--);
                                },
                          child: const Text('আগের প্রশ্ন'),
                        ),
                      ),
                      const SizedBox(height: 9),
                    ],
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: selected == null || _saving ? null : _next,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          child: Text(
                            _saving
                                ? 'সংরক্ষণ হচ্ছে...'
                                : _index == widget.quiz.questions.length - 1
                                ? 'ফলাফল দেখুন'
                                : 'পরবর্তী প্রশ্ন',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../core/widgets/app_background.dart';
import '../models/quiz_models.dart';
import 'answer_review_screen.dart';

class QuizResultScreen extends StatelessWidget {
  const QuizResultScreen({
    super.key,
    required this.quiz,
    required this.answers,
  });

  final Quiz quiz;
  final List<int> answers;

  @override
  Widget build(BuildContext context) {
    var correct = 0;

    for (var i = 0; i < answers.length; i++) {
      if (answers[i] == quiz.questions[i].correctIndex) {
        correct++;
      }
    }

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: const Text('Quiz Result'),
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  const SizedBox(height: 35),
                  const Center(
                    child: CircleAvatar(
                      radius: 58,
                      backgroundColor: Color(0xFFE1F0E7),
                      child: Icon(
                        Icons.emoji_events_outlined,
                        size: 55,
                        color: Color(0xFF236B54),
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  const Text(
                    'অনুশীলন শেষ!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF173A33),
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    quiz.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Color(0xFF708178)),
                  ),
                  const SizedBox(height: 30),
                  Card(
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(25),
                      child: Column(
                        children: [
                          Text(
                            '$correct / ${quiz.questions.length}',
                            style: const TextStyle(
                              color: Color(0xFF236B54),
                              fontSize: 38,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const Text('সঠিক উত্তর'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  FilledButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) =>
                              AnswerReviewScreen(quiz: quiz, answers: answers),
                        ),
                      );
                    },
                    icon: const Icon(Icons.fact_check_outlined),
                    label: const Text('উত্তর ও উৎস দেখুন'),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Quiz details-এ ফিরুন'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../core/widgets/app_background.dart';
import '../models/quiz_models.dart';
import 'quiz_details_screen.dart';

class QuizListScreen extends StatelessWidget {
  const QuizListScreen({
    super.key,
    required this.topic,
    required this.onQuizFinished,
  });

  final QuizTopic topic;
  final VoidCallback onQuizFinished;

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text(topic.title),
        ),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              topic.description,
              style: const TextStyle(color: Color(0xFF60786A), fontSize: 15),
            ),
            const SizedBox(height: 22),
            for (final quiz in topic.quizzes) ...[
              Card(
                color: Colors.white,
                child: ListTile(
                  contentPadding: const EdgeInsets.all(14),
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFE0F0E6),
                    child: Icon(Icons.quiz_outlined, color: Color(0xFF236B54)),
                  ),
                  title: Text(
                    quiz.title,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text('${quiz.questions.length}টি প্রশ্ন • Free'),
                  trailing: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => QuizDetailsScreen(
                          quiz: quiz,
                          onQuizFinished: onQuizFinished,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
            ],
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/widgets/app_background.dart';
import '../models/quiz_models.dart';

class AnswerReviewScreen extends StatelessWidget {
  const AnswerReviewScreen({
    super.key,
    required this.quiz,
    required this.answers,
  });

  final Quiz quiz;
  final List<int> answers;

  Future<void> _openSource(BuildContext context, String sourceUrl) async {
    try {
      final opened = await launchUrl(
        Uri.parse(sourceUrl),
        mode: LaunchMode.externalApplication,
      );

      if (!opened && context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('উৎস খোলা যায়নি।')));
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('উৎস খোলা যায়নি।')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: const Text('উত্তর পর্যালোচনা'),
        ),
        body: ListView.builder(
          padding: const EdgeInsets.all(18),
          itemCount: quiz.questions.length,
          itemBuilder: (context, index) {
            final question = quiz.questions[index];
            final isCorrect = answers[index] == question.correctIndex;

            return Card(
              color: Colors.white,
              margin: const EdgeInsets.only(bottom: 14),
              child: Padding(
                padding: const EdgeInsets.all(19),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'প্রশ্ন ${index + 1}',
                      style: const TextStyle(
                        color: Color(0xFF236B54),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 9),
                    Text(
                      question.question,
                      style: const TextStyle(
                        color: Color(0xFF173A33),
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 13),
                    Text(
                      'আপনার উত্তর: ${question.options[answers[index]]}',
                      style: TextStyle(
                        color: isCorrect
                            ? const Color(0xFF187044)
                            : const Color(0xFFB45342),
                      ),
                    ),
                    if (!isCorrect) ...[
                      const SizedBox(height: 6),
                      Text(
                        'সঠিক উত্তর: ${question.options[question.correctIndex]}',
                        style: const TextStyle(
                          color: Color(0xFF187044),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Text(
                      question.explanation,
                      style: const TextStyle(height: 1.5),
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: () => _openSource(context, question.sourceUrl),
                      icon: const Icon(Icons.open_in_new_rounded),
                      label: Text(question.sourceTitle),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

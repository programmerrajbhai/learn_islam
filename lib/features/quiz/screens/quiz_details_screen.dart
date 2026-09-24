import 'package:flutter/material.dart';

import '../../../core/widgets/app_background.dart';
import '../models/quiz_models.dart';
import 'quiz_player_screen.dart';

class QuizDetailsScreen extends StatelessWidget {
  const QuizDetailsScreen({
    super.key,
    required this.quiz,
    required this.onQuizFinished,
  });

  final Quiz quiz;
  final VoidCallback onQuizFinished;

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: const Text('Quiz details'),
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  Container(
                    width: 85,
                    height: 85,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2F0E7),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: const Icon(
                      Icons.auto_stories_rounded,
                      size: 42,
                      color: Color(0xFF236B54),
                    ),
                  ),
                  const SizedBox(height: 25),
                  Text(
                    quiz.title,
                    style: const TextStyle(
                      fontSize: 27,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF173A33),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    quiz.description,
                    style: const TextStyle(
                      color: Color(0xFF688073),
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Card(
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          _DetailRow(
                            icon: Icons.help_outline_rounded,
                            text: '${quiz.questions.length}টি প্রশ্ন',
                          ),
                          const SizedBox(height: 16),
                          const _DetailRow(
                            icon: Icons.lock_open_rounded,
                            text: 'সম্পূর্ণ Free',
                          ),
                          const SizedBox(height: 16),
                          const _DetailRow(
                            icon: Icons.replay_rounded,
                            text: 'ইচ্ছামতো আবার অনুশীলন করুন',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'শেষে সঠিক উত্তর, সংক্ষিপ্ত ব্যাখ্যা এবং উৎস দেখতে পাবেন।',
                    style: TextStyle(height: 1.5, color: Color(0xFF60786A)),
                  ),
                  const SizedBox(height: 28),
                  FilledButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => QuizPlayerScreen(
                            quiz: quiz,
                            onQuizFinished: onQuizFinished,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 13),
                      child: Text('Quiz শুরু করুন'),
                    ),
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

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF247258)),
        const SizedBox(width: 13),
        Expanded(child: Text(text)),
      ],
    );
  }
}

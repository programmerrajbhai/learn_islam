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

  void _openQuiz(BuildContext context, Quiz quiz) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => QuizDetailsScreen(
          quiz: quiz,
          onQuizFinished: onQuizFinished,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final free = topic.quizzes
        .where((quiz) => !quiz.isPremium)
        .toList();
    final premium = topic.quizzes
        .where((quiz) => quiz.isPremium)
        .toList();

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: const Text('Quiz'),
        ),
        body: ListView(
          padding:
          const EdgeInsets.fromLTRB(20, 12, 20, 32),
          children: [
            Text(
              topic.title,
              style: const TextStyle(
                color: Color(0xFF173C33),
                fontSize: 27,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              topic.description,
              style: const TextStyle(
                color: Color(0xFF71857A),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 27),
            if (free.isNotEmpty) ...[
              const _ListHeading(
                title: 'Free quizzes',
                subtitle: 'এখনই অনুশীলন শুরু করুন',
                icon: Icons.lock_open_rounded,
                color: Color(0xFF176A55),
              ),
              const SizedBox(height: 12),
              for (final quiz in free) ...[
                _QuizTile(
                  quiz: quiz,
                  onTap: () => _openQuiz(context, quiz),
                ),
                const SizedBox(height: 11),
              ],
            ],
            if (premium.isNotEmpty) ...[
              const SizedBox(height: 20),
              const _ListHeading(
                title: 'Premium quizzes',
                subtitle: 'Coins দিয়ে unlock হবে',
                icon: Icons.workspace_premium_rounded,
                color: Color(0xFF876437),
              ),
              const SizedBox(height: 12),
              for (final quiz in premium) ...[
                _QuizTile(
                  quiz: quiz,
                  onTap: () => _openQuiz(context, quiz),
                ),
                const SizedBox(height: 11),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _ListHeading extends StatelessWidget {
  const _ListHeading({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 25),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF173C33),
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Color(0xFF71857A),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _QuizTile extends StatelessWidget {
  const _QuizTile({
    required this.quiz,
    required this.onTap,
  });

  final Quiz quiz;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final paid = quiz.isPremium;
    final accent = paid
        ? const Color(0xFF876437)
        : const Color(0xFF176A55);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(21),
      child: InkWell(
        borderRadius: BorderRadius.circular(21),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                height: 53,
                width: 53,
                decoration: BoxDecoration(
                  color: paid
                      ? const Color(0xFFF9EFDA)
                      : const Color(0xFFE6F3EA),
                  borderRadius: BorderRadius.circular(17),
                ),
                child: Icon(
                  paid
                      ? Icons.lock_outline_rounded
                      : Icons.quiz_outlined,
                  color: accent,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      quiz.title,
                      style: const TextStyle(
                        color: Color(0xFF173C33),
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      paid
                          ? '${quiz.coinCost} coins • Locked'
                          : '${quiz.questions.length}টি প্রশ্ন • Free',
                      style: TextStyle(
                        color: accent,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: accent,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
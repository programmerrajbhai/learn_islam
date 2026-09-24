import 'package:flutter/material.dart';

import '../data/quiz_repository.dart';
import '../models/quiz_models.dart';
import 'quiz_list_screen.dart';

class TopicsScreen extends StatefulWidget {
  const TopicsScreen({super.key, required this.onQuizFinished});

  final VoidCallback onQuizFinished;

  @override
  State<TopicsScreen> createState() => _TopicsScreenState();
}

class _TopicsScreenState extends State<TopicsScreen> {
  late final Future<List<QuizTopic>> _topicsFuture;

  @override
  void initState() {
    super.initState();
    _topicsFuture = quizRepository.loadTopics();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<QuizTopic>>(
      future: _topicsFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'Quiz data খোলা যায়নি। pubspec.yaml-এ asset path দেখুন।',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final topics = snapshot.data!;

        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 35),
          children: [
            const Text(
              'শেখার বিষয়',
              style: TextStyle(
                color: Color(0xFF173A33),
                fontSize: 27,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 7),
            const Text(
              'একটি বিষয় বেছে নিয়ে অনুশীলন শুরু করুন।',
              style: TextStyle(color: Color(0xFF718278)),
            ),
            const SizedBox(height: 24),
            for (final topic in topics) ...[
              Material(
                color: Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(22),
                child: InkWell(
                  borderRadius: BorderRadius.circular(22),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => QuizListScreen(
                          topic: topic,
                          onQuizFinished: widget.onQuizFinished,
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Container(
                          width: 55,
                          height: 55,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE2F0E7),
                            borderRadius: BorderRadius.circular(17),
                          ),
                          child: const Icon(
                            Icons.menu_book_rounded,
                            color: Color(0xFF236B54),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                topic.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  color: Color(0xFF173A33),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                topic.description,
                                style: const TextStyle(
                                  color: Color(0xFF708178),
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                '${topic.quizzes.length}টি free quiz',
                                style: const TextStyle(
                                  color: Color(0xFF247258),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 15,
                          color: Color(0xFF809789),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 13),
            ],
          ],
        );
      },
    );
  }
}

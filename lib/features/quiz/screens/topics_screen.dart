import 'package:flutter/material.dart';

import '../data/quiz_repository.dart';
import '../models/quiz_models.dart';
import 'quiz_list_screen.dart';

class TopicsScreen extends StatefulWidget {
  const TopicsScreen({
    super.key,
    required this.onQuizFinished,
  });

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
                'Quiz data খোলা যায়নি। '
                    'JSON ও pubspec.yaml-এর assets দেখুন।',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final topics = snapshot.data!;

        return ListView(
          padding:
          const EdgeInsets.fromLTRB(20, 24, 20, 30),
          children: [
            const Text(
              'শেখার বিষয়',
              style: TextStyle(
                color: Color(0xFF173C33),
                fontSize: 28,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 7),
            const Text(
              'পছন্দের বিষয় বেছে নিয়ে quiz শুরু করুন।',
              style: TextStyle(
                color: Color(0xFF71857A),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            for (var i = 0; i < topics.length; i++) ...[
              _TopicCard(
                topic: topics[i],
                index: i,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => QuizListScreen(
                      topic: topics[i],
                      onQuizFinished:
                      widget.onQuizFinished,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 13),
            ],
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(17),
              decoration: BoxDecoration(
                color: const Color(0xFFE7F1E8),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: Color(0xFF246653),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Free quiz এখনই খেলতে পারবেন। '
                          'Premium quiz বর্তমানে locked আছে।',
                      style: TextStyle(
                        color: Color(0xFF335F4C),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _TopicCard extends StatelessWidget {
  const _TopicCard({
    required this.topic,
    required this.index,
    required this.onTap,
  });

  final QuizTopic topic;
  final int index;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final freeCount = topic.quizzes
        .where((quiz) => !quiz.isPremium)
        .length;
    final paidCount = topic.quizzes
        .where((quiz) => quiz.isPremium)
        .length;

    final gold = index.isOdd;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(23),
      child: InkWell(
        borderRadius: BorderRadius.circular(23),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(17),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: gold
                      ? const Color(0xFFF9EFDA)
                      : const Color(0xFFE6F3EA),
                  borderRadius: BorderRadius.circular(19),
                ),
                child: Icon(
                  gold
                      ? Icons.nights_stay_outlined
                      : Icons.auto_stories_rounded,
                  color: gold
                      ? const Color(0xFF876437)
                      : const Color(0xFF176A55),
                  size: 29,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      topic.title,
                      style: const TextStyle(
                        color: Color(0xFF173C33),
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      topic.description,
                      style: const TextStyle(
                        color: Color(0xFF71857A),
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 11),
                    Wrap(
                      spacing: 7,
                      runSpacing: 6,
                      children: [
                        _Tag(
                          text: '$freeCount Free',
                          color: const Color(0xFFE6F3EA),
                          ink: const Color(0xFF176A55),
                        ),
                        if (paidCount > 0)
                          _Tag(
                            text: '$paidCount Premium',
                            color: const Color(0xFFF9EFDA),
                            ink: const Color(0xFF876437),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 20),
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Color(0xFF8CA298),
                  size: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({
    required this.text,
    required this.color,
    required this.ink,
  });

  final String text;
  final Color color;
  final Color ink;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: ink,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
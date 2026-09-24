import 'package:flutter/material.dart';

import '../services/quiz_progress_service.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key, required this.revision});

  final int revision;

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  late Future<List<QuizAttempt>> _attemptsFuture;

  @override
  void initState() {
    super.initState();
    _attemptsFuture = quizProgressService.loadAttempts();
  }

  @override
  void didUpdateWidget(covariant ProgressScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.revision != widget.revision) {
      _attemptsFuture = quizProgressService.loadAttempts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<QuizAttempt>>(
      future: _attemptsFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Progress খোলা যায়নি।'));
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final attempts = snapshot.data!;
        final latestFirst = attempts.reversed.toList();

        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 30, 20, 36),
          children: [
            const Text(
              'আপনার অগ্রগতি',
              style: TextStyle(
                color: Color(0xFF173A33),
                fontSize: 27,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 7),
            const Text(
              'সম্পন্ন করা quiz-এর বাস্তব ফলাফল',
              style: TextStyle(color: Color(0xFF718278)),
            ),
            const SizedBox(height: 25),
            if (attempts.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 70),
                child: Column(
                  children: [
                    Icon(
                      Icons.insights_rounded,
                      color: Color(0xFF2B765D),
                      size: 72,
                    ),
                    SizedBox(height: 18),
                    Text(
                      'এখনো কোনো quiz শেষ হয়নি',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Quiz শেষ করলে ফলাফল এখানে দেখাবে।',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            else ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF16483C),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'মোট অনুশীলন',
                      style: TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${attempts.length} বার',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'সাম্প্রতিক ফলাফল',
                style: TextStyle(
                  color: Color(0xFF173A33),
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              for (final attempt in latestFirst)
                Card(
                  color: Colors.white,
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFFE2F0E7),
                      child: Icon(
                        Icons.checklist_rounded,
                        color: Color(0xFF236B54),
                      ),
                    ),
                    title: Text(attempt.quizTitle),
                    subtitle: Text(
                      '${attempt.completedAt.day}/${attempt.completedAt.month}/${attempt.completedAt.year}',
                    ),
                    trailing: Text(
                      '${attempt.correct}/${attempt.total}',
                      style: const TextStyle(
                        color: Color(0xFF236B54),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
            ],
          ],
        );
      },
    );
  }
}

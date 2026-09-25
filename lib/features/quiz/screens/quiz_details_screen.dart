import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/widgets/app_background.dart';
import '../../wallet/services/quiz_unlock_service.dart';
import '../models/quiz_models.dart';
import 'quiz_player_screen.dart';

class QuizDetailsScreen extends StatefulWidget {
  const QuizDetailsScreen({
    super.key,
    required this.quiz,
    required this.onQuizFinished,
  });

  final Quiz quiz;
  final VoidCallback onQuizFinished;

  @override
  State<QuizDetailsScreen> createState() =>
      _QuizDetailsScreenState();
}

class _QuizDetailsScreenState
    extends State<QuizDetailsScreen> {
  bool _unlocking = false;

  void _startQuiz() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => QuizPlayerScreen(
          quiz: widget.quiz,
          onQuizFinished: widget.onQuizFinished,
        ),
      ),
    );
  }

  Future<void> _unlockQuiz() async {
    if (_unlocking) return;

    setState(() => _unlocking = true);

    try {
      await quizUnlockService.unlock(
        quizId: widget.quiz.id,
        coinCost: widget.quiz.coinCost,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Quiz স্থায়ীভাবে unlock হয়েছে!',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      final message = error is StateError
          ? error.message.toString()
          : 'Unlock করা যায়নি। Internet ও Firebase access পরীক্ষা করুন।';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } finally {
      if (mounted) {
        setState(() => _unlocking = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final quiz = widget.quiz;
    final uid = FirebaseAuth.instance.currentUser?.uid;

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
                    height: 100,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: quiz.isPremium
                          ? const Color(0xFFF7ECD5)
                          : const Color(0xFFE2F0E7),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Icon(
                      quiz.isPremium
                          ? Icons.workspace_premium_rounded
                          : Icons.auto_stories_rounded,
                      size: 46,
                      color: quiz.isPremium
                          ? const Color(0xFF876437)
                          : const Color(0xFF236B54),
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${quiz.questions.length}টি প্রশ্ন',
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            quiz.isPremium
                                ? '${quiz.coinCost} coin দিয়ে একবার '
                                'স্থায়ী unlock। পরে আর coin লাগবে না।'
                                : 'সম্পূর্ণ Free',
                            style: const TextStyle(height: 1.5),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (!quiz.isPremium)
                    FilledButton.icon(
                      onPressed: _startQuiz,
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 13),
                        child: Text('Quiz শুরু করুন'),
                      ),
                    )
                  else if (uid == null)
                    const Text(
                      'Premium quiz খেলতে আগে login করুন।',
                    )
                  else
                    StreamBuilder<bool>(
                      stream: quizUnlockService
                          .watchUnlocked(quiz.id),
                      builder: (context, unlockSnapshot) {
                        if (unlockSnapshot.hasError) {
                          return const Text(
                            'Unlock status লোড করা যায়নি। '
                                'Internet ও Firebase access পরীক্ষা করুন।',
                          );
                        }

                        if (!unlockSnapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (unlockSnapshot.data == true) {
                          return FilledButton.icon(
                            onPressed: _startQuiz,
                            icon: const Icon(
                              Icons.play_arrow_rounded,
                            ),
                            label: const Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: 13,
                              ),
                              child: Text(
                                'Unlocked — Quiz শুরু করুন',
                              ),
                            ),
                          );
                        }

                        return StreamBuilder<
                            DocumentSnapshot<Map<String, dynamic>>>(
                          stream: FirebaseFirestore.instance
                              .collection('users')
                              .doc(uid)
                              .snapshots(),
                          builder: (context, balanceSnapshot) {
                            if (balanceSnapshot.hasError) {
                              return const Text(
                                'Balance লোড করা যায়নি।',
                              );
                            }

                            if (!balanceSnapshot.hasData) {
                              return const Center(
                                child:
                                CircularProgressIndicator(),
                              );
                            }

                            final value = balanceSnapshot
                                .data!
                                .data()?['coins'];
                            final balance =
                            value is num ? value.toInt() : 0;

                            return Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  'আপনার balance: $balance coin',
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 12),
                                FilledButton.icon(
                                  onPressed: _unlocking ||
                                      balance < quiz.coinCost
                                      ? null
                                      : _unlockQuiz,
                                  icon: const Icon(
                                    Icons.lock_open_rounded,
                                  ),
                                  label: Padding(
                                    padding:
                                    const EdgeInsets.symmetric(
                                      vertical: 13,
                                    ),
                                    child: Text(
                                      _unlocking
                                          ? 'Unlock হচ্ছে...'
                                          : '${quiz.coinCost} coin দিয়ে '
                                          'স্থায়ী unlock',
                                    ),
                                  ),
                                ),
                                if (balance < quiz.coinCost) ...[
                                  const SizedBox(height: 10),
                                  const Text(
                                    'Unlock করতে আরও coin প্রয়োজন।',
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ],
                            );
                          },
                        );
                      },
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
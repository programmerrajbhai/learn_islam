import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class QuizAttempt {
  const QuizAttempt({
    required this.quizId,
    required this.quizTitle,
    required this.correct,
    required this.total,
    required this.completedAt,
  });

  final String quizId;
  final String quizTitle;
  final int correct;
  final int total;
  final DateTime completedAt;

  Map<String, dynamic> toJson() => {
    'quizId': quizId,
    'quizTitle': quizTitle,
    'correct': correct,
    'total': total,
    'completedAt': completedAt.toIso8601String(),
  };

  factory QuizAttempt.fromJson(Map<String, dynamic> json) {
    return QuizAttempt(
      quizId: json['quizId'] as String,
      quizTitle: json['quizTitle'] as String,
      correct: json['correct'] as int,
      total: json['total'] as int,
      completedAt: DateTime.parse(json['completedAt'] as String),
    );
  }
}

class QuizProgressService {
  final SharedPreferencesAsync _prefs = SharedPreferencesAsync();

  static const _historyKey = 'free_quiz_attempts_v1';

  Future<List<QuizAttempt>> loadAttempts() async {
    final stored = await _prefs.getString(_historyKey);
    if (stored == null) return [];

    final decoded = jsonDecode(stored) as List<dynamic>;

    return decoded
        .map(
          (item) =>
              QuizAttempt.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList();
  }

  Future<void> saveAttempt(QuizAttempt attempt) async {
    final attempts = await loadAttempts();
    attempts.add(attempt);

    // Local storage-এ অপ্রয়োজনীয়ভাবে অসীম history রাখা হবে না।
    if (attempts.length > 100) {
      attempts.removeRange(0, attempts.length - 100);
    }

    await _prefs.setString(
      _historyKey,
      jsonEncode(attempts.map((item) => item.toJson()).toList()),
    );
  }
}

final QuizProgressService quizProgressService = QuizProgressService();

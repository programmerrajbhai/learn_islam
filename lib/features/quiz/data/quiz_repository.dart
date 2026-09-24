import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/quiz_models.dart';

class QuizRepository {
  Future<List<QuizTopic>>? _cachedTopics;

  Future<List<QuizTopic>> loadTopics() {
    return _cachedTopics ??= _readTopics();
  }

  Future<List<QuizTopic>> _readTopics() async {
    final text = await rootBundle.loadString('assets/data/free_quizzes.json');

    final data = jsonDecode(text) as Map<String, dynamic>;

    final topics = (data['topics'] as List<dynamic>)
        .map(
          (item) => QuizTopic.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList();

    if (topics.isEmpty) {
      throw const FormatException('কোনো quiz topic পাওয়া যায়নি।');
    }

    final ids = <String>{};

    for (final topic in topics) {
      if (!ids.add(topic.id) || topic.quizzes.isEmpty) {
        throw FormatException('Topic data ভুল: ${topic.id}');
      }

      for (final quiz in topic.quizzes) {
        if (!ids.add(quiz.id) || quiz.questions.isEmpty) {
          throw FormatException('Quiz data ভুল: ${quiz.id}');
        }

        for (final question in quiz.questions) {
          final validSource =
              Uri.tryParse(question.sourceUrl)?.hasScheme == true;

          if (!ids.add(question.id) ||
              question.options.length != 4 ||
              question.correctIndex < 0 ||
              question.correctIndex >= question.options.length ||
              question.explanation.trim().isEmpty ||
              !validSource) {
            throw FormatException('Question data ভুল: ${question.id}');
          }
        }
      }
    }

    return topics;
  }
}

final QuizRepository quizRepository = QuizRepository();

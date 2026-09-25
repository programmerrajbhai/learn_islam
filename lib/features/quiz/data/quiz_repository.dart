import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/quiz_models.dart';

class QuizRepository {
  Future<List<QuizTopic>>? _cachedTopics;

  Future<List<QuizTopic>> loadTopics() {
    return _cachedTopics ??= _readTopics();
  }

  Future<List<QuizTopic>> _readFile(String path) async {
    final text = await rootBundle.loadString(path);
    final data = jsonDecode(text) as Map<String, dynamic>;

    return (data['topics'] as List<dynamic>)
        .map(
          (item) => QuizTopic.fromJson(
        Map<String, dynamic>.from(item as Map),
      ),
    )
        .toList();
  }

  Future<List<QuizTopic>> _readTopics() async {
    final free = await _readFile('assets/data/free_quizzes.json');
    final premium = await _readFile('assets/data/premium_catalog.json');

    final topics = <QuizTopic>[];
    final positions = <String, int>{};

    void addTopic(QuizTopic topic) {
      final position = positions[topic.id];

      if (position == null) {
        positions[topic.id] = topics.length;
        topics.add(topic);
        return;
      }

      final existing = topics[position];
      topics[position] = QuizTopic(
        id: existing.id,
        title: existing.title,
        description: existing.description,
        quizzes: [...existing.quizzes, ...topic.quizzes],
      );
    }

    for (final topic in free) {
      addTopic(topic);
    }
    for (final topic in premium) {
      addTopic(topic);
    }

    if (topics.isEmpty) {
      throw const FormatException('কোনো quiz topic পাওয়া যায়নি।');
    }

    final topicIds = <String>{};
    final quizIds = <String>{};
    final questionIds = <String>{};

    for (final topic in topics) {
      if (!topicIds.add(topic.id) || topic.quizzes.isEmpty) {
        throw FormatException('Topic data ভুল: ${topic.id}');
      }

      for (final quiz in topic.quizzes) {
        if (!quizIds.add(quiz.id)) {
          throw FormatException('একই Quiz ID একাধিকবার আছে: ${quiz.id}');
        }

        if (quiz.questions.isEmpty ||
            quiz.questionCount != quiz.questions.length ||
            (quiz.isPremium && quiz.coinCost <= 0) ||
            (!quiz.isPremium && quiz.coinCost != 0)) {
          throw FormatException('Quiz data ভুল: ${quiz.id}');
        }

        for (final question in quiz.questions) {
          final uri = Uri.tryParse(question.sourceUrl);

          if (!questionIds.add(question.id) ||
              question.question.trim().isEmpty ||
              question.options.length != 4 ||
              question.options.any((option) => option.trim().isEmpty) ||
              question.options.toSet().length != 4 ||
              question.correctIndex < 0 ||
              question.correctIndex >= question.options.length ||
              question.explanation.trim().isEmpty ||
              question.sourceTitle.trim().isEmpty ||
              uri?.scheme != 'https' ||
              uri?.host.isEmpty != false) {
            throw FormatException('Question data ভুল: ${question.id}');
          }
        }
      }
    }

    return topics;
  }
}

final QuizRepository quizRepository = QuizRepository();
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
    final free = await _readFile(
      'assets/data/free_quizzes.json',
    );
    final premium = await _readFile(
      'assets/data/premium_catalog.json',
    );

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
        quizzes: [
          ...existing.quizzes,
          ...topic.quizzes,
        ],
      );
    }

    for (final topic in free) {
      addTopic(topic);
    }
    for (final topic in premium) {
      addTopic(topic);
    }

    if (topics.isEmpty) {
      throw const FormatException(
        'কোনো quiz topic পাওয়া যায়নি।',
      );
    }

    final ids = <String>{};

    for (final topic in topics) {
      if (!ids.add('topic:${topic.id}') ||
          topic.quizzes.isEmpty) {
        throw FormatException(
          'Topic data ভুল: ${topic.id}',
        );
      }

      for (final quiz in topic.quizzes) {
        if (!ids.add('quiz:${quiz.id}')) {
          throw FormatException(
            'একই Quiz ID একাধিকবার আছে: ${quiz.id}',
          );
        }

        if (quiz.isPremium) {
          if (quiz.coinCost <= 0 ||
              quiz.questionCount <= 0 ||
              quiz.questions.isNotEmpty) {
            throw FormatException(
              'Paid quiz catalog ভুল: ${quiz.id}',
            );
          }
          continue;
        }

        if (quiz.questions.isEmpty ||
            quiz.coinCost != 0) {
          throw FormatException(
            'Free quiz data ভুল: ${quiz.id}',
          );
        }

        for (final question in quiz.questions) {
          final uri = Uri.tryParse(
            question.sourceUrl,
          );

          if (!ids.add('question:${question.id}') ||
              question.options.length != 4 ||
              question.correctIndex < 0 ||
              question.correctIndex >=
                  question.options.length ||
              question.explanation.trim().isEmpty ||
              uri?.scheme != 'https') {
            throw FormatException(
              'Question data ভুল: ${question.id}',
            );
          }
        }
      }
    }

    return topics;
  }
}

final QuizRepository quizRepository =
QuizRepository();
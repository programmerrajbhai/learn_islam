class QuizTopic {
  const QuizTopic({
    required this.id,
    required this.title,
    required this.description,
    required this.quizzes,
  });

  final String id;
  final String title;
  final String description;
  final List<Quiz> quizzes;

  factory QuizTopic.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as String;

    return QuizTopic(
      id: id,
      title: json['title'] as String,
      description: json['description'] as String,
      quizzes: (json['quizzes'] as List<dynamic>)
          .map(
            (item) => Quiz.fromJson(
          Map<String, dynamic>.from(item as Map),
          topicId: id,
        ),
      )
          .toList(),
    );
  }
}

class Quiz {
  const Quiz({
    required this.id,
    required this.topicId,
    required this.title,
    required this.description,
    required this.questions,
    required this.isPremium,
    required this.coinCost,
    required this.questionCount,
  });

  final String id;
  final String topicId;
  final String title;
  final String description;
  final List<QuizQuestion> questions;
  final bool isPremium;
  final int coinCost;
  final int questionCount;

  factory Quiz.fromJson(
      Map<String, dynamic> json, {
        required String topicId,
      }) {
    final isPremium = json['isPremium'] == true;
    final questions = (json['questions'] as List<dynamic>? ?? [])
        .map(
          (item) => QuizQuestion.fromJson(
        Map<String, dynamic>.from(item as Map),
      ),
    )
        .toList();

    return Quiz(
      id: json['id'] as String,
      topicId: topicId,
      title: json['title'] as String,
      description: json['description'] as String,
      questions: questions,
      isPremium: isPremium,
      coinCost: isPremium ? (json['coinCost'] as int) : 0,
      questionCount:
      (json['questionCount'] as int?) ?? questions.length,
    );
  }
}

class QuizQuestion {
  const QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    required this.sourceTitle,
    required this.sourceUrl,
  });

  final String id;
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;
  final String sourceTitle;
  final String sourceUrl;

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      id: json['id'] as String,
      question: json['question'] as String,
      options: List<String>.from(json['options'] as List),
      correctIndex: json['correctIndex'] as int,
      explanation: json['explanation'] as String,
      sourceTitle: json['sourceTitle'] as String,
      sourceUrl: json['sourceUrl'] as String,
    );
  }
}
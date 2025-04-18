import 'quiz_category.dart';

class QuizResult {
  final DateTime dateTime;
  final QuizCategory category;
  final int score;
  final int totalQuestions;

  const QuizResult({
    required this.dateTime,
    required this.category,
    required this.score,
    required this.totalQuestions,
  });

  double get percentage => (score / totalQuestions) * 100;

  String get formattedDate {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
           '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Map<String, dynamic> toJson() => {
    'dateTime': dateTime.toIso8601String(),
    'category': category.name,
    'score': score,
    'totalQuestions': totalQuestions,
  };

  factory QuizResult.fromJson(Map<String, dynamic> json) {
    return QuizResult(
      dateTime: DateTime.parse(json['dateTime']),
      category: QuizCategory.values.firstWhere(
        (c) => c.name == json['category'],
        orElse: () => QuizCategory.general,
      ),
      score: json['score'],
      totalQuestions: json['totalQuestions'],
    );
  }
} 
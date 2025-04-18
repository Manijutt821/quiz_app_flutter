import 'package:flutter/material.dart';
import 'quiz_category.dart';

class ScoreHistoryModel {
  final String id;
  final DateTime dateTime;
  final QuizCategory category;
  final int score;
  final int totalQuestions;
  final Duration timeTaken;

  const ScoreHistoryModel({
    required this.id,
    required this.dateTime,
    required this.category,
    required this.score,
    required this.totalQuestions,
    required this.timeTaken,
  });

  double get percentage => (score / totalQuestions) * 100;

  String get formattedDate {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
           '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String get formattedTimeTaken {
    final minutes = timeTaken.inMinutes;
    final seconds = timeTaken.inSeconds % 60;
    return '${minutes}m ${seconds}s';
  }

  Color getScoreColor(BuildContext context) {
    if (percentage >= 80) {
      return Colors.green;
    } else if (percentage >= 60) {
      return Colors.orange;
    } else {
      return Theme.of(context).brightness == Brightness.dark
          ? Colors.redAccent
          : Colors.red;
    }
  }

  String getGrade() {
    if (percentage >= 90) return 'A+';
    if (percentage >= 80) return 'A';
    if (percentage >= 70) return 'B';
    if (percentage >= 60) return 'C';
    if (percentage >= 50) return 'D';
    return 'F';
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'dateTime': dateTime.toIso8601String(),
    'category': category.name,
    'score': score,
    'totalQuestions': totalQuestions,
    'timeTaken': timeTaken.inSeconds,
  };

  factory ScoreHistoryModel.fromJson(Map<String, dynamic> json) {
    return ScoreHistoryModel(
      id: json['id'] as String,
      dateTime: DateTime.parse(json['dateTime']),
      category: QuizCategory.values.firstWhere(
        (c) => c.name == json['category'],
        orElse: () => QuizCategory.general,
      ),
      score: json['score'] as int,
      totalQuestions: json['totalQuestions'] as int,
      timeTaken: Duration(seconds: json['timeTaken'] as int),
    );
  }
} 
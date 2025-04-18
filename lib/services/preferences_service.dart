import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences.dart';

class ScoreHistory {
  final int score;
  final int totalQuestions;
  final String category;
  final DateTime date;

  ScoreHistory({
    required this.score,
    required this.totalQuestions,
    required this.category,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
    'score': score,
    'totalQuestions': totalQuestions,
    'category': category,
    'date': date.toIso8601String(),
  };

  factory ScoreHistory.fromJson(Map<String, dynamic> json) => ScoreHistory(
    score: json['score'],
    totalQuestions: json['totalQuestions'],
    category: json['category'],
    date: DateTime.parse(json['date']),
  );
}

class PreferencesService extends ChangeNotifier {
  static final PreferencesService _instance = PreferencesService._internal();
  factory PreferencesService() => _instance;
  PreferencesService._internal();

  late SharedPreferences _prefs;
  bool _isDarkMode = false;
  List<ScoreHistory> _scoreHistory = [];

  bool get isDarkMode => _isDarkMode;
  List<ScoreHistory> get scoreHistory => _scoreHistory;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    _loadTheme();
    _loadScoreHistory();
  }

  void _loadTheme() {
    _isDarkMode = _prefs.getBool('isDarkMode') ?? false;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    await _prefs.setBool('isDarkMode', _isDarkMode);
    notifyListeners();
  }

  void _loadScoreHistory() {
    final String? historyJson = _prefs.getString('scoreHistory');
    if (historyJson != null) {
      final List<dynamic> decoded = jsonDecode(historyJson);
      _scoreHistory = decoded
          .map((item) => ScoreHistory.fromJson(item))
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));
    }
    notifyListeners();
  }

  Future<void> addScore(ScoreHistory score) async {
    _scoreHistory.insert(0, score);
    if (_scoreHistory.length > 50) {
      _scoreHistory = _scoreHistory.sublist(0, 50);
    }
    await _saveScoreHistory();
    notifyListeners();
  }

  Future<void> clearScoreHistory() async {
    _scoreHistory.clear();
    await _saveScoreHistory();
    notifyListeners();
  }

  Future<void> _saveScoreHistory() async {
    final String encoded = jsonEncode(_scoreHistory.map((e) => e.toJson()).toList());
    await _prefs.setString('scoreHistory', encoded);
  }

  String getMotivationalMessage(int score, int total) {
    final percentage = (score / total) * 100;
    if (percentage >= 90) {
      return "Outstanding! You're a quiz master! 🏆";
    } else if (percentage >= 75) {
      return "Great job! Keep up the excellent work! 🌟";
    } else if (percentage >= 50) {
      return "Good effort! Room for improvement! 💪";
    } else {
      return "Keep practicing! You'll do better next time! 📚";
    }
  }

  double getAverageScore() {
    if (_scoreHistory.isEmpty) return 0.0;
    final totalPercentage = _scoreHistory.fold<double>(
      0,
      (sum, score) => sum + (score.score / score.totalQuestions * 100),
    );
    return totalPercentage / _scoreHistory.length;
  }

  Map<String, double> getCategoryPerformance() {
    final Map<String, List<double>> categoryScores = {};
    for (var score in _scoreHistory) {
      categoryScores.putIfAbsent(score.category, () => []);
      categoryScores[score.category]!
          .add(score.score / score.totalQuestions * 100);
    }

    return Map.fromEntries(
      categoryScores.entries.map(
        (e) => MapEntry(
          e.key,
          e.value.reduce((a, b) => a + b) / e.value.length,
        ),
      ),
    );
  }
} 
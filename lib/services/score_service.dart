import 'dart:convert';
import 'package:shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../models/score_model.dart';

class ScoreService extends ChangeNotifier {
  static const String _scoreKey = 'quiz_scores';
  final SharedPreferences _prefs;
  List<ScoreHistoryModel> _scores = [];

  ScoreService(this._prefs) {
    _loadScores();
  }

  List<ScoreHistoryModel> get scores => List.unmodifiable(_scores);

  void _loadScores() {
    final String? scoresJson = _prefs.getString(_scoreKey);
    if (scoresJson != null) {
      try {
        final List<dynamic> scoresList = jsonDecode(scoresJson);
        _scores = scoresList
            .map((json) => ScoreHistoryModel.fromJson(json))
            .toList()
          ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
        notifyListeners();
      } catch (e) {
        debugPrint('Error loading scores: $e');
        _scores = [];
      }
    }
  }

  Future<void> addScore(ScoreHistoryModel score) async {
    _scores.insert(0, score);
    await _saveScores();
    notifyListeners();
  }

  Future<void> removeScore(String id) async {
    _scores.removeWhere((score) => score.id == id);
    await _saveScores();
    notifyListeners();
  }

  Future<void> clearAllScores() async {
    _scores.clear();
    await _saveScores();
    notifyListeners();
  }

  Future<void> _saveScores() async {
    final String scoresJson = jsonEncode(_scores.map((s) => s.toJson()).toList());
    await _prefs.setString(_scoreKey, scoresJson);
  }

  /// Returns the highest scoring quiz attempt.
  /// Returns null if no quizzes have been taken.
  ScoreHistoryModel? getBestScore() {
    if (_scores.isEmpty) return null;
    
    return _scores.reduce((a, b) => 
      a.percentage > b.percentage ? a : b
    );
  }

  /// Returns the average score across all quizzes.
  /// Returns 0.0 if no quizzes have been taken.
  double getOverallAverage() {
    if (_scores.isEmpty) return 0.0;
    
    final totalPercentage = _scores.fold<double>(
      0.0,
      (sum, score) => sum + score.percentage,
    );
    
    return totalPercentage / _scores.length;
  }

  /// Returns a map of category names to their average scores.
  /// Categories with no attempts will not be included in the map.
  Map<String, double> getCategoryAverages() {
    final Map<String, List<double>> categoryScores = {};
    
    for (final score in _scores) {
      final category = score.category.name;
      categoryScores.putIfAbsent(category, () => []);
      categoryScores[category]!.add(score.percentage);
    }

    return Map.fromEntries(
      categoryScores.entries.map(
        (entry) => MapEntry(
          entry.key,
          entry.value.isEmpty
              ? 0.0
              : entry.value.reduce((a, b) => a + b) / entry.value.length,
        ),
      ),
    );
  }

  /// Returns a list of scores for a specific category.
  /// The list is sorted by date (newest first).
  List<ScoreHistoryModel> getScoresByCategory(String category) {
    return _scores
        .where((score) => score.category.name == category)
        .toList();
  }

  /// Returns the total number of completed quizzes.
  int getTotalQuizzesTaken() => _scores.length;

  /// Returns the average score for the last [n] quizzes.
  /// If fewer than [n] quizzes exist, calculates average for all available quizzes.
  double getRecentAverage(int n) {
    if (_scores.isEmpty) return 0.0;
    
    final recentScores = _scores.take(n);
    return recentScores.fold<double>(0.0, (sum, score) => sum + score.percentage) / 
           recentScores.length;
  }

  /// Returns the improvement percentage between the average of the first half
  /// of attempts and the second half. Positive value indicates improvement.
  double getImprovementRate() {
    if (_scores.length < 2) return 0.0;
    
    final midPoint = _scores.length ~/ 2;
    final recentHalf = _scores.take(midPoint);
    final olderHalf = _scores.skip(midPoint).take(midPoint);
    
    final recentAvg = recentHalf.fold<double>(0.0, (sum, score) => sum + score.percentage) / 
                      recentHalf.length;
    final olderAvg = olderHalf.fold<double>(0.0, (sum, score) => sum + score.percentage) / 
                     olderHalf.length;
    
    return ((recentAvg - olderAvg) / olderAvg) * 100;
  }

  /// Returns a map of hour of day to number of quizzes taken during that hour.
  Map<int, int> getHourlyDistribution() {
    final distribution = Map<int, int>.fromIterables(
      List.generate(24, (i) => i),
      List.generate(24, (i) => 0),
    );
    
    for (final score in _scores) {
      distribution[score.dateTime.hour] = 
          (distribution[score.dateTime.hour] ?? 0) + 1;
    }
    
    return distribution;
  }
} 
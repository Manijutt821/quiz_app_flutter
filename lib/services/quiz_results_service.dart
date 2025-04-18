import 'dart:convert';
import 'package:shared_preferences.dart';
import '../models/quiz_result.dart';
import '../models/quiz_category.dart';

class QuizResultsService {
  static final QuizResultsService _instance = QuizResultsService._internal();
  factory QuizResultsService() => _instance;
  QuizResultsService._internal();

  static const String _storageKey = 'quiz_scores';
  List<QuizResult> _cachedResults = [];
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;
    await _loadResults();
    _isInitialized = true;
  }

  Future<void> _loadResults() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);
    if (jsonString != null) {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      _cachedResults = jsonList
          .map((json) => QuizResult.fromJson(json))
          .toList()
        ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
    }
  }

  Future<void> saveQuizResult(QuizResult result) async {
    _cachedResults.insert(0, result);
    await _saveToPrefs();
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(_cachedResults.map((r) => r.toJson()).toList());
    await prefs.setString(_storageKey, jsonString);
  }

  List<QuizResult> getAllResults() {
    return List.unmodifiable(_cachedResults);
  }

  List<QuizResult> getResultsByCategory(QuizCategory category) {
    return _cachedResults.where((r) => r.category == category).toList();
  }

  double getAverageScore() {
    if (_cachedResults.isEmpty) return 0.0;
    final totalPercentage = _cachedResults.fold<double>(
      0,
      (sum, result) => sum + result.percentage,
    );
    return totalPercentage / _cachedResults.length;
  }

  Map<QuizCategory, double> getCategoryAverages() {
    final Map<QuizCategory, List<double>> categoryScores = {};
    
    for (var result in _cachedResults) {
      categoryScores.putIfAbsent(result.category, () => []);
      categoryScores[result.category]!.add(result.percentage);
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

  Future<void> clearHistory() async {
    _cachedResults.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }
} 
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/score_model.dart';
import '../models/quiz_model.dart';

class ExportService {
  static final ExportService instance = ExportService._internal();
  ExportService._internal();

  Future<void> exportData({
    required List<ScoreHistoryModel> scores,
    required List<QuizModel> quizzes,
  }) async {
    try {
      final data = {
        'scores': scores.map((score) => score.toJson()).toList(),
        'quizzes': quizzes.map((quiz) => quiz.toJson()).toList(),
        'exportDate': DateTime.now().toIso8601String(),
        'version': '1.0.0',
      };

      final jsonString = jsonEncode(data);
      
      // Get the temporary directory
      final directory = await getTemporaryDirectory();
      final fileName = 'quiz_app_export_${DateTime.now().millisecondsSinceEpoch}.json';
      final file = File('${directory.path}/$fileName');
      
      // Write the JSON data to the file
      await file.writeAsString(jsonString);

      // Share the file
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Quiz App Data Export',
        text: 'Here is your Quiz App data export',
      );

    } catch (e) {
      throw Exception('Failed to export data: $e');
    }
  }

  Future<Map<String, dynamic>> importData(String jsonString) async {
    try {
      final data = jsonDecode(jsonString) as Map<String, dynamic>;
      
      // Validate the data structure
      if (!data.containsKey('scores') || 
          !data.containsKey('quizzes') || 
          !data.containsKey('version')) {
        throw Exception('Invalid data format');
      }

      return data;
    } catch (e) {
      throw Exception('Failed to import data: $e');
    }
  }
} 
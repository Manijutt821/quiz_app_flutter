import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:quiz_app_flutter/models/quiz_model.dart';
import 'package:quiz_app_flutter/models/score_model.dart';
import 'package:quiz_app_flutter/services/audio_service.dart';

void main() {
  group('Quiz Model Tests', () {
    test('Quiz model initialization', () {
      final quiz = QuizModel(
        id: '1',
        title: 'Test Quiz',
        questions: [
          {
            'question': 'What is 2+2?',
            'options': ['3', '4', '5', '6'],
            'correctAnswer': 1,
          }
        ],
        category: 'Math',
        difficulty: 'Easy',
      );

      expect(quiz.title, 'Test Quiz');
      expect(quiz.questions.length, 1);
      expect(quiz.category, 'Math');
      expect(quiz.difficulty, 'Easy');
    });

    test('Score calculation', () {
      final score = ScoreHistoryModel(
        quizId: '1',
        category: 'Math',
        correctAnswers: 8,
        totalQuestions: 10,
        timeTaken: const Duration(minutes: 5),
        date: DateTime.now(),
      );

      expect(score.percentage, 80);
      expect(score.correctAnswers, 8);
      expect(score.totalQuestions, 10);
    });
  });

  group('Audio Service Tests', () {
    test('Audio service initialization', () {
      final audioService = AudioService.instance;
      
      expect(audioService.isMuted, false);
      expect(audioService.isBackgroundMusicEnabled, true);
    });

    test('Audio service mute toggle', () {
      final audioService = AudioService.instance;
      final initialMuteState = audioService.isMuted;
      
      audioService.toggleMute();
      expect(audioService.isMuted, !initialMuteState);
      
      // Reset to initial state
      audioService.toggleMute();
      expect(audioService.isMuted, initialMuteState);
    });
  });

  testWidgets('Quiz button tap test', (WidgetTester tester) async {
    bool buttonPressed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ElevatedButton(
            onPressed: () => buttonPressed = true,
            child: const Text('Answer'),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    expect(buttonPressed, true);
  });
} 
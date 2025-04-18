import 'quiz_category.dart';

class Question {
  final String questionText;
  final List<String> options;
  final int correctAnswerIndex;
  final QuizCategory category;

  const Question({
    required this.questionText,
    required this.options,
    required this.correctAnswerIndex,
    required this.category,
  });

  bool isCorrectAnswer(int selectedIndex) => selectedIndex == correctAnswerIndex;

  // Factory method to create a shuffled copy of the question
  Question shuffled() {
    final shuffledOptions = List<String>.from(options);
    final correctAnswer = shuffledOptions[correctAnswerIndex];
    shuffledOptions.shuffle();
    final newCorrectIndex = shuffledOptions.indexOf(correctAnswer);
    
    return Question(
      questionText: questionText,
      options: shuffledOptions,
      correctAnswerIndex: newCorrectIndex,
      category: category,
    );
  }
} 
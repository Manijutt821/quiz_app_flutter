import '../models/question.dart';
import '../models/quiz_category.dart';

class QuizService {
  static final QuizService _instance = QuizService._internal();
  factory QuizService() => _instance;
  QuizService._internal();

  final Map<QuizCategory, List<Question>> _categoryQuestions = {
    QuizCategory.general: [
      Question(
        questionText: 'What is the capital of France?',
        options: ['London', 'Berlin', 'Paris', 'Madrid'],
        correctAnswerIndex: 2,
        category: QuizCategory.general,
      ),
      Question(
        questionText: 'Which is the largest ocean on Earth?',
        options: ['Atlantic', 'Indian', 'Arctic', 'Pacific'],
        correctAnswerIndex: 3,
        category: QuizCategory.general,
      ),
      Question(
        questionText: 'What is the currency of Japan?',
        options: ['Yuan', 'Won', 'Yen', 'Ringgit'],
        correctAnswerIndex: 2,
        category: QuizCategory.general,
      ),
    ],
    QuizCategory.science: [
      Question(
        questionText: 'What is the chemical symbol for gold?',
        options: ['Au', 'Ag', 'Fe', 'Cu'],
        correctAnswerIndex: 0,
        category: QuizCategory.science,
      ),
      Question(
        questionText: 'Which planet is known as the Red Planet?',
        options: ['Venus', 'Mars', 'Jupiter', 'Saturn'],
        correctAnswerIndex: 1,
        category: QuizCategory.science,
      ),
      Question(
        questionText: 'What is the hardest natural substance on Earth?',
        options: ['Gold', 'Iron', 'Diamond', 'Platinum'],
        correctAnswerIndex: 2,
        category: QuizCategory.science,
      ),
    ],
    QuizCategory.history: [
      Question(
        questionText: 'Who painted the Mona Lisa?',
        options: ['Vincent van Gogh', 'Pablo Picasso', 'Leonardo da Vinci', 'Michelangelo'],
        correctAnswerIndex: 2,
        category: QuizCategory.history,
      ),
      Question(
        questionText: 'In which year did World War II end?',
        options: ['1943', '1944', '1945', '1946'],
        correctAnswerIndex: 2,
        category: QuizCategory.history,
      ),
      Question(
        questionText: 'Who was the first President of the United States?',
        options: ['Thomas Jefferson', 'John Adams', 'George Washington', 'Benjamin Franklin'],
        correctAnswerIndex: 2,
        category: QuizCategory.history,
      ),
    ],
  };

  List<Question> getQuestionsForCategory(QuizCategory category) {
    final questions = List<Question>.from(_categoryQuestions[category] ?? []);
    questions.shuffle();
    return questions.map((q) => q.shuffled()).toList();
  }

  String getMotivationalMessage(int score, int total) {
    final percentage = (score / total) * 100;
    if (percentage == 100) {
      return 'Perfect Score! Outstanding! 🏆';
    } else if (percentage >= 80) {
      return 'Excellent Work! 🌟';
    } else if (percentage >= 60) {
      return 'Good Job! Keep it up! 💪';
    } else if (percentage >= 40) {
      return 'Keep Practicing! You can do better! 📚';
    } else {
      return 'Time to Study More! Never give up! 💡';
    }
  }
}
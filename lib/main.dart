import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'services/preferences_service.dart';
import 'services/audio_service.dart';
import 'services/quiz_results_service.dart';
import 'services/theme_service.dart';
import 'services/score_service.dart';
import 'utils/theme_manager.dart';
import 'services/ad_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AdManager.instance.initialize();
  
  // Initialize services
  final prefs = await SharedPreferences.getInstance();
  final themeManager = ThemeManager(prefs);
  final scoreService = ScoreService(prefs);
  final audioService = AudioService();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeManager),
        ChangeNotifierProvider.value(value: scoreService),
        Provider.value(value: audioService),
      ],
      child: const QuizApp(),
    ),
  );
}

enum QuizCategory {
  general,
  science,
  history,
}

extension QuizCategoryExtension on QuizCategory {
  String get name {
    switch (this) {
      case QuizCategory.general:
        return 'General Knowledge';
      case QuizCategory.science:
        return 'Science';
      case QuizCategory.history:
        return 'History';
    }
  }

  IconData get icon {
    switch (this) {
      case QuizCategory.general:
        return Icons.lightbulb_rounded;
      case QuizCategory.science:
        return Icons.science_rounded;
      case QuizCategory.history:
        return Icons.history_edu_rounded;
    }
  }
}

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
}

class ScoreHistory {
  final DateTime date;
  final int score;
  final int totalQuestions;
  final QuizCategory category;

  ScoreHistory({
    required this.date,
    required this.score,
    required this.totalQuestions,
    required this.category,
  });

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'score': score,
        'totalQuestions': totalQuestions,
        'category': category.index,
      };

  factory ScoreHistory.fromJson(Map<String, dynamic> json) => ScoreHistory(
        date: DateTime.parse(json['date']),
        score: json['score'],
        totalQuestions: json['totalQuestions'],
        category: QuizCategory.values[json['category']],
      );
}

// Custom theme colors
class AppColors {
  static const primaryLight = Color(0xFF2962FF);
  static const primaryDark = Color(0xFF82B1FF);
  static const secondaryLight = Color(0xFF3D5AFE);
  static const secondaryDark = Color(0xFF8C9EFF);
  static const backgroundLight = Color(0xFFF5F5F5);
  static const backgroundDark = Color(0xFF1A1A1A);
  static const surfaceLight = Color(0xFFFFFFFF);
  static const surfaceDark = Color(0xFF2C2C2C);
  static const errorLight = Color(0xFFB00020);
  static const errorDark = Color(0xFFCF6679);
}

// Custom page route for smooth transitions
class CustomPageRoute extends PageRouteBuilder {
  final Widget child;

  CustomPageRoute({required this.child})
      : super(
          transitionDuration: const Duration(milliseconds: 400),
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 0.1);
            const end = Offset.zero;
            const curve = Curves.easeOutCubic;
            
            var tween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: curve),
            );
            
            var offsetAnimation = animation.drive(tween);
            var fadeAnimation = animation.drive(
              Tween(begin: 0.0, end: 1.0).chain(
                CurveTween(curve: curve),
              ),
            );

            return SlideTransition(
              position: offsetAnimation,
              child: FadeTransition(
                opacity: fadeAnimation,
                child: child,
              ),
            );
          },
        );
}

class QuizApp extends StatelessWidget {
  const QuizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeManager>(
      builder: (context, themeManager, child) {
        return MaterialApp(
          title: 'Quiz App',
          theme: ThemeManager.getLightTheme(),
          darkTheme: ThemeManager.getDarkTheme(),
          themeMode: themeManager.themeMode,
          debugShowCheckedModeBanner: false,
          home: const HomeScreen(),
        );
      },
    );
  }
}

/// Custom page route that provides consistent transitions across the app
class QuizPageRoute<T> extends MaterialPageRoute<T> {
  QuizPageRoute({
    required WidgetBuilder builder,
    RouteSettings? settings,
  }) : super(builder: builder, settings: settings);

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        ),
      ),
      child: child,
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primaryContainer.withOpacity(0.2),
              Theme.of(context).colorScheme.background,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton.filledTonal(
                      onPressed: () async {
                        final prefs = await SharedPreferences.getInstance();
                        final history = prefs.getStringList('scoreHistory') ?? [];
                        if (!context.mounted) return;
                        
                        showModalBottomSheet(
                          context: context,
                          builder: (context) => ScoreHistorySheet(
                            history: history
                                .map((e) => ScoreHistory.fromJson(
                                    jsonDecode(e) as Map<String, dynamic>))
                                .toList(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.history_rounded),
                    ),
                    IconButton.filledTonal(
                      onPressed: () {
                        final app = context.findAncestorStateOfType<_QuizAppState>();
                        app?.toggleTheme();
                      },
                      icon: Icon(
                        Theme.of(context).brightness == Brightness.light
                            ? Icons.dark_mode_rounded
                            : Icons.light_mode_rounded,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TweenAnimationBuilder(
                        tween: Tween<double>(begin: 0, end: 1),
                        duration: const Duration(milliseconds: 1000),
                        curve: Curves.elasticOut,
                        builder: (context, double value, child) {
                          return Transform.scale(
                            scale: value,
                            child: child,
                          );
                        },
                        child: Hero(
                          tag: 'quiz_icon',
                          child: Icon(
                            Icons.quiz_rounded,
                            size: 100,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      TweenAnimationBuilder(
                        tween: Tween<double>(begin: 0, end: 1),
                        duration: const Duration(milliseconds: 800),
                        curve: Curves.easeOut,
                        builder: (context, double value, child) {
                          return Opacity(
                            opacity: value,
                            child: Transform.translate(
                              offset: Offset(0, 20 * (1 - value)),
                              child: child,
                            ),
                          );
                        },
                        child: Column(
                          children: [
                            Text(
                              'Knowledge Quiz',
                              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Choose a category to start',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onBackground
                                        .withOpacity(0.7),
                                  ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                      ...QuizCategory.values.map(
                        (category) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: FilledButton.icon(
                            onPressed: () {
                              Navigator.of(context).push(
                                CustomPageRoute(
                                  child: QuizScreen(category: category),
                                ),
                              );
                            },
                            icon: Icon(category.icon),
                            label: Text(
                              category.name,
                              style: const TextStyle(fontSize: 18),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ScoreHistorySheet extends StatelessWidget {
  final List<ScoreHistory> history;

  const ScoreHistorySheet({
    super.key,
    required this.history,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Score History',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
          const Divider(),
          if (history.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('No quiz history yet'),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: history.length,
                itemBuilder: (context, index) {
                  final score = history[index];
                  return ListTile(
                    leading: Icon(score.category.icon),
                    title: Text(score.category.name),
                    subtitle: Text(
                      'Date: ${score.date.toString().split('.')[0]}',
                    ),
                    trailing: Text(
                      '${score.score}/${score.totalQuestions}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class QuizScreen extends StatefulWidget {
  final QuizCategory category;

  const QuizScreen({
    super.key,
    required this.category,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> with SingleTickerProviderStateMixin {
  int currentQuestionIndex = 0;
  int score = 0;
  bool hasAnswered = false;
  int? selectedAnswerIndex;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  Timer? _timer;
  int _timeLeft = 10;
  late List<Question> questions;

  final Map<QuizCategory, List<Question>> categoryQuestions = {
    QuizCategory.general: const [
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
    ],
    QuizCategory.science: const [
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
    ],
    QuizCategory.history: const [
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
    ],
  };

  @override
  void initState() {
    super.initState();
    _initializeQuestions();
    _initializeAnimations();
    _startTimer();
  }

  void _initializeQuestions() {
    // Get questions for the selected category and shuffle them
    questions = List.from(categoryQuestions[widget.category]!);
    questions.shuffle();
    // Shuffle options for each question
    for (var question in questions) {
      final shuffledOptions = List<String>.from(question.options);
      final correctAnswer = shuffledOptions[question.correctAnswerIndex];
      shuffledOptions.shuffle();
      final newCorrectIndex = shuffledOptions.indexOf(correctAnswer);
      question = Question(
        questionText: question.questionText,
        options: shuffledOptions,
        correctAnswerIndex: newCorrectIndex,
        category: question.category,
      );
    }
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _slideAnimation = Tween<double>(begin: 50, end: 0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );
    _animationController.forward();
  }

  void _startTimer() {
    _timer?.cancel();
    _timeLeft = 10;
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (_timeLeft > 0) {
          setState(() {
            _timeLeft--;
          });
        } else {
          _handleTimeout();
        }
      },
    );
  }

  void _handleTimeout() {
    if (!hasAnswered) {
      handleAnswer(null);
    }
  }

  void _saveScore() async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList('scoreHistory') ?? [];
    
    final newScore = ScoreHistory(
      date: DateTime.now(),
      score: score,
      totalQuestions: questions.length,
      category: widget.category,
    );
    
    history.add(jsonEncode(newScore.toJson()));
    await prefs.setStringList('scoreHistory', history);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void handleAnswer(int? selectedIndex) {
    if (hasAnswered) return;

    _timer?.cancel();
    setState(() {
      hasAnswered = true;
      selectedAnswerIndex = selectedIndex;
      if (selectedIndex != null &&
          selectedIndex == questions[currentQuestionIndex].correctAnswerIndex) {
        score++;
      }
    });

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      
      if (currentQuestionIndex < questions.length - 1) {
        setState(() {
          currentQuestionIndex++;
          hasAnswered = false;
          selectedAnswerIndex = null;
        });
        _animationController.reset();
        _animationController.forward();
        _startTimer();
      } else {
        _saveScore();
        Navigator.of(context).pushReplacement(
          CustomPageRoute(
            child: ResultScreen(
              score: score,
              totalQuestions: questions.length,
              category: widget.category,
            ),
          ),
        );
      }
    });
  }

  Color getOptionColor(int optionIndex) {
    if (!hasAnswered) {
      return Theme.of(context).colorScheme.surface;
    }

    if (optionIndex == questions[currentQuestionIndex].correctAnswerIndex) {
      return Colors.green.withOpacity(0.15);
    }
    
    if (optionIndex == selectedAnswerIndex) {
      return Colors.red.withOpacity(0.15);
    }

    return Theme.of(context).colorScheme.surface;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primaryContainer.withOpacity(0.2),
              Theme.of(context).colorScheme.background,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton.filledTonal(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            widget.category.icon,
                            size: 20,
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            widget.category.name,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: _timeLeft <= 3
                            ? Theme.of(context).colorScheme.errorContainer
                            : Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$_timeLeft s',
                        style: TextStyle(
                          color: _timeLeft <= 3
                              ? Theme.of(context).colorScheme.onErrorContainer
                              : Theme.of(context).colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                LinearProgressIndicator(
                  value: (currentQuestionIndex + 1) / questions.length,
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.2),
                ),
                const SizedBox(height: 40),
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _slideAnimation.value),
                      child: Opacity(
                        opacity: _fadeAnimation.value,
                        child: child,
                      ),
                    );
                  },
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        questions[currentQuestionIndex].questionText,
                        style: Theme.of(context).textTheme.titleLarge,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Expanded(
                  child: AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _fadeAnimation.value,
                        child: child,
                      );
                    },
                    child: ListView.separated(
                      itemCount: questions[currentQuestionIndex].options.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          child: Card(
                            elevation: hasAnswered ? 1 : 2,
                            color: getOptionColor(index),
                            child: InkWell(
                              onTap: () => handleAnswer(index),
                              borderRadius: BorderRadius.circular(20),
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).colorScheme.primaryContainer,
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                      child: Center(
                                        child: Text(
                                          String.fromCharCode(65 + index),
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Text(
                                        questions[currentQuestionIndex].options[index],
                                        style: Theme.of(context).textTheme.bodyLarge,
                                      ),
                                    ),
                                    if (hasAnswered)
                                      AnimatedOpacity(
                                        duration: const Duration(milliseconds: 300),
                                        opacity: 1.0,
                                        child: Icon(
                                          index == questions[currentQuestionIndex].correctAnswerIndex
                                              ? Icons.check_circle_rounded
                                              : (index == selectedAnswerIndex ? Icons.cancel_rounded : null),
                                          color: index == questions[currentQuestionIndex].correctAnswerIndex
                                              ? Colors.green
                                              : Colors.red,
                                          size: 28,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ResultScreen extends StatelessWidget {
  final int score;
  final int totalQuestions;
  final QuizCategory category;

  const ResultScreen({
    super.key,
    required this.score,
    required this.totalQuestions,
    required this.category,
  });

  String getResultMessage() {
    final percentage = (score / totalQuestions) * 100;
    if (percentage == 100) {
      return 'Perfect Score! Outstanding!';
    } else if (percentage >= 80) {
      return 'Excellent Work!';
    } else if (percentage >= 60) {
      return 'Good Job!';
    } else if (percentage >= 40) {
      return 'Keep Practicing!';
    } else {
      return 'Time to Study More!';
    }
  }

  Color getScoreColor(BuildContext context) {
    final percentage = (score / totalQuestions) * 100;
    if (percentage >= 80) {
      return Colors.green;
    } else if (percentage >= 60) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  void _shareResult() {
    final percentage = (score / totalQuestions * 100).toStringAsFixed(0);
    final message = '''
🎯 Quiz Results - ${category.name}
Score: $score/$totalQuestions ($percentage%)
${getResultMessage()}

Try the quiz yourself! 🚀
''';
    Share.share(message);
  }

  @override
  Widget build(BuildContext context) {
    final percentage = (score / totalQuestions * 100).toStringAsFixed(0);
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primaryContainer.withOpacity(0.2),
              Theme.of(context).colorScheme.background,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TweenAnimationBuilder(
                    tween: Tween<double>(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 1000),
                    curve: Curves.elasticOut,
                    builder: (context, double value, child) {
                      return Transform.scale(
                        scale: value,
                        child: child,
                      );
                    },
                    child: Icon(
                      score == totalQuestions
                          ? Icons.emoji_events_rounded
                          : (score >= totalQuestions * 0.6
                              ? Icons.stars_rounded
                              : Icons.psychology_rounded),
                      size: 100,
                      color: getScoreColor(context),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Text(
                    'Quiz Completed!',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    getResultMessage(),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onBackground,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  TweenAnimationBuilder(
                    tween: Tween<double>(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 1200),
                    curve: Curves.elasticOut,
                    builder: (context, double value, child) {
                      return Transform.scale(
                        scale: value,
                        child: child,
                      );
                    },
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 32,
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  percentage,
                                  style: GoogleFonts.poppins(
                                    fontSize: 72,
                                    fontWeight: FontWeight.bold,
                                    color: getScoreColor(context),
                                  ),
                                ),
                                Text(
                                  '%',
                                  style: GoogleFonts.poppins(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: getScoreColor(context),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '$score out of $totalQuestions correct',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton.tonalIcon(
                    onPressed: _shareResult,
                    icon: const Icon(Icons.share_rounded),
                    label: const Text(
                      'Share Results',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        CustomPageRoute(child: const HomeScreen()),
                        (route) => false,
                      );
                    },
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text(
                      'Try Again',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
} 
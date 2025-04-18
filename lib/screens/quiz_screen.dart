import 'dart:async';
import 'package:flutter/material.dart';
import '../models/quiz_category.dart';
import '../models/question.dart';
import '../services/quiz_service.dart';
import '../services/audio_service.dart';
import '../widgets/quiz_option_button.dart';
import 'result_screen.dart';

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
  final _quizService = QuizService();
  final _audioService = AudioService();
  
  late final List<Question> _questions;
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _slideAnimation;
  
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _hasAnswered = false;
  int? _selectedAnswerIndex;
  Timer? _timer;
  int _timeLeft = 15;

  @override
  void initState() {
    super.initState();
    _questions = _quizService.getQuestionsForCategory(widget.category);
    _initializeAnimations();
    _startTimer();
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
    _timeLeft = 15;
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (_timeLeft > 0) {
          setState(() {
            _timeLeft--;
          });
        } else {
          _handleAnswer(null);
        }
      },
    );
  }

  void _handleAnswer(int? selectedIndex) async {
    if (_hasAnswered) return;

    _timer?.cancel();
    setState(() {
      _hasAnswered = true;
      _selectedAnswerIndex = selectedIndex;
    });

    // Play sound effect
    if (selectedIndex != null && 
        selectedIndex == _questions[_currentQuestionIndex].correctAnswerIndex) {
      await _audioService.playCorrectAnswer();
      setState(() => _score++);
    } else {
      await _audioService.playWrongAnswer();
    }

    // Wait before moving to next question
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      
      if (_currentQuestionIndex < _questions.length - 1) {
        setState(() {
          _currentQuestionIndex++;
          _hasAnswered = false;
          _selectedAnswerIndex = null;
        });
        _animationController.reset();
        _animationController.forward();
        _startTimer();
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => ResultScreen(
              score: _score,
              totalQuestions: _questions.length,
              category: widget.category,
            ),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = _questions[_currentQuestionIndex];
    
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
                        color: _timeLeft <= 5
                            ? Theme.of(context).colorScheme.errorContainer
                            : Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$_timeLeft s',
                        style: TextStyle(
                          color: _timeLeft <= 5
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
                  value: (_currentQuestionIndex + 1) / _questions.length,
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
                        currentQuestion.questionText,
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
                      itemCount: currentQuestion.options.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        return QuizOptionButton(
                          text: currentQuestion.options[index],
                          optionLetter: String.fromCharCode(65 + index),
                          isSelected: _selectedAnswerIndex == index,
                          isCorrect: index == currentQuestion.correctAnswerIndex,
                          hasAnswered: _hasAnswered,
                          onTap: () => _handleAnswer(index),
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
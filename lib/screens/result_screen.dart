import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import '../models/quiz_category.dart';
import '../models/quiz_result.dart';
import '../services/quiz_service.dart';
import '../services/quiz_results_service.dart';
import '../services/audio_service.dart';
import '../services/ad_manager.dart';
import 'quiz_screen.dart';
import 'home_screen.dart';

class ResultScreen extends StatefulWidget {
  final int score;
  final int totalQuestions;
  final QuizCategory category;

  const ResultScreen({
    super.key,
    required this.score,
    required this.totalQuestions,
    required this.category,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final _quizService = QuizService();
  final _audioService = AudioService();
  final _resultsService = QuizResultsService();
  late final QuizResult _result;

  @override
  void initState() {
    super.initState();
    _result = QuizResult(
      dateTime: DateTime.now(),
      category: widget.category,
      score: widget.score,
      totalQuestions: widget.totalQuestions,
    );
    _initializeResult();
    _showAd();
  }

  Future<void> _initializeResult() async {
    await _resultsService.saveQuizResult(_result);
    await _playResultSound();
  }

  Future<void> _playResultSound() async {
    if (_result.percentage >= 80) {
      await _audioService.playComplete();
    } else {
      await _audioService.playButtonClick();
    }
  }

  Future<void> _showAd() async {
    await AdManager.instance.showInterstitialAd();
  }

  Color _getScoreColor() {
    if (_result.percentage >= 80) {
      return Colors.green;
    } else if (_result.percentage >= 60) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  void _shareResult() {
    final message = '''
🎯 Quiz Results - ${widget.category.name}
Score: ${widget.score}/${widget.totalQuestions} (${_result.percentage.toStringAsFixed(0)}%)
${_quizService.getMotivationalMessage(widget.score, widget.totalQuestions)}

Try the quiz yourself! 🚀
''';
    Share.share(message);
  }

  void _restartQuiz() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => QuizScreen(category: widget.category),
      ),
    );
  }

  void _goToHome() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const HomeScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final percentage = _result.percentage.toStringAsFixed(0);
    final scoreColor = _getScoreColor();
    
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
                      _result.percentage == 100
                          ? Icons.emoji_events_rounded
                          : (_result.percentage >= 60
                              ? Icons.stars_rounded
                              : Icons.psychology_rounded),
                      size: 100,
                      color: scoreColor,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Text(
                    'Quiz Completed!',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _quizService.getMotivationalMessage(widget.score, widget.totalQuestions),
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
                                    color: scoreColor,
                                  ),
                                ),
                                Text(
                                  '%',
                                  style: GoogleFonts.poppins(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: scoreColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${widget.score} out of ${widget.totalQuestions} correct',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                  ),
                            ),
                            Text(
                              _result.formattedDate,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FilledButton.tonalIcon(
                        onPressed: _shareResult,
                        icon: const Icon(Icons.share_rounded),
                        label: const Text('Share'),
                      ),
                      const SizedBox(width: 16),
                      FilledButton.icon(
                        onPressed: _restartQuiz,
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Play Again'),
                      ),
                      const SizedBox(width: 16),
                      FilledButton.icon(
                        onPressed: _goToHome,
                        icon: const Icon(Icons.home_rounded),
                        label: const Text('Home'),
                      ),
                    ],
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
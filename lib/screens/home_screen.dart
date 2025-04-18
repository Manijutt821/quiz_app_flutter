import 'package:flutter/material.dart';
import '../models/quiz_category.dart';
import '../widgets/category_card.dart';
import '../widgets/theme_toggle_button.dart';
import '../services/audio_service.dart';
import '../services/score_service.dart';
import 'quiz_screen.dart';
import 'analytics_screen.dart';

class HomeScreen extends StatelessWidget {
  final ScoreService scoreService;

  const HomeScreen({
    super.key,
    required this.scoreService,
  });

  @override
  Widget build(BuildContext context) {
    final audioService = AudioService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz App'),
        actions: [
          const ThemeToggleButton(),
          IconButton(
            icon: Icon(
              audioService.isMuted ? Icons.volume_off : Icons.volume_up,
            ),
            onPressed: () {
              audioService.toggleMute();
            },
          ),
          IconButton(
            icon: const Icon(Icons.analytics_outlined),
            tooltip: 'Analytics',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AnalyticsScreen(
                  scoreService: scoreService,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Choose a Category',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              padding: const EdgeInsets.all(16),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: QuizCategory.values.map((category) {
                return CategoryCard(
                  category: category,
                  onTap: () async {
                    await audioService.playButtonClick();
                    if (context.mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => QuizScreen(category: category),
                        ),
                      );
                    }
                  },
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
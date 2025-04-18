import 'package:flutter/material.dart';
import '../models/score_model.dart';
import '../services/score_service.dart';
import '../models/quiz_category.dart';
import 'score_tile.dart';

class ScoreHistorySheet extends StatefulWidget {
  final ScoreService scoreService;

  const ScoreHistorySheet({
    super.key,
    required this.scoreService,
  });

  static Future<void> show(BuildContext context, ScoreService scoreService) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => ScoreHistorySheet(
          scoreService: scoreService,
        ),
      ),
    );
  }

  @override
  State<ScoreHistorySheet> createState() => _ScoreHistorySheetState();
}

class _ScoreHistorySheetState extends State<ScoreHistorySheet> {
  QuizCategory? _selectedCategory;
  bool _showingStats = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _buildHeader(context),
          if (_showingStats) _buildStats(context) else _buildScoreList(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Row(
            children: [
              Text(
                'Quiz History',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const Spacer(),
              IconButton(
                icon: Icon(_showingStats ? Icons.list : Icons.bar_chart),
                onPressed: () => setState(() => _showingStats = !_showingStats),
                tooltip: _showingStats ? 'Show List' : 'Show Stats',
              ),
              if (!_showingStats) ...[
                const SizedBox(width: 8),
                DropdownButton<QuizCategory?>(
                  value: _selectedCategory,
                  hint: const Text('All Categories'),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('All Categories'),
                    ),
                    ...QuizCategory.values.map((category) => DropdownMenuItem(
                          value: category,
                          child: Text(category.name),
                        )),
                  ],
                  onChanged: (category) => setState(() => _selectedCategory = category),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScoreList(BuildContext context) {
    List<ScoreHistoryModel> scores = widget.scoreService.scores;
    if (_selectedCategory != null) {
      scores = widget.scoreService.getScoresByCategory(_selectedCategory!.name);
    }

    if (scores.isEmpty) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.history_edu,
                size: 64,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
              ),
              const SizedBox(height: 16),
              Text(
                'No quiz history yet',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Complete a quiz to see your results here',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                    ),
              ),
            ],
          ),
        ),
      );
    }

    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: scores.length,
        itemBuilder: (context, index) => ScoreTile(
          score: scores[index],
          animate: index < 5,
        ),
      ),
    );
  }

  Widget _buildStats(BuildContext context) {
    final bestScore = widget.scoreService.getBestScore();
    final overallAverage = widget.scoreService.getOverallAverage();
    final categoryAverages = widget.scoreService.getCategoryAverages();
    final totalQuizzes = widget.scoreService.getTotalQuizzesTaken();

    return Expanded(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatCard(
              context,
              'Overall Statistics',
              [
                _buildStatItem(
                  context,
                  'Total Quizzes',
                  '$totalQuizzes',
                  Icons.quiz,
                ),
                if (bestScore != null)
                  _buildStatItem(
                    context,
                    'Best Score',
                    '${bestScore.percentage.toStringAsFixed(1)}%',
                    Icons.emoji_events,
                    color: bestScore.getScoreColor(context),
                  ),
                _buildStatItem(
                  context,
                  'Average Score',
                  '${overallAverage.toStringAsFixed(1)}%',
                  Icons.analytics,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildStatCard(
              context,
              'Category Averages',
              categoryAverages.entries.map((entry) {
                final category = QuizCategory.values.firstWhere(
                  (c) => c.name == entry.key,
                  orElse: () => QuizCategory.general,
                );
                return _buildStatItem(
                  context,
                  category.name,
                  '${entry.value.toStringAsFixed(1)}%',
                  category.icon,
                  color: category.color,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon, {
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (color ?? Theme.of(context).colorScheme.primary).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color ?? Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: color ?? Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
} 
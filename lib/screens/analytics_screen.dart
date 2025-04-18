import 'package:flutter/material.dart';
import '../services/score_service.dart';
import '../models/quiz_category.dart';
import '../widgets/score_chart.dart';

class AnalyticsScreen extends StatefulWidget {
  final ScoreService scoreService;

  const AnalyticsScreen({
    super.key,
    required this.scoreService,
  });

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _showingAllTime = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scores = widget.scoreService.scores;
    if (scores.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Analytics')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.analytics_outlined,
                size: 64,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
              ),
              const SizedBox(height: 16),
              Text(
                'No quiz data yet',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Complete some quizzes to see analytics',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                    ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Categories'),
          ],
        ),
        actions: [
          TextButton.icon(
            icon: Icon(_showingAllTime ? Icons.calendar_today : Icons.calendar_month),
            label: Text(_showingAllTime ? 'Last 30 Days' : 'All Time'),
            onPressed: () => setState(() => _showingAllTime = !_showingAllTime),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(context),
          _buildCategoriesTab(context),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(BuildContext context) {
    final scores = _showingAllTime
        ? widget.scoreService.scores
        : widget.scoreService.scores
            .where((s) => s.dateTime.isAfter(
                  DateTime.now().subtract(const Duration(days: 30)),
                ))
            .toList();

    final bestScore = widget.scoreService.getBestScore();
    final overallAverage = widget.scoreService.getOverallAverage();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Score Trend',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                ScoreChart(
                  scores: scores,
                  showCategories: false,
                  maxDataPoints: 15,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                'Best Score',
                bestScore?.percentage.toStringAsFixed(1) ?? '0.0',
                Icons.emoji_events,
                bestScore?.getScoreColor(context) ?? Theme.of(context).colorScheme.primary,
                subtitle: bestScore?.category.name ?? 'N/A',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                context,
                'Average Score',
                overallAverage.toStringAsFixed(1),
                Icons.analytics,
                Theme.of(context).colorScheme.primary,
                subtitle: '${scores.length} quizzes',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildTimeDistributionCard(context, scores),
      ],
    );
  }

  Widget _buildCategoriesTab(BuildContext context) {
    final categoryAverages = widget.scoreService.getCategoryAverages();
    final scores = widget.scoreService.scores;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Category Performance',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                ScoreChart(
                  scores: scores,
                  showCategories: true,
                  maxDataPoints: 15,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        ...QuizCategory.values.map((category) {
          final average = categoryAverages[category.name] ?? 0.0;
          final categoryScores = scores.where((s) => s.category == category).toList();
          if (categoryScores.isEmpty) return const SizedBox.shrink();

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _buildCategoryCard(
              context,
              category,
              average,
              categoryScores.length,
            ),
          );
        }),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color, {
    String? subtitle,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '$value%',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context,
    QuizCategory category,
    double average,
    int quizCount,
  ) {
    return Card(
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: category.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            category.icon,
            color: category.color,
          ),
        ),
        title: Text(category.name),
        subtitle: Text('$quizCount quizzes taken'),
        trailing: Text(
          '${average.toStringAsFixed(1)}%',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: category.color,
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
    );
  }

  Widget _buildTimeDistributionCard(BuildContext context, List<ScoreHistoryModel> scores) {
    // Group scores by hour of day
    final hourDistribution = List.generate(24, (index) => 0);
    for (final score in scores) {
      hourDistribution[score.dateTime.hour]++;
    }

    // Find peak hours
    final maxCount = hourDistribution.reduce(math.max);
    final peakHours = hourDistribution
        .asMap()
        .entries
        .where((e) => e.value == maxCount)
        .map((e) => e.key)
        .toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quiz Time Distribution',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 100,
              child: Row(
                children: List.generate(24, (hour) {
                  final count = hourDistribution[hour];
                  final height = count == 0 ? 0.0 : 20.0 + (count / maxCount) * 60;
                  return Expanded(
                    child: Column(
                      children: [
                        Expanded(
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              width: 8,
                              height: height,
                              decoration: BoxDecoration(
                                color: peakHours.contains(hour)
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).colorScheme.primary.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${hour.toString().padLeft(2, '0')}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                              ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Peak quiz time: ${peakHours.map((h) => '${h.toString().padLeft(2, '0')}:00').join(', ')}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
            ),
          ],
        ),
      ),
    );
  }
} 
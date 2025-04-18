import 'package:flutter/material.dart';
import '../models/score_model.dart';
import '../models/quiz_category.dart';
import 'dart:math' as math;

class ScoreChart extends StatelessWidget {
  final List<ScoreHistoryModel> scores;
  final bool showCategories;
  final double height;
  final int maxDataPoints;

  const ScoreChart({
    super.key,
    required this.scores,
    this.showCategories = true,
    this.height = 200,
    this.maxDataPoints = 10,
  });

  @override
  Widget build(BuildContext context) {
    if (scores.isEmpty) {
      return SizedBox(
        height: height,
        child: Center(
          child: Text(
            'No data available',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                ),
          ),
        ),
      );
    }

    return SizedBox(
      height: height,
      child: CustomPaint(
        size: Size.infinite,
        painter: _ScoreChartPainter(
          scores: scores.take(maxDataPoints).toList(),
          showCategories: showCategories,
          theme: Theme.of(context),
        ),
      ),
    );
  }
}

class _ScoreChartPainter extends CustomPainter {
  final List<ScoreHistoryModel> scores;
  final bool showCategories;
  final ThemeData theme;

  _ScoreChartPainter({
    required this.scores,
    required this.showCategories,
    required this.theme,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final dotPaint = Paint()
      ..style = PaintingStyle.fill;

    final height = size.height - 40; // Leave space for labels
    final width = size.width - 40; // Leave space for axis
    final chartArea = Rect.fromLTWH(30, 10, width, height);

    // Draw axes
    paint.color = theme.colorScheme.onSurface.withOpacity(0.2);
    canvas.drawLine(
      Offset(chartArea.left, chartArea.bottom),
      Offset(chartArea.right, chartArea.bottom),
      paint,
    );
    canvas.drawLine(
      Offset(chartArea.left, chartArea.top),
      Offset(chartArea.left, chartArea.bottom),
      paint,
    );

    // Draw grid lines and labels
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    for (var i = 0; i <= 5; i++) {
      final y = chartArea.bottom - (i * height / 5);
      paint.color = theme.colorScheme.onSurface.withOpacity(0.1);
      canvas.drawLine(
        Offset(chartArea.left, y),
        Offset(chartArea.right, y),
        paint,
      );

      // Draw percentage labels
      textPainter.text = TextSpan(
        text: '${i * 20}%',
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurface.withOpacity(0.5),
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(5, y - textPainter.height / 2),
      );
    }

    if (scores.isEmpty) return;

    // Draw data points and lines
    final pointWidth = width / (scores.length - 1);
    Path? categoryPath;
    QuizCategory? currentCategory;

    for (var i = scores.length - 1; i >= 0; i--) {
      final score = scores[i];
      final x = chartArea.left + ((scores.length - 1 - i) * pointWidth);
      final y = chartArea.bottom - (score.percentage * height / 100);

      if (showCategories) {
        if (currentCategory != score.category) {
          if (categoryPath != null) {
            paint.color = currentCategory!.color.withOpacity(0.8);
            canvas.drawPath(categoryPath, paint);
          }
          categoryPath = Path()..moveTo(x, y);
          currentCategory = score.category;
        } else {
          categoryPath?.lineTo(x, y);
        }

        dotPaint.color = score.category.color;
      } else {
        if (i == scores.length - 1) {
          categoryPath = Path()..moveTo(x, y);
        } else {
          categoryPath?.lineTo(x, y);
        }
        dotPaint.color = theme.colorScheme.primary;
      }

      // Draw point
      canvas.drawCircle(Offset(x, y), 4, dotPaint);
    }

    // Draw final path
    if (categoryPath != null) {
      paint.color = (showCategories ? currentCategory!.color : theme.colorScheme.primary).withOpacity(0.8);
      canvas.drawPath(categoryPath, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ScoreChartPainter oldDelegate) {
    return scores != oldDelegate.scores ||
        showCategories != oldDelegate.showCategories ||
        theme != oldDelegate.theme;
  }
} 
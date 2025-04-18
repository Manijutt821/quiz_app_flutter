import 'package:flutter/material.dart';

enum QuizCategory {
  general(
    id: 'general',
    name: 'General Knowledge',
    icon: Icons.lightbulb_outline,
    color: Colors.blue,
  ),
  science(
    id: 'science',
    name: 'Science',
    icon: Icons.science_outlined,
    color: Colors.green,
  ),
  history(
    id: 'history',
    name: 'History',
    icon: Icons.history_edu_outlined,
    color: Colors.brown,
  ),
  geography(
    id: 'geography',
    name: 'Geography',
    icon: Icons.public_outlined,
    color: Colors.orange,
  ),
  sports(
    id: 'sports',
    name: 'Sports',
    icon: Icons.sports_soccer_outlined,
    color: Colors.red,
  ),
  entertainment(
    id: 'entertainment',
    name: 'Entertainment',
    icon: Icons.movie_outlined,
    color: Colors.purple,
  );

  final String id;
  final String name;
  final IconData icon;
  final Color color;

  const QuizCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });
} 
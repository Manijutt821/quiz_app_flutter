import 'package:flutter/material.dart';

class QuizOptionButton extends StatelessWidget {
  final String text;
  final String optionLetter;
  final bool isSelected;
  final bool isCorrect;
  final bool hasAnswered;
  final VoidCallback? onTap;

  const QuizOptionButton({
    super.key,
    required this.text,
    required this.optionLetter,
    required this.isSelected,
    required this.isCorrect,
    required this.hasAnswered,
    this.onTap,
  });

  Color _getBackgroundColor(BuildContext context) {
    if (!hasAnswered) {
      return Theme.of(context).colorScheme.surface;
    }
    if (isCorrect) {
      return Colors.green.withOpacity(0.15);
    }
    if (isSelected) {
      return Colors.red.withOpacity(0.15);
    }
    return Theme.of(context).colorScheme.surface;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: Card(
        elevation: hasAnswered ? 1 : 2,
        color: _getBackgroundColor(context),
        child: InkWell(
          onTap: hasAnswered ? null : onTap,
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
                      optionLetter,
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
                    text,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                if (hasAnswered)
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: 1.0,
                    child: Icon(
                      isCorrect
                          ? Icons.check_circle_rounded
                          : (isSelected ? Icons.cancel_rounded : null),
                      color: isCorrect ? Colors.green : Colors.red,
                      size: 28,
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
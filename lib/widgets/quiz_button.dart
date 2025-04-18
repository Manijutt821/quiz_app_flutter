import 'package:flutter/material.dart';
import '../services/audio_service.dart';

class QuizButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final bool isCorrect;
  final bool isSelected;
  final bool showResult;
  final bool isEnabled;
  final double? width;
  final double? height;

  const QuizButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.isCorrect = false,
    this.isSelected = false,
    this.showResult = false,
    this.isEnabled = true,
    this.width,
    this.height,
  });

  Color _getButtonColor(BuildContext context) {
    if (!isEnabled) return Theme.of(context).disabledColor;
    if (!showResult) return Theme.of(context).primaryColor;
    if (isSelected) {
      return isCorrect
          ? Colors.green
          : Colors.red;
    }
    if (isCorrect) return Colors.green;
    return Theme.of(context).primaryColor;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: width,
      height: height ?? 56.0,
      child: ElevatedButton(
        onPressed: isEnabled
            ? () {
                AudioService.instance.playButtonClick();
                onPressed();
              }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: _getButtonColor(context),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: isEnabled ? 4 : 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                text,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
            ),
            if (showResult && isSelected)
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Icon(
                  isCorrect ? Icons.check_circle : Icons.cancel,
                  color: Colors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }
} 
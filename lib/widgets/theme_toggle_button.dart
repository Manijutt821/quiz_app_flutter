import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/theme_service.dart';

class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeService>(
      builder: (context, themeService, child) {
        return TweenAnimationBuilder<double>(
          tween: Tween<double>(
            begin: 0,
            end: themeService.isDarkMode ? 1 : 0,
          ),
          duration: const Duration(milliseconds: 300),
          builder: (context, value, child) {
            return Transform.rotate(
              angle: value * 2 * 3.14159,
              child: IconButton(
                icon: Stack(
                  alignment: Alignment.center,
                  children: [
                    Opacity(
                      opacity: 1 - value,
                      child: const Icon(Icons.light_mode_rounded),
                    ),
                    Opacity(
                      opacity: value,
                      child: const Icon(Icons.dark_mode_rounded),
                    ),
                  ],
                ),
                onPressed: () {
                  themeService.toggleTheme();
                },
                tooltip: themeService.isDarkMode ? 'Switch to light mode' : 'Switch to dark mode',
              ),
            );
          },
        );
      },
    );
  }
} 
import 'package:flutter/material.dart';

class ResponsiveUtils {
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600 &&
      MediaQuery.of(context).size.width < 900;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 900;

  static double getQuizCardWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 1200) return 900; // max width
    if (width >= 900) return width * 0.75;
    if (width >= 600) return width * 0.85;
    return width * 0.95;
  }

  static EdgeInsets getScreenPadding(BuildContext context) {
    if (isDesktop(context)) {
      return const EdgeInsets.symmetric(horizontal: 64, vertical: 32);
    }
    if (isTablet(context)) {
      return const EdgeInsets.symmetric(horizontal: 32, vertical: 24);
    }
    return const EdgeInsets.symmetric(horizontal: 16, vertical: 16);
  }

  static double getDialogWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 1200) return 600;
    if (width >= 900) return width * 0.5;
    if (width >= 600) return width * 0.7;
    return width * 0.9;
  }

  static double getFontSize(BuildContext context, double baseFontSize) {
    if (isDesktop(context)) return baseFontSize * 1.2;
    if (isTablet(context)) return baseFontSize * 1.1;
    return baseFontSize;
  }

  static double getIconSize(BuildContext context, double baseIconSize) {
    if (isDesktop(context)) return baseIconSize * 1.2;
    if (isTablet(context)) return baseIconSize * 1.1;
    return baseIconSize;
  }

  static int getGridCrossAxisCount(BuildContext context) {
    if (isDesktop(context)) return 4;
    if (isTablet(context)) return 3;
    return 2;
  }

  static Widget wrapWithMaxWidth(Widget child, {double maxWidth = 1200}) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }

  static Widget addResponsivePadding(BuildContext context, Widget child) {
    return Padding(
      padding: getScreenPadding(context),
      child: child,
    );
  }

  static Widget buildResponsiveBuilder({
    required Widget Function(BuildContext, BoxConstraints) builder,
    double maxWidth = 1200,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: maxWidth,
              minHeight: constraints.maxHeight,
            ),
            child: builder(context, constraints),
          ),
        );
      },
    );
  }
} 
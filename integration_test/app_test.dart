import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:quiz_app_flutter/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('App Test', () {
    testWidgets('Complete app flow test', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Verify home screen loads
      expect(find.text('Quiz App'), findsOneWidget);

      // Navigate to settings
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      // Verify settings screen
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Sound Effects'), findsOneWidget);
      expect(find.text('Background Music'), findsOneWidget);

      // Test audio toggles
      await tester.tap(find.byType(SwitchListTile).first);
      await tester.pumpAndSettle();

      // Navigate back
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Verify back on home screen
      expect(find.text('Quiz App'), findsOneWidget);
    });
  });
} 
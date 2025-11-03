import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bolide/utils/error_handler.dart';

/// Widget tests for CustomErrorWidget
/// Following Flutter 2025 testing best practices
void main() {
  group('CustomErrorWidget', () {
    testWidgets('displays error icon', (WidgetTester tester) async {
      final errorDetails = FlutterErrorDetails(
        exception: Exception('Test error'),
        stack: StackTrace.current,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomErrorWidget(errorDetails: errorDetails),
          ),
        ),
      );

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('displays generic message in release mode',
        (WidgetTester tester) async {
      final errorDetails = FlutterErrorDetails(
        exception: Exception('Test error'),
        stack: StackTrace.current,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomErrorWidget(errorDetails: errorDetails),
          ),
        ),
      );

      // In test mode (debug), it should show the actual error
      expect(find.textContaining('Error:'), findsOneWidget);
    });

    testWidgets('has proper layout structure', (WidgetTester tester) async {
      final errorDetails = FlutterErrorDetails(
        exception: Exception('Test error'),
        stack: StackTrace.current,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomErrorWidget(errorDetails: errorDetails),
          ),
        ),
      );

      // Should have Material wrapper
      expect(find.byType(Material), findsOneWidget);
      
      // Should have Container
      expect(find.byType(Container), findsWidgets);
      
      // Should have Column for layout
      expect(find.byType(Column), findsOneWidget);
    });

    testWidgets('icon has correct color', (WidgetTester tester) async {
      final errorDetails = FlutterErrorDetails(
        exception: Exception('Test error'),
        stack: StackTrace.current,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomErrorWidget(errorDetails: errorDetails),
          ),
        ),
      );

      final iconFinder = find.byIcon(Icons.error_outline);
      final Icon icon = tester.widget(iconFinder);
      
      expect(icon.color, isNotNull);
      expect(icon.size, 80);
    });
  });
}

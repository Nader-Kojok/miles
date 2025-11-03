# Testing Guide for Bolide App

This directory contains all tests for the Bolide application, following Flutter 2025 best practices.

## Test Structure

```
test/
├── unit/              # Unit tests for business logic
├── widget/            # Widget tests for UI components
└── integration/       # Integration tests for end-to-end flows
```

## Running Tests

### Run all tests
```bash
flutter test
```

### Run unit tests only
```bash
flutter test test/unit/
```

### Run widget tests only
```bash
flutter test test/widget/
```

### Run integration tests
```bash
flutter test integration_test/
```

### Run tests with coverage
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

## Test Types

### Unit Tests
- Test individual functions and classes
- Located in `test/unit/`
- Fast execution
- No Flutter dependencies required
- Example: `error_handler_test.dart`, `analytics_service_test.dart`

### Widget Tests
- Test UI components
- Located in `test/widget/`
- Test widget behavior and appearance
- Use `WidgetTester` for interaction
- Example: `custom_error_widget_test.dart`

### Integration Tests
- Test complete app flows
- Located in `integration_test/`
- Slower execution
- Test real app behavior
- Example: `app_test.dart`

## Writing Tests

### Unit Test Example
```dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MyClass', () {
    test('method returns expected value', () {
      final result = MyClass().method();
      expect(result, expectedValue);
    });
  });
}
```

### Widget Test Example
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('MyWidget displays correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(home: MyWidget()),
    );
    
    expect(find.text('Expected Text'), findsOneWidget);
  });
}
```

### Integration Test Example
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  testWidgets('complete user flow', (WidgetTester tester) async {
    // Test complete app flow
  });
}
```

## Best Practices

1. **Test Naming**: Use descriptive names that explain what is being tested
2. **AAA Pattern**: Arrange, Act, Assert
3. **Mock Dependencies**: Use mockito for mocking services
4. **Test Coverage**: Aim for >80% code coverage
5. **Fast Tests**: Keep unit tests fast, move slow tests to integration
6. **Isolated Tests**: Each test should be independent
7. **Clear Assertions**: One logical assertion per test when possible

## Mocking

Use `mockito` for creating mock objects:

```dart
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([MyService])
void main() {
  late MockMyService mockService;
  
  setUp(() {
    mockService = MockMyService();
  });
  
  test('test with mock', () {
    when(mockService.getData()).thenAnswer((_) async => 'data');
    // Test code here
  });
}
```

## Continuous Integration

Tests are automatically run on CI/CD pipeline:
- All tests must pass before merging
- Coverage reports are generated
- Integration tests run on real devices

## Resources

- [Flutter Testing Documentation](https://docs.flutter.dev/testing)
- [Effective Dart: Testing](https://dart.dev/guides/language/effective-dart/testing)
- [Mockito Documentation](https://pub.dev/packages/mockito)

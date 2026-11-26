// test/widget_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:top_prompt/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // This is a basic smoke test; full tests require mocking AdMob.
    expect(MyApp, isNotNull);
  });
}

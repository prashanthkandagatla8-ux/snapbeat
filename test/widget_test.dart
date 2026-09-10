import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snapbeat_flutter/main.dart';

void main() {
  testWidgets('SnapBeat smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const SnapBeatApp());
    expect(find.byType(SnapBeatApp), findsOneWidget);
  });
}

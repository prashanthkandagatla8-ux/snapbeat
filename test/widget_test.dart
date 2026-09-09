import 'package:flutter_test/flutter_test.dart';
import 'package:snapbeat_flutter/main.dart';

void main() {
  testWidgets('SnapBeat smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SnapBeatApp());
    expect(find.text('SnapBeat'), findsWidgets);
  });
}

import 'package:flutter_test/flutter_test.dart';

import 'package:awnwasand/main.dart';

void main() {
  testWidgets('Splash screen shows the association name', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const AwnWasandApp());

    expect(find.text('جمعية عون وسند الخيرية'), findsOneWidget);
    expect(find.text('عوّن وسند... نصنع الفرق'), findsOneWidget);
  });
}

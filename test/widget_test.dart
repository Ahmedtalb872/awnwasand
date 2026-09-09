import 'package:flutter_test/flutter_test.dart';

import 'package:awnwasand/main.dart';

void main() {
  testWidgets('Splash screen shows the platform name', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const AwnWasandApp());

    expect(find.text('المحجة البيضاء'), findsOneWidget);
    expect(find.text('للعلم الشرعي'), findsOneWidget);
  });
}

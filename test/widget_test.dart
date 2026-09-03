import 'package:flutter_test/flutter_test.dart';

import 'package:awnwasand/main.dart';

void main() {
  testWidgets('Home screen shows the app title', (WidgetTester tester) async {
    await tester.pumpWidget(const AwnWasandApp());

    expect(find.text('جمعية عون وسند الخيرية'), findsOneWidget);
    expect(find.text('مرحبًا بكم'), findsOneWidget);
  });
}

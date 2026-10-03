import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:awnwasand/main.dart';
import 'package:awnwasand/models.dart';
import 'package:awnwasand/learning_store.dart';

Future<void> pumpLearning(WidgetTester tester) async {
  final curriculum = Curriculum.decode(File('assets/curriculum.json').readAsStringSync());
  final store = await LearningStore.load();
  addTearDown(store.dispose);
  await tester.pumpWidget(AwnWasandApp(curriculum: curriculum, store: store));
  await tester.pumpAndSettle();
}

Finder lessonScroll() => find.descendant(of: find.byType(ListView), matching: find.byType(Scrollable)).first;

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('Arabic home opens a lesson and saves a passing quiz', (tester) async {
    await pumpLearning(tester);
    expect(find.text('المحجة البيضاء'), findsOneWidget);
    expect(Directionality.of(tester.element(find.text('المحجة البيضاء'))), TextDirection.rtl);
    await tester.tap(find.text('ابدأ التعلم الآن'));
    await tester.pumpAndSettle();
    expect(find.text('أركان الإيمان'), findsWidgets);
    final six = find.text('ستة');
    await tester.scrollUntilVisible(six, 250, scrollable: lessonScroll());
    await tester.tap(six);
    final lastDay = find.text('اليوم الآخر');
    await tester.scrollUntilVisible(lastDay, 200, scrollable: lessonScroll());
    await tester.tap(lastDay);
    final submit = find.text('تحقق من إجاباتي');
    await tester.scrollUntilVisible(submit, 200, scrollable: lessonScroll());
    await tester.tap(submit);
    await tester.pumpAndSettle();
    final result = find.text('100٪ — أحسنت! حُفظ إنجازك.');
    await tester.scrollUntilVisible(result, 200, scrollable: lessonScroll());
    expect(result, findsOneWidget);
  });

  testWidgets('small screen library handles empty search without overflow', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await pumpLearning(tester);
    await tester.tap(find.text('المكتبة'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'موضوع غير موجود');
    await tester.pumpAndSettle();
    expect(find.textContaining('لا توجد دروس مطابقة'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

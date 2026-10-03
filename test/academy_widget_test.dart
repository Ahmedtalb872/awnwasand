import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:awnwasand/academy.dart';
import 'package:awnwasand/main.dart';
import 'package:awnwasand/models.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  Future<Academy> start(WidgetTester tester) async {
    final repo = Academy(await SharedPreferences.getInstance());
    await repo.restore();
    addTearDown(repo.dispose);
    final data = Curriculum.decode(File('assets/curriculum.json').readAsStringSync());
    await tester.pumpWidget(AwnWasandApp(academy: repo, curriculum: data));
    await tester.pumpAndSettle();
    return repo;
  }
  testWidgets('approved brand and student area fit a narrow Arabic screen', (tester) async {
    await tester.binding.setSurfaceSize(const Size(360, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final repo = await start(tester);
    expect(find.text('ابدأ رحلتك في طلب العلم'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await repo.signUp('طالب جديد', '', '');
    await tester.pumpAndSettle();
    expect(find.text('المحجة البيضاء'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('حسابي'));
    await tester.pumpAndSettle();
    expect(find.text('تقدّمك الدراسي'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('welcome creates a student profile without admin access', (tester) async {
    final repo = await start(tester);
    expect(find.text('أنشئ ملف طالب للتجربة'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField), 'أحمد طالب');
    final submit = find.text('إنشاء ملف وبدء التعلم');
    await tester.ensureVisible(submit);
    await tester.tap(submit);
    await tester.pumpAndSettle();
    expect(repo.user!.name, 'أحمد طالب');
    expect(find.text('الإدارة'), findsNothing);
    await tester.tap(find.text('حسابي'));
    await tester.pumpAndSettle();
    expect(find.text('ملف الطالب'), findsOneWidget);
    expect(find.text('أحمد طالب'), findsOneWidget);
  });
  testWidgets('admin dashboard creates a course with title and description', (tester) async {
    final repo = await start(tester);
    await repo.selectDemo('demo-admin');
    await tester.pumpAndSettle();
    await tester.tap(find.text('الإدارة'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('إضافة دورة جديدة'));
    await tester.pumpAndSettle();
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'دورة الأخلاق');
    await tester.enterText(fields.at(1), 'شرح تفصيلي لتعلم الأخلاق الإسلامية');
    final save = find.text('حفظ الدورة');
    await tester.scrollUntilVisible(save, 300, scrollable: find.descendant(of: find.byType(ListView), matching: find.byType(Scrollable)).first);
    await tester.pumpAndSettle();
    await tester.tap(save);
    await tester.pumpAndSettle();
    expect(repo.courses.any((c) => c.title == 'دورة الأخلاق'), isTrue);
    expect(repo.courses.first.published, isFalse);
    expect(find.text('دورة الأخلاق'), findsOneWidget);
  });
}

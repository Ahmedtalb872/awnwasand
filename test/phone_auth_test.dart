import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:awnwasand/academy.dart';
import 'package:awnwasand/academy_models.dart';
import 'package:awnwasand/main.dart';
import 'package:awnwasand/models.dart';

class ConnectedAcademy extends Academy {
  ConnectedAcademy(super.preferences);
  @override
  bool get isDemo => false;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));
  test('international phone normalization accepts Arabic digits and rejects local numbers', () {
    expect(Academy.normalizePhone(' ٠٠٢١٢ (٦١٢) ٣٤٥-٦٧٨ '), '+212612345678');
    expect(Academy.normalizePhone('+۹۶۶۵۱۲۳۴۵۶۷۸'), '+966512345678');
    for (final value in ['0612345678', '+000123456', '+123', '+212abc123456', '+1234567890123456']) {
      expect(() => Academy.normalizePhone(value), throwsArgumentError);
    }
    final profile = StudentProfile.fromJson({'id': 'student', 'name': 'أحمد', 'phone': '+212612345678'});
    expect(StudentProfile.fromJson(profile.toJson()).phone, '+212612345678');
  });
  test('signup and password login send phone without an email identifier', () async {
    final requests = <http.Request>[];
    final transport = MockClient((request) async {
      requests.add(request);
      if (request.url.path.endsWith('/signup')) {
        return http.Response(jsonEncode({'user': {'id': '11111111-1111-4111-8111-111111111111', 'aud': 'authenticated', 'phone': '+212612345678', 'created_at': '2026-10-03T00:00:00Z', 'app_metadata': {}, 'user_metadata': {'name': 'طالب جديد'}}}), 200, headers: {'content-type': 'application/json'});
      }
      return http.Response(jsonEncode({'code': 'invalid_credentials', 'msg': 'Invalid login credentials'}), 400, headers: {'content-type': 'application/json'});
    });
    final client = SupabaseClient('https://example.supabase.co', 'test-public-key', httpClient: transport);
    final repo = Academy(await SharedPreferences.getInstance(), client: client);
    addTearDown(() async { repo.dispose(); await client.dispose(); transport.close(); });
    expect(await repo.signUp('طالب جديد', '00212 612345678', 'test-password'), isFalse);
    final signup = jsonDecode(requests.first.body) as Map<String, dynamic>;
    expect(signup['phone'], '+212612345678');
    expect(signup['email'], isNull);
    expect(signup['data']['name'], 'طالب جديد');
    await expectLater(repo.signIn('+212612345678', 'test-password'), throwsA(isA<AuthException>()));
    final login = jsonDecode(requests.last.body) as Map<String, dynamic>;
    expect(login['phone'], '+212612345678');
    expect(login['password'], 'test-password');
    expect(login['email'], isNull);
    final count = requests.length;
    await expectLater(repo.signUp('طالب جديد', '0612345678', 'test-password'), throwsArgumentError);
    expect(requests.length, count);
  });
  testWidgets('connected registration uses only name phone and password on mobile', (tester) async {
    await tester.binding.setSurfaceSize(const Size(360, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final repo = ConnectedAcademy(await SharedPreferences.getInstance());
    addTearDown(repo.dispose);
    final curriculum = Curriculum.decode(File('assets/curriculum.json').readAsStringSync());
    await tester.pumpWidget(AwnWasandApp(academy: repo, curriculum: curriculum));
    await tester.pumpAndSettle();
    await tester.tap(find.text('إنشاء حساب').first);
    await tester.pumpAndSettle();
    expect(find.byType(TextFormField), findsNWidgets(3));
    expect(find.text('اسم الطالب'), findsOneWidget);
    expect(find.text('رقم الهاتف'), findsOneWidget);
    expect(find.text('كلمة السر'), findsOneWidget);
    expect(find.text('البريد الإلكتروني'), findsNothing);
    expect(tester.takeException(), isNull);
  }, timeout: const Timeout(Duration(seconds: 45)));
}
